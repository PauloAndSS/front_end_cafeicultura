import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/trato_cultural/cadastrar_trato_cultural_view.dart';

const _verdePrimario = Color(0xFF67835C);
const _cinzaBorda = Color(0xFFE0E0E0);

/// Um tipo de atividade que pode ser lançado a partir do calendário geral.
class TipoCadastroAtividade {
  final String rotulo;
  final IconData icone;

  /// A data vem do dia tocado no calendário e chega ao formulário já
  /// preenchida. É nula quando o cadastro é aberto sem dia de origem.
  final Widget Function(DateTime? dataInicial) construirTela;

  const TipoCadastroAtividade({
    required this.rotulo,
    required this.icone,
    required this.construirTela,
  });
}

/// Catálogo do que a home consegue cadastrar hoje.
///
/// Existe um item só, e ainda assim o seletor é exibido: a home é a visão de
/// todos os módulos, e entrar direto no trato cultural ensinaria ao usuário um
/// caminho que muda de destino quando o segundo módulo entrar. Colheita e os
/// demais entram aqui — é o único ponto a editar.
final List<TipoCadastroAtividade> tiposDeCadastroDisponiveis = [
  TipoCadastroAtividade(
    rotulo: 'Trato cultural',
    icone: Icons.grass,
    construirTela: (dataInicial) =>
        CadastrarTratoCulturalView(dataInicial: dataInicial),
  ),
];

/// Pergunta que tipo de atividade cadastrar. Devolve `null` se o usuário fechar
/// o painel sem escolher.
Future<TipoCadastroAtividade?> mostrarSelecaoTipoAtividade({
  required BuildContext context,
}) {
  return showModalBottomSheet<TipoCadastroAtividade>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _PainelTiposDeCadastro(),
  );
}

class _PainelTiposDeCadastro extends StatelessWidget {
  const _PainelTiposDeCadastro();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: _cinzaBorda,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'O que deseja cadastrar?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          ...tiposDeCadastroDisponiveis.map(
            (tipo) => ListTile(
              leading: Icon(tipo.icone, color: _verdePrimario),
              title: Text(
                tipo.rotulo,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black26),
              onTap: () => Navigator.pop(context, tipo),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
