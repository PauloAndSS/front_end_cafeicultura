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

class PessoaLocalizada extends ResultadoCadastroPessoa {
  final PapelPessoa papel;

  const PessoaLocalizada(this.papel);
}

class SalvaSemLocalizar extends ResultadoCadastroPessoa {
  final String mensagem;

  const SalvaSemLocalizar(this.mensagem);
}

Future<ResultadoCadastroPessoa> cadastrarPessoaDoPapel(
  BuildContext context,
  CarregarPessoasMixin catalogoDePessoas,
  TipoPapel papel,
) async {
  final montado = await Navigator.push<PapelPessoa>(
    context,
    MaterialPageRoute(builder: (_) => CadastrarPessoaView(papel: papel)),
  );

  if (montado == null) return const CadastroCancelado();

  await catalogoDePessoas.carregarCategoria(papel, recarregar: true);

  final localizado = catalogoDePessoas.localizarPorDocumento(
    papel,
    montado.pessoa.documentoFormatado,
  );

  if (localizado != null) return PessoaLocalizada(localizado);

  return SalvaSemLocalizar(
    catalogoDePessoas.mensagemErroDe(papel) ??
        'A lista de ${papel.rotuloPlural} não pôde ser atualizada.',
  );
}
