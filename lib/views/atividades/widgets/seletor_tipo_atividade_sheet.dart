import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/registro_atividades.dart';
import 'package:frond_end_cafeicultura_mobile/views/atividades/tipo_atividade.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/modal_selecao.dart';

Future<TipoAtividade?> mostrarSelecaoTipoAtividade({
  required BuildContext context,
}) {
  return mostrarPainelModal<TipoAtividade>(
    context: context,
    alturaLivre: false,
    construir: (context) => const _PainelTiposDeCadastro(),
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
          const AlcaDoPainel(),
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
          ...tiposComCadastro.map(
            (tipo) => ListTile(
              leading: Icon(tipo.icone, color: AppCores.verdePrimario),
              title: Text(
                tipo.rotuloSingular,
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
