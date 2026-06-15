import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:provider/provider.dart';

class TalhaoView extends StatelessWidget {
  const TalhaoView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Talhões'),
        backgroundColor: const Color(0xFF67835C),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const Text(
              'Página Talhão',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), 
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: CustomButton(
                text: "Sair da conta",
                backgroundColor: Colors.red.shade700,
                onPressed: () async {
                  final session = Provider.of<SessionViewModel>(context, listen: false);
                  await session.logout();
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}