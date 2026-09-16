import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class CadastrarEnderecoViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final _proprietarioService = ServicesProprietario();

  Future<Proprietario?> adicionarEndereco({
    required Proprietario proprietarioLogado,
    required String cepDigitado,
    required String logradouro,
    required String bairro,
    required String cidade,
    required UF uf,
    String? pais,
  }) {
    return cargaPrincipal.executar(
      chamada: () async {
        final enderecoFinal = Endereco(
          cidade: cidade.trim(),
          bairro: bairro.trim(),
          cep: CEP.criar(cepDigitado),
          logradouro: logradouro.trim(),
          uf: uf,
          pais: pais,
        );

        final idProprietario = proprietarioLogado.id;

        if (idProprietario == null) {
          throw Exception('Tentativa de cadastrar endereço em um usuário sem ID.');
        }

        await _proprietarioService.cadastrarEndereco(
          idProprietario: idProprietario,
          endereco: enderecoFinal,
        );

        return Proprietario(
          id: idProprietario,
          email: proprietarioLogado.email,
          telefone: proprietarioLogado.telefone,
          pessoa: _comEndereco(proprietarioLogado.pessoa, enderecoFinal),
        );
      },
      aoFalhar: () => null,
    );
  }

  dynamic _comEndereco(dynamic pessoaAnterior, Endereco endereco) {
    if (pessoaAnterior is PessoaFisica) {
      return PessoaFisica(
        id: pessoaAnterior.id,
        nome: pessoaAnterior.nome,
        cpf: pessoaAnterior.cpf,
        endereco: endereco,
      );
    }

    final juridica = pessoaAnterior as PessoaJuridica;

    return PessoaJuridica(
      id: juridica.id,
      razaoSocial: juridica.razaoSocial,
      cnpj: juridica.cnpj,
      inscricaoEstadual: juridica.inscricaoEstadual,
      endereco: endereco,
    );
  }
}
