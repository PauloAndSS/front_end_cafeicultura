import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_encerrar.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campo_suspenso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/selo_situacao.dart';

class SafraSelectorWidget extends StatelessWidget {
  final List<Safra> safras;
  final Safra? safraSelecionada;
  final ValueChanged<Safra> onSelecionar;

  final bool mostrarAcoes;

  final bool isLoading;

  final VoidCallback? onNovaSafra;

  final VoidCallback? onEncerrarSafra;

  final VoidCallback? onReativarSafra;

  final VoidCallback? onEditarDataInicio;

  const SafraSelectorWidget({
    super.key,
    required this.safras,
    required this.safraSelecionada,
    required this.onSelecionar,
    this.mostrarAcoes = true,
    this.isLoading = false,
    this.onNovaSafra,
    this.onEncerrarSafra,
    this.onReativarSafra,
    this.onEditarDataInicio,
  }) : assert(
          !mostrarAcoes || onNovaSafra != null,
          'Ao usar mostrarAcoes: true, informe onNovaSafra (e, se fizer '
          'sentido nessa tela, onEncerrarSafra/onReativarSafra também).',
        );

  bool _podeEditarInicio(Safra safra) =>
      mostrarAcoes && onEditarDataInicio != null && !safra.encerrada;

  @override
  Widget build(BuildContext context) {
    final selecionada =
        safras.any((s) => s == safraSelecionada) ? safraSelecionada : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoSuspenso<Safra>(
              rotulo: 'Safra selecionada',
              valor: selecionada,
              itens: safras,
              rotuloItem: (safra) => safra.nomeExibicao,
              seloItem: (safra) =>
                  SeloDeSituacao.safra(encerrado: safra.encerrada),
              dica: 'Selecione a safra',
              aoSelecionar: safras.isEmpty
                  ? null
                  : (Safra? safra) {
                      if (safra != null) {
                        onSelecionar(safra);
                      }
                    },
            ),
            if (selecionada != null) ...[
              const SizedBox(height: 10),
              _LinhaDePeriodo(
                texto: selecionada.periodoTexto,
                onEditar: _podeEditarInicio(selecionada) && !isLoading
                    ? onEditarDataInicio
                    : null,
              ),
            ],
            if (selecionada?.encerrada ?? false) ...[
              const SizedBox(height: 10),
              const _AvisoSafraCongelada(),
            ],
            if (mostrarAcoes) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onNovaSafra,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Nova safra'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: (selecionada?.encerrada ?? false)
                        ? OutlinedButton.icon(
                            onPressed: isLoading ? null : onReativarSafra,
                            icon: const Icon(Icons.restart_alt, size: 20),
                            label: const Text('Reativar safra'),
                          )
                        : BotaoEncerrar(
                            rotulo: 'Encerrar safra',
                            carregando: isLoading,
                            aoTocar: selecionada == null ? null : onEncerrarSafra,
                          ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinhaDePeriodo extends StatelessWidget {
  final String texto;
  final VoidCallback? onEditar;

  const _LinhaDePeriodo({required this.texto, this.onEditar});

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppCores.textoSecundario,
        );

    if (onEditar == null) return Text(texto, style: estilo);

    return InkWell(
      onTap: onEditar,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(texto, style: estilo)),
            const SizedBox(width: 6),
            const Icon(
              Icons.edit_calendar_outlined,
              size: 16,
              color: AppCores.acao,
            ),
            const SizedBox(width: 4),
            Text(
              'Alterar início',
              style: estilo?.copyWith(
                color: AppCores.acao,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoSafraCongelada extends StatelessWidget {
  const _AvisoSafraCongelada();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lock_outline,
          size: 16,
          color: AppCores.textoSecundario,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Safra congelada: nenhum dado pode ser alterado até reativá-la.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppCores.textoSecundario,
                ),
          ),
        ),
      ],
    );
  }
}
