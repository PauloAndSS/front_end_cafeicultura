import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/cadastrar_propriedade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/proprietario/atualizar_dados_view.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();

    final nomeCompleto = session.nomeUsuario;
    final primeiroNome = nomeCompleto.split(' ').first;

    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final listaPropriedades = propriedadesVM.propriedades;
    return AppBar(
      title: Row(
        children: [
          Text("Olá, $primeiroNome"),
          const SizedBox(width: 16),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  dropdownColor: Colors.green.shade800,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  hint: propriedadesVM.isLoading
                      ? const Text('Carregando...', style: TextStyle(color: Colors.white70))
                      : const Text('Selecionar Propriedade', style: TextStyle(color: Colors.white)),
                  
                  value: null, 
                  
                  items: [
                    ...listaPropriedades.map((prop) {
                      return DropdownMenuItem<int>(
                        value: prop.id,
                        child: Text(
                          prop.nome,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                    
                    const DropdownMenuItem<int>(
                      value: -1,
                      child: Text(
                        '+ Nova Propriedade',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  
                  onChanged: (int? valorSelecionado) {
                    if (valorSelecionado == -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastrarPropriedadeView(),
                        ),
                      );
                    } else if (valorSelecionado != null) {
                      propriedadesVM.selecionarPropriedade(valorSelecionado);
                      debugPrint('Propriedade selecionada ID: $valorSelecionado');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
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