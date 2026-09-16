import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/notificacoes/widgets/sino_notificacoes.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/pessoas_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/atualizar_propriedade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/acoes_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/proprietario/atualizar_dados_view.dart';
import 'package:provider/provider.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _navegarSubstituindo(BuildContext context, Widget novaTela) {
    final rotaAtual = ModalRoute.of(context);
    final nome = novaTela.runtimeType.toString();

    if (rotaAtual?.settings.name == nome) {
      return;
    }

    final rota = MaterialPageRoute(
      builder: (_) => novaTela,
      settings: RouteSettings(name: nome),
    );

    if (rotaAtual?.isFirst ?? true) {
      Navigator.push(context, rota);
    } else {
      Navigator.pushReplacement(context, rota);
    }
  }

  void _navegarFormulario(BuildContext context, Widget novaTela) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => novaTela));
  }

  Widget _botaoPrimeiraPropriedade(BuildContext context) {
    return InkWell(
      onTap: () => abrirCadastroDePropriedade(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 18, color: AppCores.acao),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Nova propriedade',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppCores.acao,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _irParaInicio(BuildContext context) {
    context.read<NavegacaoViewModel>().irParaInicio();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _encerrarSessao(
    BuildContext context,
    SessionViewModel session,
  ) async {
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Encerrar sessão?',
      mensagem: 'Você precisará informar login e senha para entrar novamente.',
      rotuloConfirmar: 'Encerrar',
    );

    if (!confirmou || !context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
    await session.logout();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
    final listaPropriedades = propriedadesVM.propriedades;
    final int? idSelecionadoValido =
        listaPropriedades.any(
          (p) => p.id == propriedadesVM.idPropriedadeSelecionada,
        )
        ? propriedadesVM.idPropriedadeSelecionada
        : null;

    return AppBar(
      centerTitle: true,
      title: Tooltip(
        message: 'Início',
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _irParaInicio(context),
          child: Image.asset(
            'assets/images/logo_cafe.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
      leadingWidth: 190,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppCores.fundo,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppCores.bordaCampo),
          ),
          child: listaPropriedades.isEmpty && !propriedadesVM.isLoading
              ? _botaoPrimeiraPropriedade(context)
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    dropdownColor: AppCores.superficie,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppCores.textoSecundario,
                      size: 20,
                    ),
                    style: TextStyle(
                      color: AppCores.textoPrimario,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    hint: propriedadesVM.isLoading
                        ? const Text(
                            'Carregando...',
                            overflow: TextOverflow.ellipsis,
                          )
                        : const Text(
                            'Propriedade',
                            overflow: TextOverflow.ellipsis,
                          ),

                    value: idSelecionadoValido,

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

                      if (idSelecionadoValido != null)
                        const DropdownMenuItem<int>(
                          value: -2,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: AppCores.acao,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Editar Atual',
                                style: TextStyle(color: AppCores.acao),
                              ),
                            ],
                          ),
                        ),

                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18, color: AppCores.acao),
                            SizedBox(width: 8),
                            Text(
                              'Nova Propriedade',
                              style: TextStyle(
                                color: AppCores.acao,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (int? valorSelecionado) {
                      if (valorSelecionado == -1) {
                        abrirCadastroDePropriedade(context);
                      } else if (valorSelecionado == -2 &&
                          idSelecionadoValido != null) {
                        _navegarFormulario(
                          context,
                          AtualizarPropriedadeView(
                            idPropriedade: idSelecionadoValido,
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
      actions: [
        const SinoNotificacoes(),

        PopupMenuButton<String>(
          icon: const Icon(
            Icons.person_outline,
            color: AppCores.sobreCasca,
            size: 26,
          ),
          tooltip: 'Perfil',
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (String escolha) {
            if (escolha == 'atualizar') {
              _navegarFormulario(context, const AtualizarDadosView());
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'atualizar',
              child: ListTile(
                leading: Icon(
                  Icons.manage_accounts_outlined,
                  color: AppCores.textoPrimario,
                ),
                title: Text('Atualizar Dados'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),

        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: AppCores.sobreCasca, size: 28),
          tooltip: 'Menu',
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (String escolha) async {
            if (escolha == 'pessoas') {
              _navegarSubstituindo(context, const PessoasView());
            } else if (escolha == 'sair') {
              await _encerrarSessao(context, session);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'pessoas',
              child: ListTile(
                leading: Icon(
                  Icons.groups_outlined,
                  color: AppCores.textoPrimario,
                ),
                title: Text('Pessoas Cadastradas'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'sair',
              child: ListTile(
                leading: Icon(Icons.logout, color: AppCores.erro),
                title: Text(
                  'Encerrar Sessão',
                  style: TextStyle(color: AppCores.erro),
                ),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
