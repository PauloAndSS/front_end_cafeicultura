import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/utils/datas.dart';
import 'package:frond_end_cafeicultura_mobile/utils/formatadores.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/base/detalhes_atividade_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/seletor_data_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';

const _verdePrimario = Color(0xFF67835C);
const _vermelhoErro = Color(0xFFD32F2F);

/// Confirmação de uma atividade agrícola: fecha a atividade escolhendo a data
/// de término e, se preciso, corrigindo a de início.
///
/// É tela, e não o par picker + `AlertDialog` que existia antes, porque são
/// dois calendários que conversam entre si — o término não pode anteceder o
/// início, e mexer no início invalida um término já escolhido. Num diálogo o
/// usuário não vê as duas datas ao mesmo tempo para conferir.
///
/// Só as datas entram aqui. Descrição, responsáveis e insumos continuam
/// editáveis campo a campo no detalhe, que é onde eles moram.
class ConfirmarAtividadeView<T extends EventoAgricola>
    extends StatefulWidget {
  final DetalhesAtividadeViewModel<T> viewModel;
  final String nomeTalhao;

  /// 'Confirmar Trato Cultural' — título da tela.
  final String titulo;

  /// 'Data de início do trato cultural' — cabeçalho do calendário.
  final String ajudaDataInicio;
  final String ajudaDataFim;

  const ConfirmarAtividadeView({
    super.key,
    required this.viewModel,
    required this.nomeTalhao,
    required this.titulo,
    required this.ajudaDataInicio,
    required this.ajudaDataFim,
  });

  @override
  State<ConfirmarAtividadeView<T>> createState() =>
      _ConfirmarAtividadeViewState<T>();
}

class _ConfirmarAtividadeViewState<T extends EventoAgricola>
    extends State<ConfirmarAtividadeView<T>> {
  DetalhesAtividadeViewModel<T> get _viewModel => widget.viewModel;

  /// Já preenchida com a data que a atividade tem: confirmar sem mexer nela é
  /// o caminho comum.
  ///
  /// Passa por [apenasData] porque a data vem do backend em UTC: entregue crua
  /// ao `showDatePicker`, a meia-noite UTC vira o dia anterior no fuso de
  /// Brasília e o calendário abriria um dia atrás do que a tela exibe.
  late DateTime _dataInicio = apenasData(_viewModel.atividade.dataInicio);

  late final _dataInicioController = TextEditingController(
    text: formatarDataBr(_dataInicio),
  );

  DateTime? _dataFim;
  final _dataFimController = TextEditingController();

  @override
  void dispose() {
    _dataInicioController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: _vermelhoErro),
    );
  }

  Future<void> _selecionarDataInicio() async {
    final escolhida = await selecionarDataAtividade(
      context: context,
      ajuda: widget.ajudaDataInicio,
      inicial: _dataInicio,
      // Teto é hoje, e não [limiteAgendamento]: confirmar é registrar o que já
      // aconteceu — um início no futuro contradiria a própria confirmação.
    );

    if (escolhida == null) return;

    setState(() {
      _dataInicio = escolhida;
      _dataInicioController.text = formatarDataBr(escolhida);

      if (_dataFim != null && _dataFim!.isBefore(escolhida)) {
        _dataFim = null;
        _dataFimController.clear();
      }
    });
  }

  Future<void> _selecionarDataFim() async {
    final escolhida = await selecionarDataAtividade(
      context: context,
      ajuda: widget.ajudaDataFim,
      inicial: _dataFim ?? _dataInicio,
      minima: _dataInicio,
    );

    if (escolhida == null) return;

    setState(() {
      _dataFim = escolhida;
      _dataFimController.text = formatarDataBr(escolhida);
    });
  }

  Future<void> _confirmar() async {
    if (_dataFim == null) {
      _mostrarErro('Selecione a data de término.');
      return;
    }

    final sucesso = await _viewModel.confirmar(
      dataInicio: _dataInicio,
      dataFim: _dataFim!,
    );

    if (!mounted) return;

    if (!sucesso) {
      _mostrarErro(
        _viewModel.mensagemErro ?? 'Erro ao confirmar a atividade.',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.titulo, style: const TextStyle(color: Colors.white)),
        backgroundColor: _verdePrimario,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _construirCartao(),
        ),
      ),
    );
  }

  Widget _construirCartao() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _viewModel.atividade.tituloExibicao,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _verdePrimario,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Talhão: ${widget.nomeTalhao}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Divider(height: 32, color: Color(0xFFE0E0E0)),

          _construirCampoData(
            rotulo: 'Data de início',
            controller: _dataInicioController,
            aoTocar: _selecionarDataInicio,
          ),
          _construirCampoData(
            rotulo: 'Data de término',
            controller: _dataFimController,
            dica: 'Selecione a data',
            aoTocar: _selecionarDataFim,
          ),

          const SizedBox(height: 8),
          // Caixa de aviso, e não a linha cinza que estava aqui: confirmar é o
          // ponto sem volta da atividade — descrição, responsáveis, insumos e a
          // própria exclusão saem de cena junto. Em 13px cinza, ao lado de um
          // botão verde, essa consequência passava batida.
          const CaixaAvisoAtencao(
            mensagem: 'Depois de confirmada, a atividade não poderá mais ser '
                'alterada nem excluída — apenas visualizada.',
          ),
          const SizedBox(height: 32),

          CustomButton(
            text: _viewModel.isLoading ? 'Confirmando...' : 'Confirmar',
            onPressed: _viewModel.isLoading ? null : _confirmar,
          ),
        ],
      ),
    );
  }

  Widget _construirCampoData({
    required String rotulo,
    required TextEditingController controller,
    required VoidCallback aoTocar,
    String? dica,
  }) {
    return GestureDetector(
      onTap: aoTocar,
      child: AbsorbPointer(
        child: CustomTextField(
          label: rotulo,
          controller: controller,
          hintText: dica,
          readOnly: true,
        ),
      ),
    );
  }
}
