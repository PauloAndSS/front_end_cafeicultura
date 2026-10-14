import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

Future<DateTime?> selecionarMesAno({
  required BuildContext context,
  required DateTime inicial,
  required DateTime minimo,
  required DateTime maximo,
  String titulo = 'Escolher mês',
}) {
  final primeiro = inicioDoMes(minimo);
  final ultimoInformado = inicioDoMes(maximo);
  final ultimo = ultimoInformado.isBefore(primeiro) ? primeiro : ultimoInformado;

  return showDialog<DateTime>(
    context: context,
    builder: (context) => _DialogoMesAno(
      inicial: inicioDoMes(inicial),
      primeiro: primeiro,
      ultimo: ultimo,
      titulo: titulo,
    ),
  );
}

class _DialogoMesAno extends StatefulWidget {
  final DateTime inicial;
  final DateTime primeiro;
  final DateTime ultimo;
  final String titulo;

  const _DialogoMesAno({
    required this.inicial,
    required this.primeiro,
    required this.ultimo,
    required this.titulo,
  });

  @override
  State<_DialogoMesAno> createState() => _DialogoMesAnoState();
}

class _DialogoMesAnoState extends State<_DialogoMesAno> {
  late int _ano = widget.inicial.year.clamp(
    widget.primeiro.year,
    widget.ultimo.year,
  );

  bool get _podeVoltarAno => _ano > widget.primeiro.year;
  bool get _podeAvancarAno => _ano < widget.ultimo.year;

  bool _disponivel(DateTime mes) =>
      !mes.isBefore(widget.primeiro) && !mes.isAfter(widget.ultimo);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppCores.superficie,
      title: Text(
        widget.titulo,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          child: const Text('Cancelar', style: TextStyle(color: AppCores.textoSecundario)),
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
          color: AppCores.acao,
        ),
        Text(
          '$_ano',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppCores.textoPrimario,
          ),
        ),
        IconButton(
          onPressed: _podeAvancarAno ? () => setState(() => _ano++) : null,
          icon: const Icon(Icons.chevron_right),
          color: AppCores.acao,
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
        final mes = DateTime(_ano, indice + 1);

        return _construirBotaoDeMes(
          mes: mes,
          selecionado: mes == widget.inicial,
          disponivel: _disponivel(mes),
        );
      }),
    );
  }

  Widget _construirBotaoDeMes({
    required DateTime mes,
    required bool selecionado,
    required bool disponivel,
  }) {
    final rotulo = formatarMesAbreviado(mes);

    return Material(
      color: selecionado ? AppCores.acao : AppCores.fundo,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: disponivel ? () => Navigator.pop(context, mes) : null,
        child: Center(
          child: Text(
            rotulo,
            style: TextStyle(
              color: _corDoRotulo(selecionado: selecionado, disponivel: disponivel),
              fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Color _corDoRotulo({required bool selecionado, required bool disponivel}) {
    if (selecionado) return AppCores.sobreAcao;
    if (!disponivel) return AppCores.textoInativo;
    return AppCores.textoPrimario;
  }
}
