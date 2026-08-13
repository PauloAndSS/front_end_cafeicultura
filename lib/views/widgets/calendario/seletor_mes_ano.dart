import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _verdePrimario = Color(0xFF67835C);

/// Escolha de mês e ano, para pular direto a um período distante.
///
/// Não é um `showDatePicker`: aquele obrigaria a escolher também um dia, que
/// não tem significado nenhum aqui — o calendário só precisa saber que mês
/// desenhar. Devolve o dia 1º do mês escolhido, ou `null` se cancelar.
Future<DateTime?> selecionarMesAno({
  required BuildContext context,
  required DateTime inicial,
  required DateTime primeiroAno,
  required DateTime ultimoAno,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => _DialogoMesAno(
      inicial: inicial,
      anoMinimo: primeiroAno.year,
      anoMaximo: ultimoAno.year,
    ),
  );
}

class _DialogoMesAno extends StatefulWidget {
  final DateTime inicial;
  final int anoMinimo;
  final int anoMaximo;

  const _DialogoMesAno({
    required this.inicial,
    required this.anoMinimo,
    required this.anoMaximo,
  });

  @override
  State<_DialogoMesAno> createState() => _DialogoMesAnoState();
}

class _DialogoMesAnoState extends State<_DialogoMesAno> {
  late int _ano = widget.inicial.year;

  /// "jan", "fev"... Sempre em pt-BR: o calendário inteiro é dessa localidade,
  /// e depender do locale do dispositivo faria o diálogo divergir do cabeçalho
  /// logo acima dele.
  static final _nomeDoMes = DateFormat.MMM('pt_BR');

  bool get _podeVoltarAno => _ano > widget.anoMinimo;
  bool get _podeAvancarAno => _ano < widget.anoMaximo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Escolher mês',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _construirSeletorDeAno(),
            const SizedBox(height: 16),
            _construirGradeDeMeses(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _construirSeletorDeAno() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _podeVoltarAno ? () => setState(() => _ano--) : null,
          icon: const Icon(Icons.chevron_left),
          color: _verdePrimario,
        ),
        Text(
          '$_ano',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: _podeAvancarAno ? () => setState(() => _ano++) : null,
          icon: const Icon(Icons.chevron_right),
          color: _verdePrimario,
        ),
      ],
    );
  }

  Widget _construirGradeDeMeses() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 2.1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(12, (indice) {
        final mes = indice + 1;
        final selecionado =
            mes == widget.inicial.month && _ano == widget.inicial.year;

        return _construirBotaoDeMes(mes: mes, selecionado: selecionado);
      }),
    );
  }

  Widget _construirBotaoDeMes({required int mes, required bool selecionado}) {
    final rotulo = _nomeDoMes.format(DateTime(_ano, mes));

    return Material(
      color: selecionado ? _verdePrimario : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pop(context, DateTime(_ano, mes)),
        child: Center(
          child: Text(
            rotulo,
            style: TextStyle(
              color: selecionado ? Colors.white : Colors.black87,
              fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
