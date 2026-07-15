import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/proprietario/atualizar_dados_view.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionViewModel>(context, listen: false);
    final nomeCompleto = session.nomeUsuario;
    final primeiroNome = nomeCompleto.split(' ').first;
    return AppBar(
      title: Text("Olá, $primeiroNome"),
      backgroundColor: Colors.green,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.person, color: Colors.white),
          tooltip: 'Menu do Usuário',
          onSelected: (String escolha) async {
            if (escolha == 'atualizar') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AtualizarDadosView(),
                ),
              );
            } else if (escolha == 'sair') {
              await session.logout(); 
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'atualizar',
              child: ListTile(
                leading: Icon(Icons.manage_accounts),
                title: Text('Atualizar Dados'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'sair',
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Encerrar Sessão', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
}