import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/navegacao_viewmodel.dart';
import 'views/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NavegacaoViewModel(),
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
      home: const MainScreen(),
    );
  }
}