import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/cadastrar_propriedade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

Future<void> abrirCadastroDePropriedade(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CadastrarPropriedadeView()),
  );
}

class EstadoSemPropriedade extends StatelessWidget {
  const EstadoSemPropriedade({super.key});

  @override
  Widget build(BuildContext context) {
    return EstadoVazio(
      icone: Icons.holiday_village_outlined,
      mensagem:
          'Você ainda não tem uma propriedade cadastrada.\n'
          'Cadastre a primeira para acompanhar safras, talhões e atividades.',
      acao: SizedBox(
        width: 280,
        child: CustomButton(
          text: 'Cadastrar propriedade',
          onPressed: () => abrirCadastroDePropriedade(context),
        ),
      ),
    );
  }
}

class EstadoPropriedadeNaoSelecionada extends StatelessWidget {
  final String mensagem;

  const EstadoPropriedadeNaoSelecionada({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return EstadoVazio(
      icone: Icons.holiday_village_outlined,
      mensagem: mensagem,
    );
  }
}
