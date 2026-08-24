import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/tratos_culturais/trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/evento.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/trato_cultural/agenda_tratos_culturais_viewmodel.dart';
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
  final _agendaViewModel = AgendaTratosCulturaisViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    _agendaViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListaAtividadesView<TratoCultural>(
      viewModel: _viewModel,
      agendaViewModel: _agendaViewModel,
      rotuloCadastrar: 'Novo Trato',
      construirMensagemVazia: (status, nomePropriedade) =>
          'Você não tem tratos culturais ${_descricaoDoStatus(status)} '
          'na propriedade "$nomePropriedade".',
      iconeCard: Icons.grass,
      construirTelaCadastro: (_, dataInicial) =>
          CadastrarTratoCulturalView(dataInicial: dataInicial),
      construirTelaDetalhes: (_, trato, talhao) =>
          DetalhesTratoCulturalView(trato: trato, talhao: talhao),
    );
  }
  String _descricaoDoStatus(StatusEvento status) => switch (status) {
        StatusEvento.agendado => 'agendados',
        StatusEvento.emAndamento => 'em andamento',
        StatusEvento.finalizado => 'finalizados',
      };
}
