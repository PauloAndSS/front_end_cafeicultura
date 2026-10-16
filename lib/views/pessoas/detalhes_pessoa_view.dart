import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/diarista.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/detalhes_pessoa_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/sessao_em_breve_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/widgets/editar_valor_painel.dart';

sealed class DesfechoDetalhePessoa {
  const DesfechoDetalhePessoa();
}

class PessoaAlterada extends DesfechoDetalhePessoa {
  final PapelPessoa papel;

  const PessoaAlterada(this.papel);
}

class PessoaExcluida extends DesfechoDetalhePessoa {
  final int id;

  const PessoaExcluida(this.id);
}

class DetalhesPessoaView extends StatefulWidget {
  final PapelPessoa papelPessoa;

  const DetalhesPessoaView({super.key, required this.papelPessoa});

  @override
  State<DetalhesPessoaView> createState() => _DetalhesPessoaViewState();
}

class _DetalhesPessoaViewState extends State<DetalhesPessoaView> {
  final _viewModel = DetalhesPessoaViewModel();
  bool _houveAlteracao = false;

  DesfechoDetalhePessoa? get _desfecho {
    final alterada = _viewModel.pessoaDetalhe;

    if (!_houveAlteracao || alterada == null) return null;

    return PessoaAlterada(alterada);
  }

  Future<void> _recarregar() {
    final tipoPapel = PessoaFactory.obterTipoPapel(widget.papelPessoa);

    return _viewModel.buscarPorId(widget.papelPessoa.id!, tipoPapel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _excluir() async {
    final tipoPapel = PessoaFactory.obterTipoPapel(widget.papelPessoa);
    final sucesso = await _viewModel.excluir(widget.papelPessoa.id!, tipoPapel);

    if (!mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Pessoa excluída com sucesso.');
      Navigator.pop(context, PessoaExcluida(widget.papelPessoa.id!));
    } else if (_viewModel.mensagemErro != null) {
      mostrarErro(context, _viewModel.mensagemErro!);
    }
  }

  Future<void> _editarSalario(Funcionario funcionario) => _concluirEdicao(
        mostrarEdicaoSalario(
          context,
          funcionario: funcionario,
          viewModel: _viewModel,
        ),
        'Salário atualizado.',
      );

  Future<void> _editarValorHora(Diarista diarista) => _concluirEdicao(
        mostrarEdicaoValorHora(
          context,
          diarista: diarista,
          viewModel: _viewModel,
        ),
        'Valor por hora atualizado.',
      );

  Future<void> _concluirEdicao(Future<bool> edicao, String mensagem) async {
    final salvou = await edicao;

    if (salvou && mounted) {
      _houveAlteracao = true;
      mostrarSucesso(context, mensagem);
    }
  }

  Widget _buildInfoRowEditavel(
    String label,
    String value, {
    required VoidCallback aoTocar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: _buildInfoRow(label, value, bottom: 0)),
                const Icon(Icons.edit, size: 22, color: AppCores.acao),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {double bottom = 14.0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppCores.textoSecundario,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppCores.textoPrimario,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _desfecho);
      },
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        appBar: AppBarPadrao(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _desfecho),
          ),
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading && _viewModel.pessoaDetalhe == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final papelAtual = _viewModel.pessoaDetalhe ?? widget.papelPessoa;
            final pessoaBase = papelAtual.pessoa;

            return RefreshIndicator(
              onRefresh: _recarregar,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.person_outline,
                      size: 100,
                      color: AppCores.textoPrimario,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pessoaBase.nomeParaExibicao,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: AppCores.textoPrimario,
                      ),
                    ),
                    const SizedBox(height: 24),

                    BotaoExcluir(
                      titulo: 'Excluir Pessoa?',
                      mensagem:
                          'Deseja realmente excluir '
                          '${widget.papelPessoa.pessoa.nomeParaExibicao}? '
                          'Esta ação não poderá ser desfeita.',
                      bloqueado: _viewModel.isLoading,
                      aoConfirmar: _excluir,
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalhes :',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppCores.textoPrimario,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            'Função :',
                            PessoaFactory.obterTipoPapel(papelAtual).titulo,
                          ),

                          _buildInfoRow(
                            pessoaBase is PessoaJuridica ? 'CNPJ :' : 'CPF :',
                            pessoaBase.documentoParaExibicao,
                          ),

                          if (pessoaBase is PessoaJuridica &&
                              (pessoaBase.inscricaoEstadual?.isNotEmpty ??
                                  false))
                            _buildInfoRow(
                              'Insc. Estadual :',
                              pessoaBase.inscricaoEstadual!,
                            ),

                          if (papelAtual is Diarista)
                            _buildInfoRowEditavel(
                              'Valor/Hora :',
                              papelAtual.valorHoraParaExibicao,
                              aoTocar: () => _editarValorHora(papelAtual),
                            ),

                          if (papelAtual is Funcionario) ...[
                            _buildInfoRow(
                              'CTPS :',
                              (papelAtual.ctps != null &&
                                      papelAtual.ctps!.isNotEmpty)
                                  ? papelAtual.ctps!
                                  : 'Não informado',
                            ),

                            _buildInfoRowEditavel(
                              'Salário :',
                              papelAtual.salarioParaExibicao,
                              aoTocar: () => _editarSalario(papelAtual),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    buildSecaoEmBreve('Documentos :'),
                    buildSecaoEmBreve('Atividades :'),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
