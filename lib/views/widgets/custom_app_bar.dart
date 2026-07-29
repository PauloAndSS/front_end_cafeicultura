import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/atualizar_propriedade_view.dart';
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
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final listaPropriedades = propriedadesVM.propriedades;

    return AppBar(
      backgroundColor: const Color(0xFF8FA67E),
      elevation: 0,
      centerTitle: true,
      
      // ==========================================
      // CENTRO: LOGO
      // ==========================================
      title: Image.asset(
        'assets/images/logo_cafe.png',
        height: 80,
        fit: BoxFit.contain,
      ),

      // ==========================================
      // ESQUERDA: SELETOR DE PROPRIEDADE
      // ==========================================
      leadingWidth: 190,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700, size: 20),
              style: TextStyle(
                color: Colors.grey.shade800, 
                fontSize: 13, 
                fontWeight: FontWeight.w500,
              ),
              hint: propriedadesVM.isLoading
                  ? const Text('Carregando...', overflow: TextOverflow.ellipsis)
                  : const Text('Propriedade', overflow: TextOverflow.ellipsis),
              
              value: propriedadesVM.idPropriedadeSelecionada,
              
              items: [
                ...listaPropriedades.map((prop) {
                  return DropdownMenuItem<int>(
                    value: prop.id,
                    child: Text(
                      prop.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                
                if (propriedadesVM.idPropriedadeSelecionada != null)
                  const DropdownMenuItem<int>(
                    value: -2,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: Color(0xFF8FA67E)),
                        SizedBox(width: 8),
                        Text('Editar Atual', style: TextStyle(color: Color(0xFF8FA67E))),
                      ],
                    ),
                  ),
                
                const DropdownMenuItem<int>(
                  value: -1,
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 18, color: Color(0xFF8FA67E)),
                      SizedBox(width: 8),
                      Text(
                        'Nova Propriedade', 
                        style: TextStyle(color: Color(0xFF8FA67E), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (int? valorSelecionado) {
                if (valorSelecionado == -1) {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const CadastrarPropriedadeView())
                  );
                } else if (valorSelecionado == -2 && propriedadesVM.idPropriedadeSelecionada != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AtualizarPropriedadeView(
                        idPropriedade: propriedadesVM.idPropriedadeSelecionada!,
                      ),
                    ),
                  );
                } else if (valorSelecionado != null) {
                  propriedadesVM.selecionarPropriedade(valorSelecionado);
                }
              },
            ),
          ),
        ),
      ),

      // ==========================================
      // DIREITA: ÍCONES DE AÇÃO
      // ==========================================
      actions: [
        // 1. Sino de Notificações
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
          tooltip: 'Notificações',
          onPressed: () {
            // TODO: Implementar lógica de notificações futuramente
          },
        ),
        
        // 2. Menu do Usuário (Perfil)
        PopupMenuButton<String>(
          icon: const Icon(Icons.person_outline, color: Colors.white, size: 26),
          tooltip: 'Perfil',
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (String escolha) async {
            if (escolha == 'atualizar') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AtualizarDadosView()),
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
                leading: Icon(Icons.manage_accounts_outlined, color: Colors.black87),
                title: Text('Atualizar Dados'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'sair',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Encerrar Sessão', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          tooltip: 'Menu',
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (String escolha) {
            if (escolha == 'pessoas') {
              // TODO: Substituir pelo Navigator.push para a tela de Pessoas Cadastradas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecionando para Pessoas Cadastradas...')),
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'pessoas',
              child: ListTile(
                leading: Icon(Icons.groups_outlined, color: Colors.black87),
                title: Text('Pessoas Cadastradas'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}