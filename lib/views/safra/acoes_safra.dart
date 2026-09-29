import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
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
  final dataInicio = await _perguntarData(
    context,
    titulo: 'Nova safra',
    descricao: 'Defina a data de início da safra para registrar o ciclo.',
    rotuloConfirmar: 'Salvar',
    ajuda: 'Selecione a data de início da safra',
    inicial: hoje(),
    minima: _pisoDeSafra,
    maxima: _tetoDeSafra,
  );

  if (dataInicio == null || !context.mounted) return;

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

class AvisoSemSafraAberta extends StatelessWidget {
  const AvisoSemSafraAberta({super.key});

  @override
  Widget build(BuildContext context) {
    return CaixaAvisoAtencao(
      mensagem:
          'Registre a data de início do Ciclo da sua Safra para poder registrar as atividades que acontecem nela.',
      acao: TextButton.icon(
        onPressed: () => abrirNovaSafra(context),
        icon: const Icon(Icons.grass, size: 18),
        label: const Text('Cadastrar safra'),
      ),
    );
  }
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

Future<DateTime?> _perguntarDataDeFim(BuildContext context, Safra safra) {
  final inicio = safra.dataInicio ?? _pisoDeSafra;

  return _perguntarData(
    context,
    titulo: 'Encerrar safra',
    descricao: 'Deseja encerrar a ${safra.nomeExibicao}?',
    rotuloConfirmar: 'Encerrar safra',
    corConfirmar: AppCores.aviso,
    rotuloDaData: 'Data de fim da safra',
    ajuda: 'Selecione a data de fim da safra',
    inicial: hoje(),
    minima: inicio,
    maxima: _tetoDeSafra,
    complemento: const CaixaAvisoAtencao(
      mensagem:
          'A safra deixa de aparecer no cadastro de novas '
          'atividades e nenhum dado dela poderá ser alterado. '
          'Ela continua na lista com o selo "Encerrada" e pode '
          'ser reativada quando você quiser.',
    ),
  );
}

Future<void> alterarDataInicioDaSafraSelecionada(BuildContext context) async {
  final viewModel = context.read<SafraViewModel>();
  final safra = viewModel.safraSelecionada;

  if (safra == null) {
    mostrarAviso(context, 'Selecione uma safra para alterar a data de início.');
    return;
  }

  if (safra.encerrada) {
    mostrarAviso(context, 'Reative a safra antes de alterar a data de início.');
    return;
  }

  final dataInicio = await _perguntarDataDeInicio(context, safra);

  if (dataInicio == null || !context.mounted) return;

  final idPropriedade = context
      .read<PropriedadesUsuarioViewModel>()
      .idPropriedadeSelecionada;

  if (idPropriedade == null) {
    mostrarErro(context, 'Não foi possível localizar a propriedade atual.');
    return;
  }

  final sucesso = await viewModel.editarDataInicioDaSafra(
    idPropriedade: idPropriedade,
    idSafra: safra.id ?? 0,
    dataInicio: dataInicio,
  );

  if (!context.mounted) return;

  mostrarResultado(
    context,
    sucesso
        ? 'Data de início da safra alterada.'
        : viewModel.mensagemErro ??
              'Não foi possível alterar a data de início da safra.',
    sucesso: sucesso,
  );
}

Future<DateTime?> _perguntarDataDeInicio(BuildContext context, Safra safra) {
  final inicioAtual = safra.dataInicio ?? hoje();

  return _perguntarData(
    context,
    titulo: 'Alterar data de início',
    descricao: 'Informe a nova data de início da ${safra.nomeExibicao}.',
    rotuloConfirmar: 'Salvar',
    rotuloDaData: 'Data de início da safra',
    ajuda: 'Selecione a nova data de início da safra',
    inicial: inicioAtual,
    minima: menorData(_pisoDeSafra, inicioAtual)!,
    maxima: safra.dataFim ?? hoje(),
    complemento: const CaixaAvisoAtencao(
      mensagem:
          'A nova data não pode ser posterior à atividade mais antiga já '
          'registrada nesta safra.',
    ),
  );
}

Future<DateTime?> _perguntarData(
  BuildContext context, {
  required String titulo,
  required String descricao,
  required String rotuloConfirmar,
  required String ajuda,
  required DateTime inicial,
  required DateTime minima,
  required DateTime maxima,
  String? rotuloDaData,
  Widget? complemento,
  Color corConfirmar = AppCores.acao,
}) async {
  var data = apenasData(inicial);

  if (data.isBefore(minima)) data = apenasData(minima);
  if (data.isAfter(maxima)) data = apenasData(maxima);

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contextoDoDialogo) {
      return StatefulBuilder(
        builder: (_, redesenhar) {
          return AlertDialog(
            title: Text(titulo),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(descricao),
                if (complemento != null) ...[
                  const SizedBox(height: 12),
                  complemento,
                ],
                const SizedBox(height: 12),
                if (rotuloDaData != null) ...[
                  Text(rotuloDaData),
                  const SizedBox(height: 8),
                ],
                SeletorDataEmBloco(
                  data: data,
                  aoTocar: () async {
                    final selecionada = await selecionarData(
                      context: contextoDoDialogo,
                      ajuda: ajuda,
                      inicial: data,
                      minima: minima,
                      maxima: maxima,
                    );
                    if (selecionada != null) {
                      redesenhar(() => data = selecionada);
                    }
                  },
                ),
              ],
            ),
            actions: acoesDeDialogo(
              context: contextoDoDialogo,
              rotuloConfirmar: rotuloConfirmar,
              corConfirmar: corConfirmar,
              aoConfirmar: () => Navigator.of(contextoDoDialogo).pop(true),
              aoCancelar: () => Navigator.of(contextoDoDialogo).pop(false),
            ),
          );
        },
      );
    },
  );

  return confirmado == true ? data : null;
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
