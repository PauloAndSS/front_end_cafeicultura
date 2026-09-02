import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/funcionario.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/meeiro.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/prestador.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/detalhes_pessoa_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_excluir.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/sessao_em_breve_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/app_bar_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';

class DetalhesPessoaView extends StatefulWidget {
  final PapelPessoa papelPessoa;

  const DetalhesPessoaView({super.key, required this.papelPessoa});

  @override
  State<DetalhesPessoaView> createState() => _DetalhesPessoaViewState();
}

class _DetalhesPessoaViewState extends State<DetalhesPessoaView> {
  final _viewModel = DetalhesPessoaViewModel();
  bool _houveAlteracao = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tipoPapel = PessoaFactory.obterTipoPapel(widget.papelPessoa);
      _viewModel.buscarPorId(widget.papelPessoa.id!, tipoPapel);
    });
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
      Navigator.pop(context, true);
    } else if (_viewModel.mensagemErro != null) {
      mostrarErro(context, _viewModel.mensagemErro!);
    }
  }

  Future<void> _editarSalario(Funcionario funcionario) async {
    final salarioAtual =
        funcionario.salario?.toStringAsFixed(2).replaceAll('.', ',') ?? '';
    final controller = TextEditingController(text: salarioAtual);
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Atualizar Salário'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [AppMasks.decimal],
            decoration: const InputDecoration(
              labelText: 'Novo Salário (R\$)',
              hintText: '0,00',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o valor';
              }
              final valorT = value.replaceAll('.', '').replaceAll(',', '.');
              if (double.tryParse(valorT) == null) return 'Valor inválido';
              return null;
            },
          ),
        ),
        actions: acoesDeDialogo(
          context: context,
          rotuloConfirmar: 'Salvar',
          corConfirmar: AppCores.verdeSecundario,
          aoCancelar: () => Navigator.pop(context, false),
          aoConfirmar: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, true);
            }
          },
        ),
      ),
    );

    if (resultado == true && mounted) {
      final valorFormatado = controller.text
          .replaceAll('.', '')
          .replaceAll(',', '.');
      final novoSalario = double.parse(valorFormatado);

      final sucesso = await _viewModel.atualizarSalario(
        funcionario.id!,
        novoSalario,
      );

      if (sucesso && mounted) {
        _houveAlteracao = true;
        mostrarSucesso(context, 'Salário atualizado com sucesso!');
        final tipoPapel = PessoaFactory.obterTipoPapel(widget.papelPessoa);
        await _viewModel.buscarPorId(funcionario.id!, tipoPapel);
      } else if (mounted && _viewModel.mensagemErro != null) {
        mostrarErro(context, _viewModel.mensagemErro!);
      }
    }
  }

  String _obterNomeFuncao(PapelPessoa item) {
    if (item is Funcionario) return 'Funcionário';
    if (item is Fornecedor) return 'Fornecedor';
    if (item is Cliente) return 'Cliente';
    if (item is Meeiro) return 'Meeiro';
    if (item is PrestadorDeServico) return 'Prestador de Serviço';
    return 'Não definido';
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
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
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
        Navigator.pop(context, _houveAlteracao);
      },
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        appBar: AppBarPadrao(
          cor: AppCores.fundo,
          corConteudo: Colors.black87,
          elevacao: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _houveAlteracao),
          ),
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppCores.verdeSecundario),
              );
            }

            final papelAtual = _viewModel.pessoaDetalhe ?? widget.papelPessoa;
            final pessoaBase = papelAtual.pessoa;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.person_outline,
                    size: 100,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pessoaBase.nomeParaExibicao,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
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
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoRow('Função :', _obterNomeFuncao(papelAtual)),

                        if (pessoaBase is PessoaFisica) ...[
                          _buildInfoRow('CPF :', pessoaBase.cpf.formatado),
                        ] else if (pessoaBase is PessoaJuridica) ...[
                          _buildInfoRow('CNPJ :', pessoaBase.cnpj.formatado),
                          if (pessoaBase.inscricaoEstadual != null &&
                              pessoaBase.inscricaoEstadual!.isNotEmpty)
                            _buildInfoRow(
                              'Insc. Estadual :',
                              pessoaBase.inscricaoEstadual!,
                            ),
                        ],

                        if (papelAtual is Funcionario) ...[
                          _buildInfoRow(
                            'CTPS :',
                            (papelAtual.ctps != null &&
                                    papelAtual.ctps!.isNotEmpty)
                                ? papelAtual.ctps!
                                : 'Não informado',
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 130,
                                  child: Text(
                                    'Salário :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'R\$ ${papelAtual.salario?.toStringAsFixed(2).replaceAll('.', ',') ?? '0,00'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 22,
                                    color: AppCores.verdeSecundario,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _editarSalario(papelAtual),
                                ),
                              ],
                            ),
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
            );
          },
        ),
      ),
    );
  }
}
