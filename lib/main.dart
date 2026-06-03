// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/navegacao_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';
import 'views/main_screen.dart';
import 'views/first_acess.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavegacaoViewModel()),
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
    // Escuta o estado da sessão de forma reativa
    final session = Provider.of<SessionViewModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafeicultura',
      
      // A própria propriedade 'home' decide o que renderizar em tempo real
      home: session.isLoggedIn ? const MainScreen() : const FirstAcess(),
    );
  }
}