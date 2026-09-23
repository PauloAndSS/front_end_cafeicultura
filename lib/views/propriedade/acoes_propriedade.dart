import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/cadastrar_propriedade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/estados.dart';

const _iconeSemPropriedade = Icons.holiday_village_outlined;

const _mensagemSemPropriedade =
    'Você ainda não tem uma propriedade cadastrada.\n'
    'Cadastre a primeira para acompanhar safras, talhões e atividades.';

Future<void> abrirCadastroDePropriedade(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CadastrarPropriedadeView()),
  );
}

class _BotaoCadastrarPropriedade extends StatelessWidget {
  const _BotaoCadastrarPropriedade();

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Cadastrar propriedade',
      onPressed: () => abrirCadastroDePropriedade(context),
    );
  }
}

class EstadoSemPropriedade extends StatelessWidget {
  const EstadoSemPropriedade({super.key});

  @override
  Widget build(BuildContext context) {
    return const EstadoVazio(
      icone: _iconeSemPropriedade,
      mensagem: _mensagemSemPropriedade,
      acao: SizedBox(width: 280, child: _BotaoCadastrarPropriedade()),
    );
  }
}

class CartaoSemPropriedade extends StatelessWidget {
  const CartaoSemPropriedade({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartaoVazio(
      icone: _iconeSemPropriedade,
      mensagem: _mensagemSemPropriedade,
      acao: _BotaoCadastrarPropriedade(),
    );
  }
}

class EstadoPropriedadeNaoSelecionada extends StatelessWidget {
  final String mensagem;

  const EstadoPropriedadeNaoSelecionada({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return EstadoVazio(
      icone: _iconeSemPropriedade,
      mensagem: mensagem,
    );
  }
}
