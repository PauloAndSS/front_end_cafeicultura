import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/pessoas_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart'; 
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';

import 'package:frond_end_cafeicultura_mobile/views/auth/first_acess.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/main_screen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega os símbolos de data de pt-BR (nomes de mês e de dia da semana).
  // Os delegates do MaterialApp cobrem os widgets do Flutter, mas não o `intl`
  // usado direto pelo app e pelo calendário: sem isto, todo `DateFormat` com
  // locale explícito lança `LocaleDataException` em runtime.
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
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
        
        if (session.isLoggedIn) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => NavegacaoViewModel()),
              ChangeNotifierProvider(create: (_) => PropriedadesUsuarioViewModel()),
              ChangeNotifierProvider(create: (_) => PessoasViewModel()),
              ChangeNotifierProvider(create: (_) => TalhoesViewModel()),
              ChangeNotifierProvider(create: (_) => SafraViewModel()),
            ],
            child: child!,
          );
        }
        
        return child!;
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
        backgroundColor: Color(0xFF9FB896),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    return session.isLoggedIn ? const MainScreenView() : const FirstAcess();
  }
}