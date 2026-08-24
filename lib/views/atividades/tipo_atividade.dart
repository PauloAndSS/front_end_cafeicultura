import 'package:flutter/material.dart';

enum TipoAtividade {
  tratosCulturais('Tratos Culturais', 'Trato cultural', Icons.grass),
  colheitas('Colheitas', 'Colheita', Icons.agriculture),
  preSecagens('Pré-Secagens', 'Pré-secagem', Icons.wb_twilight),
  despolpagens('Despolpagens', 'Despolpagem', Icons.water_drop_outlined),
  fermentacoes('Fermentações', 'Fermentação', Icons.science_outlined),
  secagens('Secagens', 'Secagem', Icons.wb_sunny_outlined),
  pilagens('Pilagens', 'Pilagem', Icons.grain);

  const TipoAtividade(this.rotulo, this.rotuloSingular, this.icone);

  final String rotulo;

  final String rotuloSingular;

  final IconData icone;
}
