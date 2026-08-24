import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';

class AtividadesView extends StatelessWidget {
  const AtividadesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: TipoAtividade.values.length,
      child: Column(
        children: [
          BarraDeAbas(
            rolavel: true,
            abas: TipoAtividade.values
                .map((tipo) => Tab(text: tipo.rotulo))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: TipoAtividade.values
                  .map((tipo) => construirTelaAtividade(context, tipo))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
