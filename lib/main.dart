// main.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/auth/first_acess.dart';
import 'package:provider/provider.dart';

import 'viewmodels/navegacao_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';
import 'views/main_screen_view.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafeicultura',
      home: Consumer<SessionViewModel>(
        builder: (context, session, child) {
          return session.isLoggedIn ? const MainScreenView() : const FirstAcess();
        },
      ),
    );
  }
}