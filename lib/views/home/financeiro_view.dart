import 'package:flutter/material.dart';

class FinanceiroView extends StatelessWidget {
  const FinanceiroView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Página Financeiro',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}