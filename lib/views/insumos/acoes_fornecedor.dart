import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/acoes_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/caixa_aviso.dart';

const semFornecedorMensagem =
    'Nenhum fornecedor cadastrado. A compra precisa de um fornecedor.';

Future<bool> cadastrarFornecedor(
  BuildContext context,
  CarregarPessoasMixin catalogoDePessoas,
) {
  return cadastrarPessoaDoPapel(
    context,
    catalogoDePessoas,
    TipoPapel.fornecedor,
  );
}

class AvisoSemFornecedor extends StatelessWidget {
  final VoidCallback? aoCadastrar;

  const AvisoSemFornecedor({super.key, required this.aoCadastrar});

  @override
  Widget build(BuildContext context) {
    return CaixaAvisoAtencao(
      mensagem: semFornecedorMensagem,
      acao: TextButton.icon(
        onPressed: aoCadastrar,
        icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
        label: const Text('Cadastrar fornecedor'),
      ),
    );
  }
}
