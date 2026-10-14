import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/views/pessoas/cadastrar_pessoa_view.dart';

sealed class ResultadoCadastroPessoa {
  const ResultadoCadastroPessoa();
}

class CadastroCancelado extends ResultadoCadastroPessoa {
  const CadastroCancelado();
}

class PessoaCadastrada extends ResultadoCadastroPessoa {
  final PapelPessoa papel;

  const PessoaCadastrada(this.papel);
}

class CadastradaSemId extends ResultadoCadastroPessoa {
  const CadastradaSemId();
}

String cadastradaSemIdMensagem(TipoPapel papel) =>
    '${papel.titulo} cadastrado, mas o servidor não informou o identificador. '
    'Selecione-o na lista de ${papel.rotuloPlural}.';

Future<ResultadoCadastroPessoa> cadastrarPessoaDoPapel(
  BuildContext context,
  CarregarPessoasMixin catalogoDePessoas,
  TipoPapel papel,
) async {
  final cadastrado = await Navigator.push<PapelPessoa>(
    context,
    MaterialPageRoute(builder: (_) => CadastrarPessoaView(papel: papel)),
  );

  if (cadastrado == null) return const CadastroCancelado();

  if (cadastrado.id == null) {
    await catalogoDePessoas.carregarCategoria(papel, recarregar: true);
    return const CadastradaSemId();
  }

  catalogoDePessoas.incluirCadastrada(papel, cadastrado);

  return PessoaCadastrada(cadastrado);
}
