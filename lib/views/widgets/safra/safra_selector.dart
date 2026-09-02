import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/botao_encerrar.dart';

class SafraSelectorWidget extends StatelessWidget {
  final List<Safra> safras;
  final Safra? safraSelecionada;
  final ValueChanged<Safra> onSelecionar;

  final bool mostrarAcoes;

  final bool isLoading;
  final String? titulo;
  final String? subtitulo;

  final VoidCallback? onNovaSafra;

  final VoidCallback? onEncerrarSafra;

  final VoidCallback? onReativarSafra;

  const SafraSelectorWidget({
    super.key,
    required this.safras,
    required this.safraSelecionada,
    required this.onSelecionar,
    this.mostrarAcoes = true,
    this.isLoading = false,
    this.titulo,
    this.subtitulo,
    this.onNovaSafra,
    this.onEncerrarSafra,
    this.onReativarSafra,
  }) : assert(
          !mostrarAcoes || onNovaSafra != null,
          'Ao usar mostrarAcoes: true, informe onNovaSafra (e, se fizer '
          'sentido nessa tela, onEncerrarSafra/onReativarSafra também).',
        );

  List<Safra> get _safrasEmOrdem {
    final ordenadas = List<Safra>.from(safras);
    ordenadas.sort((a, b) {
      final dataA = a.dataInicio ?? a.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dataB = b.dataInicio ?? b.dataFim ?? DateTime.fromMillisecondsSinceEpoch(0);
      final comparacaoData = dataA.compareTo(dataB);
      if (comparacaoData != 0) {
        return comparacaoData;
      }
      return (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return ordenadas;
  }

  @override
  Widget build(BuildContext context) {
    final safrasEmOrdem = _safrasEmOrdem;
    final temSafraSelecionadaValida = safras.any((s) => s == safraSelecionada);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titulo != null) ...[
              Text(
                titulo!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppCores.verdePrimario),
              ),
              const SizedBox(height: 8),
            ],
            if (subtitulo != null) ...[
              Text(subtitulo!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
            ],
            DropdownButtonFormField<Safra>(
              initialValue: temSafraSelecionadaValida ? safraSelecionada : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppCores.verdePrimario, width: 2),
                ),
                labelStyle: const TextStyle(color: AppCores.verdePrimario),
                floatingLabelStyle: const TextStyle(color: AppCores.verdePrimario),
                labelText: 'Safra selecionada',
              ),
              selectedItemBuilder: (context) {
                return safrasEmOrdem.map((safra) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      safra.nomeComSituacao,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              items: safrasEmOrdem
                  .map(
                    (safra) => DropdownMenuItem<Safra>(
                      value: safra,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(safra.nomeExibicao),
                          ),
                          if (safra.encerrada)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text('Encerrada', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            )
                          else
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppCores.verdeSecundario.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text('Ativa', style: TextStyle(fontSize: 11, color: AppCores.verdePrimario)),
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: safras.isEmpty
                  ? null
                  : (Safra? safra) {
                      if (safra != null) {
                        onSelecionar(safra);
                      }
                    },
            ),
            if (mostrarAcoes) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onNovaSafra,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Nova safra'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCores.verdeSecundario,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (safraSelecionada?.encerrada ?? false)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : onReativarSafra,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reativar safra'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppCores.verdePrimario,
                          side: const BorderSide(color: AppCores.verdeSecundario),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    BotaoEncerrar(
                      rotulo: 'Encerrar safra',
                      carregando: isLoading,
                      aoTocar: safraSelecionada == null ? null : onEncerrarSafra,
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
