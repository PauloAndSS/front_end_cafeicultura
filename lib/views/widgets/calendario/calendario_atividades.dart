import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatacao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/calendario/seletor_mes_ano.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

const _anosDeMargem = 5;

class CalendarioAtividades<T extends Evento> extends StatefulWidget {
  final List<T> atividades;
  final DateTime? diaSelecionado;

  final DateTime? mesInicial;

  final void Function(DateTime primeiroDiaDoMes)? aoMudarMes;

  final void Function(DateTime dia, List<T> doDia) aoSelecionarDia;

  final bool carregando;

  final Color Function(T atividade)? corDoMarcador;

  const CalendarioAtividades({
    super.key,
    required this.atividades,
    required this.aoSelecionarDia,
    this.diaSelecionado,
    this.mesInicial,
    this.aoMudarMes,
    this.carregando = false,
    this.corDoMarcador,
  });

  @override
  State<CalendarioAtividades<T>> createState() =>
      _CalendarioAtividadesState<T>();
}

class _CalendarioAtividadesState<T extends Evento>
    extends State<CalendarioAtividades<T>> {

  late DateTime _diaFocado = widget.mesInicial ?? hoje();

  late Map<DateTime, List<T>> _porDia = _agruparPorDia(widget.atividades);

  @override
  void didUpdateWidget(covariant CalendarioAtividades<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.atividades, widget.atividades)) {
      _porDia = _agruparPorDia(widget.atividades);
    }
  }

  Map<DateTime, List<T>> _agruparPorDia(List<T> atividades) {
    final agrupadas = <DateTime, List<T>>{};

    for (final atividade in atividades) {
      agrupadas
          .putIfAbsent(apenasData(atividade.dataInicio), () => <T>[])
          .add(atividade);
    }

    return agrupadas;
  }

  List<T> _doDia(DateTime dia) => _porDia[apenasData(dia)] ?? const [];

  DateTime get _primeiroDia => DateTime(hoje().year - _anosDeMargem, 1, 1);
  DateTime get _ultimoDia => DateTime(hoje().year + _anosDeMargem, 12, 31);

  Future<void> _abrirSeletorDeMes() async {
    final escolhido = await selecionarMesAno(
      context: context,
      inicial: _diaFocado,
      primeiroAno: _primeiroDia,
      ultimoAno: _ultimoDia,
    );

    if (escolhido == null || !mounted) return;

    setState(() => _diaFocado = escolhido);
    widget.aoMudarMes?.call(escolhido);
  }

  void _aoTrocarPagina(DateTime focado) {
    final mudouDeMes =
        focado.year != _diaFocado.year || focado.month != _diaFocado.month;

    _diaFocado = focado;

    if (mudouDeMes) {
      widget.aoMudarMes?.call(DateTime(focado.year, focado.month));
    }
  }

  void _aoSelecionarDia(DateTime selecionado, DateTime focado) {
    setState(() => _diaFocado = focado);

    widget.aoSelecionarDia(selecionado, _doDia(selecionado));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: _construirCalendario(),
    );
  }

  Widget _construirCalendario() {
    return TableCalendar<T>(
      locale: 'pt_BR',
      focusedDay: _diaFocado,
      firstDay: _primeiroDia,
      lastDay: _ultimoDia,
      calendarFormat: CalendarFormat.month,

      availableCalendarFormats: const {CalendarFormat.month: ''},

      availableGestures: AvailableGestures.horizontalSwipe,

      startingDayOfWeek: StartingDayOfWeek.sunday,
      eventLoader: _doDia,
      selectedDayPredicate: (dia) => isSameDay(widget.diaSelecionado, dia),
      onDaySelected: _aoSelecionarDia,
      onPageChanged: _aoTrocarPagina,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        headerPadding: EdgeInsets.symmetric(vertical: 12),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppCores.verdePrimario),
        rightChevronIcon: Icon(Icons.chevron_right, color: AppCores.verdePrimario),
      ),
      calendarBuilders: CalendarBuilders<T>(
        headerTitleBuilder: _construirTitulo,
        singleMarkerBuilder: _construirMarcador,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.black54, fontSize: 12),
        weekendStyle: TextStyle(color: Colors.black38, fontSize: 12),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        markersMaxCount: 4,
        markerSize: 6,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        todayDecoration: const BoxDecoration(
          color: AppCores.verdeSecundario,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppCores.verdePrimario,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _construirTitulo(BuildContext context, DateTime mes) {
    final titulo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatarMesAnoExtenso(mes),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: AppCores.verdePrimario),
        if (widget.carregando) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppCores.verdePrimario,
            ),
          ),
        ],
      ],
    );

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _abrirSeletorDeMes,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: titulo,
        ),
      ),
    );
  }

  Widget? _construirMarcador(BuildContext context, DateTime dia, T atividade) {
    final cor = widget.corDoMarcador?.call(atividade) ?? AppCores.verdePrimario;

    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
    );
  }
}
