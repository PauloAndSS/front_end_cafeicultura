import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/cadastrar_trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/trato_cultural_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/widgets/atividade_em_desenvolvimento.dart';

class RegistroAtividade {
  final WidgetBuilder construirListagem;

  final Widget Function(DateTime? dataInicial)? construirCadastro;

  const RegistroAtividade({
    required this.construirListagem,
    this.construirCadastro,
  });
}

const Map<TipoAtividade, RegistroAtividade> registroAtividades = {
  TipoAtividade.tratosCulturais: RegistroAtividade(
    construirListagem: _listagemTratoCultural,
    construirCadastro: _cadastroTratoCultural,
  ),
};

Widget _listagemTratoCultural(BuildContext context) =>
    const TratoCulturalView();

Widget _cadastroTratoCultural(DateTime? dataInicial) =>
    CadastrarTratoCulturalView(dataInicial: dataInicial);

bool atividadeImplementada(TipoAtividade tipo) =>
    registroAtividades.containsKey(tipo);

Widget construirTelaAtividade(BuildContext context, TipoAtividade tipo) {
  final registro = registroAtividades[tipo];

  if (registro == null) return AtividadeEmDesenvolvimento(tipo: tipo);

  return registro.construirListagem(context);
}

Iterable<TipoAtividade> get tiposComCadastro => registroAtividades.entries
    .where((entrada) => entrada.value.construirCadastro != null)
    .map((entrada) => entrada.key);

Widget construirCadastroAtividade(TipoAtividade tipo, DateTime? dataInicial) =>
    registroAtividades[tipo]!.construirCadastro!(dataInicial);
