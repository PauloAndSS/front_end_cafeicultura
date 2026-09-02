import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/detalhes_despesa_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/secao_lista_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/transacao_financeira_dialog.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/selecionar_responsaveis_modal.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:provider/provider.dart';

class SecaoResponsaveisAtividade<T extends EventoAgricola>
    extends StatelessWidget {
  final DetalhesAtividadeViewModel<T> viewModel;

  final bool podeEditar;

  const SecaoResponsaveisAtividade({
    super.key,
    required this.viewModel,
    required this.podeEditar,
  });

  Future<void> _editar(BuildContext context) async {
    final escolhidos = await mostrarSelecaoResponsaveis(
      context: context,
      viewModel: viewModel,
      selecionadosAtuais: viewModel.atividade.responsaveis,
    );

    if (escolhidos == null || !context.mounted) return;

    await _aplicar(context, escolhidos);
  }

  Future<void> _remover(BuildContext context, Pessoa pessoa) {
    return _aplicar(
      context,
      viewModel.atividade.responsaveis
          .where((atual) => atual.id != pessoa.id)
          .toList(),
    );
  }

  Future<void> _aplicar(BuildContext context, List<Pessoa> escolhidos) async {
    final sucesso = await viewModel.alterarResponsaveis(escolhidos);

    if (!context.mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Responsáveis atualizados com sucesso!');
    } else {
      mostrarErro(
        context,
        viewModel.mensagemErro ?? 'Erro ao alterar os responsáveis.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsaveis = viewModel.atividade.responsaveis;

    final habilitado = podeEditar && viewModel.podeAlterarResponsaveis;

    return SecaoListaAtividade<Pessoa>(
      titulo: 'Responsáveis',
      icone: Icons.group_outlined,
      rotuloVazio: 'Selecionar responsáveis',
      textoVazio: 'Nenhum responsável',
      rotuloContagem: responsaveis.contagem,
      itens: responsaveis,
      rotuloItem: (pessoa) => pessoa.nomeParaExibicao,
      aoAbrir: habilitado ? () => _editar(context) : null,
      aoRemover: (pessoa) => _remover(context, pessoa),
    );
  }
}

class SecaoDespesasAtividade<T extends EventoAgricola>
    extends StatelessWidget {
  final DetalhesAtividadeViewModel<T> viewModel;

  final bool podeEditar;

  final String motivoSomenteLeitura;

  const SecaoDespesasAtividade({
    super.key,
    required this.viewModel,
    required this.podeEditar,
    required this.motivoSomenteLeitura,
  });

  Future<void> _lancar(BuildContext context) async {
    final idPropriedade =
        context.read<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada;

    if (idPropriedade == null) {
      mostrarAviso(
        context,
        'Selecione uma propriedade antes de lançar uma despesa.',
      );
      return;
    }

    final despesa = await mostrarCadastroTransacao(
      context: context,
      idPropriedade: idPropriedade,
      catalogoDePessoas: viewModel,
      responsaveis: viewModel.atividade.responsaveis,
    );

    if (despesa == null || !context.mounted) return;

    final sucesso = await viewModel.lancarDespesa(despesa);

    if (!context.mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Despesa lançada com sucesso!');
    } else {
      mostrarErro(context, viewModel.mensagemErro ?? 'Erro ao lançar a despesa.');
    }
  }

  Future<void> _consultar(BuildContext context, Despesa despesa) async {
    await mostrarDetalhesDespesa(
      context: context,
      despesa: despesa,
      podeExcluir: false,
      motivoBloqueio: motivoSomenteLeitura,
    );
  }

  Future<void> _abrirDetalhes(BuildContext context, Despesa despesa) async {
    final semIdentificador = despesa.id == null;

    final excluir = await mostrarDetalhesDespesa(
      context: context,
      despesa: despesa,
      podeExcluir: !semIdentificador,
      motivoBloqueio: semIdentificador
          ? 'Esta despesa acabou de ser lançada e o servidor ainda não '
              'devolveu o identificador dela. Volte e abra a atividade '
              'novamente para poder excluí-la.'
          : null,
    );

    if (!excluir || !context.mounted) return;

    await _remover(context, despesa);
  }

  Future<void> _remover(BuildContext context, Despesa despesa) async {
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Excluir despesa?',
      mensagem: 'Deseja realmente excluir "${despesa.resumoComBeneficiado}"? '
          'Esta ação não poderá ser desfeita.',
      rotuloConfirmar: 'Excluir',
    );

    if (!confirmou || !context.mounted) return;

    final sucesso = await viewModel.excluirDespesa(despesa);

    if (!context.mounted) return;

    if (sucesso) {
      mostrarSucesso(context, 'Despesa excluída com sucesso!');
    } else {
      mostrarErro(context, viewModel.mensagemErro ?? 'Erro ao excluir a despesa.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final despesas = viewModel.despesas;

    final habilitado = podeEditar && viewModel.podeLancarDespesa;

    return SecaoListaAtividade<Despesa>(
      titulo: 'Despesas',
      icone: Icons.payments_outlined,
      rotuloVazio: 'Adicionar despesa',
      textoVazio: 'Nenhuma despesa lançada',
      rotuloContagem: despesas.contagemComTotal,
      itens: despesas,
      rotuloItem: (despesa) => despesa.resumoComBeneficiado,
      aoAbrir: habilitado ? () => _lancar(context) : null,
      aoRemover: (despesa) => _remover(context, despesa),
      podeRemover: (despesa) => despesa.id != null,
      aoTocarItem: habilitado
          ? (despesa) => _abrirDetalhes(context, despesa)
          : (despesa) => _consultar(context, despesa),
    );
  }
}
