/// Os tipos de atividade agrícola que o app conhece.
///
/// Não vai nem vem da API — dirige as abas e o seletor de atividade do talhão.
/// Quais deles já têm tela é responsabilidade do registro em
/// `views/home/atividades/registro_atividades.dart`, e não de um flag aqui:
/// um `bool` no enum é estado de UI dentro do model, e viraria fonte de
/// verdade duplicada assim que houvesse mais de uma tela.
enum TipoAtividade {
  tratosCulturais('Tratos Culturais'),
  colheitas('Colheitas'),
  preSecagens('Pré-Secagens'),
  despolpagens('Despolpagens'),
  fermentacoes('Fermentações'),
  secagens('Secagens'),
  pilagens('Pilagens');

  const TipoAtividade(this.rotulo);

  final String rotulo;
}
