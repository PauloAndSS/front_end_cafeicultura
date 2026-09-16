import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/dialogos.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/feedback_usuario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/seletor_data_em_bloco.dart';
import 'package:provider/provider.dart';

DateTime get _pisoDeSafra => DateTime(DateTime.now().year - 1);

DateTime get _tetoDeSafra => DateTime(DateTime.now().year + 5, 12, 31);

Future<void> abrirNovaSafra(BuildContext context) async {
  final hoje = DateTime.now();
  var dataInicio = DateTime(hoje.year, hoje.month, hoje.day);

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contextoDoDialogo) {
      return StatefulBuilder(
        builder: (_, redesenhar) {
          return AlertDialog(
            title: const Text('Nova safra'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Defina a data de início da safra para registrar o ciclo.',
                ),
                const SizedBox(height: 12),
                SeletorDataEmBloco(
                  data: dataInicio,
                  aoTocar: () async {
                    final selecionada = await selecionarData(
                      context: contextoDoDialogo,
                      ajuda: 'Selecione a data de início da safra',
                      inicial: dataInicio,
                      minima: _pisoDeSafra,
                      maxima: _tetoDeSafra,
                    );
                    if (selecionada != null) {
                      redesenhar(() => dataInicio = selecionada);
                    }
                  },
                ),
              ],
            ),
            actions: acoesDeDialogo(
              context: contextoDoDialogo,
              rotuloConfirmar: 'Salvar',
              aoConfirmar: () => Navigator.of(contextoDoDialogo).pop(true),
              aoCancelar: () => Navigator.of(contextoDoDialogo).pop(false),
            ),
          );
        },
      );
    },
  );

  if (confirmado != true || !context.mounted) return;

  final idPropriedade = context
      .read<PropriedadesUsuarioViewModel>()
      .idPropriedadeSelecionada;

  if (idPropriedade == null) {
    mostrarAviso(
      context,
      'Selecione uma propriedade antes de cadastrar uma safra.',
    );
    return;
  }

  final viewModel = context.read<SafraViewModel>();
  final sucesso = await viewModel.criarSafra(
    idPropriedade: idPropriedade,
    dataInicio: dataInicio,
  );

  if (!context.mounted) return;

  mostrarResultado(
    context,
    sucesso
        ? 'Safra cadastrada com sucesso.'
        : viewModel.mensagemErro ?? 'Não foi possível cadastrar a safra.',
    sucesso: sucesso,
  );
}

Future<void> encerrarSafraSelecionada(BuildContext context) async {
  final viewModel = context.read<SafraViewModel>();
  final safra = viewModel.safraSelecionada;

  if (safra == null) {
    mostrarAviso(context, 'Selecione uma safra para encerrá-la.');
    return;
  }

  if (safra.encerrada) {
    mostrarAviso(context, 'Esta safra já está encerrada.');
    return;
  }

  final dataFim = await _perguntarDataDeFim(context, safra);

  if (dataFim == null || !context.mounted) return;

  final idPropriedade = context
      .read<PropriedadesUsuarioViewModel>()
      .idPropriedadeSelecionada;

  if (idPropriedade == null) {
    mostrarErro(context, 'Não foi possível localizar a propriedade atual.');
    return;
  }

  final sucesso = await viewModel.encerrarSafra(
    idPropriedade: idPropriedade,
    idSafra: safra.id ?? 0,
    dataFim: dataFim,
  );

  if (!context.mounted) return;

  mostrarResultado(
    context,
    sucesso
        ? 'Safra encerrada. Ela continua na lista com o selo "Encerrada".'
        : viewModel.mensagemErro ?? 'Não foi possível encerrar a safra.',
    sucesso: sucesso,
  );
}

Future<DateTime?> _perguntarDataDeFim(BuildContext context, Safra safra) async {
  var dataFim = DateTime.now();
  final inicio = safra.dataInicio ?? _pisoDeSafra;

  if (dataFim.isBefore(inicio)) dataFim = inicio;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contextoDoDialogo) {
      return StatefulBuilder(
        builder: (_, redesenhar) {
          return AlertDialog(
            title: const Text('Encerrar safra'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deseja encerrar a ${safra.nomeExibicao}?'),
                const SizedBox(height: 12),
                const CaixaAvisoAtencao(
                  mensagem:
                      'A safra deixa de aparecer no cadastro de novas '
                      'atividades e nenhum dado dela poderá ser alterado. '
                      'Ela continua na lista com o selo "Encerrada" e pode '
                      'ser reativada quando você quiser.',
                ),
                const SizedBox(height: 12),
                const Text('Data de fim da safra'),
                const SizedBox(height: 8),
                SeletorDataEmBloco(
                  data: dataFim,
                  aoTocar: () async {
                    final selecionada = await selecionarData(
                      context: contextoDoDialogo,
                      ajuda: 'Selecione a data de fim da safra',
                      inicial: dataFim,
                      minima: inicio,
                      maxima: _tetoDeSafra,
                    );
                    if (selecionada != null) {
                      redesenhar(() => dataFim = selecionada);
                    }
                  },
                ),
              ],
            ),
            actions: acoesDeDialogo(
              context: contextoDoDialogo,
              rotuloConfirmar: 'Encerrar safra',
              corConfirmar: AppCores.aviso,
              aoConfirmar: () => Navigator.of(contextoDoDialogo).pop(true),
              aoCancelar: () => Navigator.of(contextoDoDialogo).pop(false),
            ),
          );
        },
      );
    },
  );

  return confirmado == true ? dataFim : null;
}

Future<void> reativarSafraSelecionada(BuildContext context) async {
  final viewModel = context.read<SafraViewModel>();
  final safra = viewModel.safraSelecionada;

  if (safra == null) {
    mostrarAviso(context, 'Selecione uma safra para reativá-la.');
    return;
  }

  if (!safra.encerrada) {
    mostrarAviso(context, 'Esta safra já está ativa.');
    return;
  }

  final confirmado = await confirmarAcao(
    context,
    titulo: 'Reativar safra',
    mensagem:
        'Deseja reativar a ${safra.nomeExibicao}? Os dados voltarão a poder '
        'ser editados normalmente.',
    rotuloConfirmar: 'Reativar',
    corConfirmar: AppCores.acao,
  );

  if (!confirmado || !context.mounted) return;

  final idPropriedade = context
      .read<PropriedadesUsuarioViewModel>()
      .idPropriedadeSelecionada;

  if (idPropriedade == null) {
    mostrarErro(context, 'Não foi possível localizar a propriedade atual.');
    return;
  }

  final sucesso = await viewModel.reativarSafra(
    idPropriedade: idPropriedade,
    idSafra: safra.id ?? 0,
  );

  if (!context.mounted) return;

  mostrarResultado(
    context,
    sucesso
        ? 'Safra reativada com sucesso.'
        : viewModel.mensagemErro ?? 'Não foi possível reativar a safra.',
    sucesso: sucesso,
  );
}
