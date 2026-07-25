import 'package:flutter/material.dart';

class FuncionariosView extends StatelessWidget {
  const FuncionariosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Página Funcionários',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}