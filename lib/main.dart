import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/pessoas_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/auth/first_acess.dart';
import 'package:provider/provider.dart';

import 'viewmodels/navegacao_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';
import 'views/main_screen_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavegacaoViewModel()),
        ChangeNotifierProvider(create: (_) => SessionViewModel()),
        ChangeNotifierProvider(create: (_) => PropriedadesUsuarioViewModel()),
        ChangeNotifierProvider(create: (_) => PessoasViewModel()),
      ],
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafeicultura',
      home: AuthWrapper(), 
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionViewModel>(context);

    if (session.isInitializing) {
      return const Scaffold(
        backgroundColor: Color(0xFF9FB896),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    return session.isLoggedIn ? const MainScreenView() : const FirstAcess();
  }
}