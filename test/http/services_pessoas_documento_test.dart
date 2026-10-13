import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/fornecedor.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:http/http.dart' as http;

import 'mock_http.dart';

Future<Map<String, dynamic>> corpoEnviadoAo(
  Future<bool> Function() cadastrar,
) async {
  late http.Request enviada;

  await comRespostaFixa(
    cadastrar,
    respostaJson({'mensagem': 'ok'}, 201),
    capturar: (requisicao) => enviada = requisicao,
  );

  return jsonDecode(enviada.body) as Map<String, dynamic>;
}

void main() {
  setUp(() => BaseService.sessionCookie = null);

  group('cadastrar papel sem documento', () {
    test('pessoa fisica sem CPF vai sem a chave cpf', () async {
      final corpo = await corpoEnviadoAo(
        () => ServicesCliente().cadastrar(
          Cliente(pessoa: PessoaFisica(nome: 'Joao', cpf: null)),
        ),
      );

      expect(corpo.containsKey('cpf'), isFalse);
      expect(corpo['nome'], 'Joao');
      expect(corpo['tipoPessoa'], 'fisica');
    });

    test('pessoa juridica sem CNPJ vai sem a chave cnpj', () async {
      final corpo = await corpoEnviadoAo(
        () => ServicesFornecedor().cadastrar(
          Fornecedor(
            pessoa: PessoaJuridica(razaoSocial: 'Agro Ltda', cnpj: null),
          ),
        ),
      );

      expect(corpo.containsKey('cnpj'), isFalse);
      expect(corpo['razaoSocial'], 'Agro Ltda');
      expect(corpo['tipoPessoa'], 'juridica');
    });

    test('com documento, o CPF segue mascarado no corpo', () async {
      final corpo = await corpoEnviadoAo(
        () => ServicesCliente().cadastrar(
          Cliente(
            pessoa: PessoaFisica(nome: 'Joao', cpf: CPF.criar('11144477735')),
          ),
        ),
      );

      expect(corpo['cpf'], '111.444.777-35');
    });
  });

  group('listar papel com pessoa sem documento', () {
    test('a categoria carrega inteira, com e sem documento', () async {
      final clientes = await comRespostaFixa(
        () => ServicesCliente().listar(),
        respostaJson({
          'dados': [
            {'id': 1, 'nome': 'Com CPF', 'cpf': '111.444.777-35'},
            {'id': 2, 'nome': 'Sem CPF', 'cpf': null},
            {
              'id': 3,
              'razaoSocial': 'Sem CNPJ Ltda',
              'cnpj': null,
              'inscrEstadual': null,
            },
          ],
        }, 200),
      );

      expect(clientes.map((cliente) => cliente.id), [1, 2, 3]);
      expect(clientes[0].pessoa.documentoParaExibicao, '111.444.777-35');
      expect(clientes[1].pessoa.documentoParaExibicao, 'CPF não informado');
      expect(clientes[2].pessoa, isA<PessoaJuridica>());
      expect(clientes[2].pessoa.nomeParaExibicao, 'Sem CNPJ Ltda');
      expect(clientes[2].pessoa.documentoParaExibicao, 'CNPJ não informado');
    });
  });
}
