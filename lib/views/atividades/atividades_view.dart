import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/reinicio_de_secao.dart';

class AtividadesView extends StatefulWidget {
  const AtividadesView({super.key});

  @override
  State<AtividadesView> createState() => _AtividadesViewState();
}

class _AtividadesViewState extends State<AtividadesView>
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin,
        ReinicioDeSecaoMixin {
  late final TabController _abas;

  @override
  bool get wantKeepAlive => true;

  @override
  SecaoPrincipal get secaoDoReinicio => SecaoPrincipal.atividades;

  @override
  void aoReiniciarSecao() {
    _abas.index = 0;
  }

  @override
  void initState() {
    super.initState();
    _abas = TabController(length: TipoAtividade.values.length, vsync: this);
  }

  @override
  void dispose() {
    _abas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    observarReinicioDeSecao(context);

    return Column(
      children: [
        BarraDeAbas(
          controller: _abas,
          rolavel: true,
          abas: TipoAtividade.values
              .map((tipo) => Tab(text: tipo.rotulo))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _abas,
            physics: const NeverScrollableScrollPhysics(),
            children: TipoAtividade.values
                .map((tipo) => construirTelaAtividade(context, tipo))
                .toList(),
          ),
        ),
      ],
    );
  }
}
