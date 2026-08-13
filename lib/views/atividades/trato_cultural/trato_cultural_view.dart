import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/status_evento.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/tratos_culturais_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/base/lista_atividades_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/cadastrar_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/detalhes_trato_cultural_view.dart';

class TratoCulturalView extends StatefulWidget {
  const TratoCulturalView({super.key});

  @override
  State<TratoCulturalView> createState() => _TratoCulturalViewState();
}

class _TratoCulturalViewState extends State<TratoCulturalView> {
  final _viewModel = TratosCulturaisViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListaAtividadesView<TratoCultural>(
      viewModel: _viewModel,
      rotuloCadastrar: 'Novo Trato',
      construirMensagemVazia: (status, nomePropriedade) =>
          'Você não tem tratos culturais ${_descricaoDoStatus(status)} '
          'na propriedade "$nomePropriedade".',
      iconeCard: Icons.grass,
      construirTelaCadastro: (_) => const CadastrarTratoCulturalView(),
      construirTelaDetalhes: (_, trato, nomeTalhao) =>
          DetalhesTratoCulturalView(trato: trato, nomeTalhao: nomeTalhao),
    );
  }

  /// Concorda com "tratos culturais", no masculino plural — é por isso que a
  /// frase do estado vazio é montada aqui e não na tela base.
  String _descricaoDoStatus(StatusEvento status) => switch (status) {
        StatusEvento.agendado => 'agendados',
        StatusEvento.emAndamento => 'em andamento',
        StatusEvento.finalizado => 'finalizados',
      };
}
