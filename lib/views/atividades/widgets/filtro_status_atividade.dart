import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/status_evento.dart';

/// Alternador entre os status de atividade.
///
/// Usado tanto nas abas de atividade quanto na seção de atividades do detalhe
/// do talhão — o estado da seleção fica com quem usa.
///
/// Filtra pelo mesmo [StatusEvento] que o model calcula: um enum próprio de
/// filtro seria a mesma regra escrita duas vezes. `null` é o segmento "Todas",
/// que a seção do talhão oferece e a aba não: lá o filtro é opcional na rota, e
/// ausência de `status` na query é literalmente "sem filtro".
///
/// Sem os ícones que existiam quando eram dois segmentos: com três rótulos,
/// ícone mais texto não cabe na largura de um telefone comum. Com quatro, nem o
/// texto inteiro cabe — daí os rótulos curtos e o padding menor a partir do
/// quarto segmento.
class FiltroStatusAtividade extends StatelessWidget {
  final StatusEvento? selecionado;
  final ValueChanged<StatusEvento?> onSelecionar;

  /// Os segmentos, na ordem. `StatusEvento.values` (o padrão) é uma
  /// `List<StatusEvento>`, que serve de `List<StatusEvento?>` por covariância.
  final List<StatusEvento?> filtros;

  const FiltroStatusAtividade({
    super.key,
    required this.selecionado,
    required this.onSelecionar,
    this.filtros = StatusEvento.values,
  });

  /// A partir de quatro segmentos o texto longo não cabe mais.
  bool get _apertado => filtros.length > 3;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatusEvento?>(
      showSelectedIcon: false,
      segments: filtros.map((status) {
        return ButtonSegment<StatusEvento?>(
          value: status,
          label: Text(
            rotuloDeFiltro(status, curto: _apertado),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
      selected: {selecionado},
      onSelectionChanged: (Set<StatusEvento?> novaSelecao) {
        onSelecionar(novaSelecao.first);
      },
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: _apertado ? 12 : 13),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: _apertado ? 4 : 8),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF67835C);
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.black87;
        }),
      ),
    );
  }
}
