import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhoes_viewmodel.dart'; 
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/financeiro/financeiro_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/financeiro/financeiro_mudou.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notificacoes/notificacoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/status_de_conexao.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/tela_sem_conexao.dart';

import 'package:frond_end_cafeicultura_mobile/views/auth/first_acess.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/main_screen_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_tema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  final statusDeConexao = StatusDeConexao();
  BaseService.aoPerderConexao = statusDeConexao.registrarFalha;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StatusDeConexao>.value(value: statusDeConexao),
        ChangeNotifierProvider(create: (_) => SessionViewModel()),
      ],
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafeicultura',
      theme: AppTema.claro,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      
      builder: (context, child) {
        final session = context.watch<SessionViewModel>();

        if (!session.isLoggedIn) {
          return GuardaDeConexao(filho: child!);
        }

        return GuardaDeConexao(
          filho: MultiProvider(
            key: ValueKey(session.idUsuario),
            providers: [
              ChangeNotifierProvider(create: (_) => NavegacaoViewModel()),
              ChangeNotifierProvider(create: (_) => PropriedadesUsuarioViewModel()),
              ChangeNotifierProvider(create: (_) => TalhoesViewModel()),
              ChangeNotifierProvider(create: (_) => SafraViewModel()),
              // Precisa vir ANTES do FinanceiroViewModel, que depende dele
              // para avisar a aba Safra quando uma despesa muda.
              ChangeNotifierProvider(create: (_) => FinanceiroMudou()),
              ChangeNotifierProxyProvider<FinanceiroMudou, FinanceiroViewModel>(
                create: (context) => FinanceiroViewModel(
                  financeiroMudou: context.read<FinanceiroMudou>(),
                ),
                update: (context, financeiroMudou, viewModel) => viewModel!,
              ),
              ChangeNotifierProvider(create: (_) => AtividadesMudaram()),
              ChangeNotifierProvider(create: (_) => NotificacoesViewModel()),
            ],
            child: child!,
          ),
        );
      },
      home: const AuthWrapper(), 
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();

    if (session.isInitializing) {
      return const Scaffold(
        backgroundColor: AppCores.fundo,
        body: Center(
          child: CircularProgressIndicator(color: AppCores.acao),
        ),
      );
    }
    
    return session.isLoggedIn ? const MainScreenView() : const FirstAcess();
  }
}