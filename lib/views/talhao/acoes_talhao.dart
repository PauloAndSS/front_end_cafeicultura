import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';

Future<void> abrirCadastroDeTalhao(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CadastrarTalhaoView()),
  );
}

class AvisoSemTalhao extends StatelessWidget {
  const AvisoSemTalhao({super.key});

  @override
  Widget build(BuildContext context) {
    return CaixaAvisoAtencao(
      mensagem:
          'Registre os talhões da sua propriedade. As atividades que você registra '
          'acontecem neles.',
      acao: TextButton.icon(
        onPressed: () => abrirCadastroDeTalhao(context),
        icon: const Icon(Icons.eco_outlined, size: 18),
        label: const Text('Cadastrar talhão'),
      ),
    );
  }
}
