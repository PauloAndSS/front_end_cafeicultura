import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/home/atividades/registro_atividades.dart';

/// Aba de atividades: uma guia por [TipoAtividade].
///
/// Quem decide o que cada guia mostra é o `registro_atividades.dart` — os tipos
/// ausentes do registro caem no placeholder de "em desenvolvimento".
class AtividadesView extends StatelessWidget {
  const AtividadesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: TipoAtividade.values.length,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFF67835C),
              labelColor: const Color(0xFF67835C),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: TipoAtividade.values
                  .map((tipo) => Tab(text: tipo.rotulo))
                  .toList(),
            ),
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
