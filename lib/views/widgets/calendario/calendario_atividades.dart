import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/calendario/seletor_mes_ano.dart';
import 'package:table_calendar/table_calendar.dart';

const _verdePrimario = Color(0xFF67835C);
const _verdeSecundario = Color(0xFF8FA67E);

/// Até onde o calendário deixa navegar. Não é regra de negócio — é só um teto
/// para a rolagem não ser infinita, do mesmo tamanho do que o agendamento de
/// atividade já usa.
const _anosDeMargem = 5;

/// Calendário mensal de atividades.
///
/// **Só mês.** Semana e quinzena existiram e saíram: o marcador é um ponto
/// colorido, não um horário, então períodos mais curtos mostravam a mesma
/// informação com mais espaço em branco — e o seletor de amplitude custava uma
/// linha inteira do card para oferecer uma escolha que não mudava nada.
///
/// **Não busca nada.** Recebe as atividades já carregadas e avisa, por
/// [aoMudarMes], quando o usuário navegou para outro mês — é quem usa que decide
/// se isso vira requisição. Foi assim, e não com um ViewModel embutido, para o
/// mesmo widget servir à home (que carrega da rota de eventos gerais) e às abas
/// de atividade (que já têm a coleção inteira em memória e não buscam nada).
///
/// O pacote que desenha a grade fica contido neste arquivo: quem monta o
/// calendário fala em [Evento] e [DateTime], não em `CalendarFormat`.
class CalendarioAtividades<T extends Evento> extends StatefulWidget {
  /// Atividades do período já carregado. Trocar esta lista redesenha os
  /// marcadores.
  final List<T> atividades;

  /// Dia destacado na grade.
  ///
  /// Controlado por quem usa, e não guardado aqui dentro, porque limpar a
  /// seleção é decisão de fora: a aba de atividade zera o dia ao mudar de mês
  /// para a lista abaixo da grade não continuar presa a um dia que saiu de
  /// vista.
  final DateTime? diaSelecionado;

  /// Mês em que a grade abre. `null` abre no corrente.
  ///
  /// Serve para quem precisa sobreviver a uma remontagem: se a tela troca o
  /// calendário por um spinner durante uma recarga, sem isto a grade volta para
  /// hoje e desencontra do resto da tela, que continua no mês de antes.
  final DateTime? mesInicial;

  /// Chamado quando o mês visível muda — por seta, por swipe ou pelo seletor de
  /// mês.
  final void Function(DateTime primeiroDiaDoMes)? aoMudarMes;

  /// Toque num dia, com as atividades daquele dia já filtradas.
  final void Function(DateTime dia, List<T> doDia) aoSelecionarDia;

  /// Mostra um indicador fino no cabeçalho, sem apagar a grade. Substituir o
  /// calendário inteiro por um spinner faria a tela piscar a cada troca de mês.
  final bool carregando;

  /// Cor do marcador de cada atividade. Injetada em vez de importada porque a
  /// regra de cor mora no domínio de atividades, e este widget não depende
  /// dele.
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
  /// Abre em hoje quando ninguém disse o contrário — é o que faz o mês corrente
  /// ser o padrão.
  ///
  /// Segue privado mesmo com o dia selecionado tendo subido para quem usa: isto
  /// aqui é a página visível, não a seleção. Rolar o mês sem tocar em dia
  /// nenhum muda este campo e não muda aquele.
  late DateTime _diaFocado = widget.mesInicial ?? hoje();

  /// Atividades indexadas pelo dia em que começam.
  late Map<DateTime, List<T>> _porDia = _agruparPorDia(widget.atividades);

  @override
  void didUpdateWidget(covariant CalendarioAtividades<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.atividades, widget.atividades)) {
      _porDia = _agruparPorDia(widget.atividades);
    }
  }

  /// Agrupa pela **data de início**, que é a única data que toda atividade tem:
  /// a de término só existe depois de finalizada.
  ///
  /// A chave passa por [apenasData] sem `toLocal()` antes. As datas chegam do
  /// backend em UTC, gravadas como meia-noite do dia escolhido; convertidas
  /// para o fuso de Brasília, virariam 21h do dia anterior e a atividade
  /// apareceria um dia cedo.
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

      // Um formato só na lista: o pacote traz o próprio botão de alternância e
      // ele ofereceria semana e quinzena de volta, que é justamente o que saiu.
      availableCalendarFormats: const {CalendarFormat.month: ''},

      // Só arrasto horizontal. O vertical, ligado por padrão, encolhe a grade
      // para semana — o mesmo formato que este calendário não tem mais.
      availableGestures: AvailableGestures.horizontalSwipe,

      startingDayOfWeek: StartingDayOfWeek.sunday,
      eventLoader: _doDia,
      selectedDayPredicate: (dia) => isSameDay(widget.diaSelecionado, dia),
      onDaySelected: _aoSelecionarDia,
      onPageChanged: _aoTrocarPagina,
      // Sem `onHeaderTapped`: o pacote só o liga no título padrão — com
      // `headerTitleBuilder` presente, aquele ramo nunca é construído. O toque
      // mora dentro de `_construirTitulo`.
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        headerPadding: EdgeInsets.symmetric(vertical: 12),
        leftChevronIcon: Icon(Icons.chevron_left, color: _verdePrimario),
        rightChevronIcon: Icon(Icons.chevron_right, color: _verdePrimario),
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
          color: _verdeSecundario,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: _verdePrimario,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }

  /// Título do cabeçalho, que é também o botão do seletor de mês/ano — daí a
  /// seta ao lado do texto.
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
        const Icon(Icons.arrow_drop_down, color: _verdePrimario),
        if (widget.carregando) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _verdePrimario,
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
    final cor = widget.corDoMarcador?.call(atividade) ?? _verdePrimario;

    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
    );
  }
}
