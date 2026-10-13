import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/pessoas/carregar_pessoas_mixin.dart';

import '../http/mock_http.dart';

class CatalogoDeTeste extends ChangeNotifier
    with NotificaSeVivoMixin, CarregarPessoasMixin {}

Future<CatalogoDeTeste> catalogoCom(
  TipoPapel papel,
  List<Map<String, dynamic>> dados,
) async {
  final catalogo = CatalogoDeTeste();

  await comRespostaFixa(
    () => catalogo.carregarCategoria(papel),
    respostaJson({'dados': dados}, 200),
  );

  return catalogo;
}

PessoaFisica fisicaSemCpf(String nome) => PessoaFisica(nome: nome, cpf: null);

void main() {
  setUp(() => BaseService.sessionCookie = null);

  group('com documento, casa pelo documento', () {
    test('acha a pessoa pelo CPF mesmo com nome diferente', () async {
      final catalogo = await catalogoCom(TipoPapel.cliente, [
        {'id': 1, 'nome': 'Outro Nome', 'cpf': '111.444.777-35'},
        {'id': 2, 'nome': 'Joao', 'cpf': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.cliente,
        PessoaFisica(nome: 'Joao', cpf: CPF.criar('11144477735')),
      );

      expect(achado?.id, 1);
    });

    test('acha a pessoa juridica pelo CNPJ', () async {
      final catalogo = await catalogoCom(TipoPapel.fornecedor, [
        {'id': 7, 'razaoSocial': 'Agro Ltda', 'cnpj': '11.222.333/0001-81'},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.fornecedor,
        PessoaJuridica(
          razaoSocial: 'Agro Ltda',
          cnpj: CNPJ.criar('11222333000181'),
        ),
      );

      expect(achado?.id, 7);
    });

    test('documento ausente da lista nao recai no casamento por nome', () async {
      final catalogo = await catalogoCom(TipoPapel.cliente, [
        {'id': 1, 'nome': 'Joao', 'cpf': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.cliente,
        PessoaFisica(nome: 'Joao', cpf: CPF.criar('11144477735')),
      );

      expect(achado, isNull);
    });
  });

  group('sem documento, casa pelo nome entre quem tambem nao tem', () {
    test('acha a pessoa sem CPF pelo nome', () async {
      final catalogo = await catalogoCom(TipoPapel.cliente, [
        {'id': 1, 'nome': 'Maria', 'cpf': null},
        {'id': 2, 'nome': 'Joao', 'cpf': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.cliente,
        fisicaSemCpf('Joao'),
      );

      expect(achado?.id, 2);
    });

    test('entre homonimos sem documento fica com o maior id', () async {
      final catalogo = await catalogoCom(TipoPapel.cliente, [
        {'id': 9, 'nome': 'Joao', 'cpf': null},
        {'id': 15, 'nome': 'Joao', 'cpf': null},
        {'id': 12, 'nome': 'Joao', 'cpf': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.cliente,
        fisicaSemCpf('Joao'),
      );

      expect(achado?.id, 15);
    });

    test('homonimo com documento nao e confundido com o recem-cadastrado',
        () async {
      final catalogo = await catalogoCom(TipoPapel.cliente, [
        {'id': 30, 'nome': 'Joao', 'cpf': '111.444.777-35'},
        {'id': 4, 'nome': 'Joao', 'cpf': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.cliente,
        fisicaSemCpf('Joao'),
      );

      expect(achado?.id, 4);
    });

    test('ignora caixa e espacos nas pontas do nome', () async {
      final catalogo = await catalogoCom(TipoPapel.cliente, [
        {'id': 3, 'nome': 'JOAO DA SILVA', 'cpf': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.cliente,
        fisicaSemCpf('  joao da silva '),
      );

      expect(achado?.id, 3);
    });

    test('pessoa juridica sem CNPJ casa pela razao social', () async {
      final catalogo = await catalogoCom(TipoPapel.fornecedor, [
        {'id': 5, 'razaoSocial': 'Agro Ltda', 'cnpj': null},
        {'id': 6, 'razaoSocial': 'Outra Ltda', 'cnpj': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.fornecedor,
        PessoaJuridica(razaoSocial: 'Agro Ltda', cnpj: null),
      );

      expect(achado?.id, 5);
    });

    test('nome ausente da lista devolve nulo', () async {
      final catalogo = await catalogoCom(TipoPapel.cliente, [
        {'id': 1, 'nome': 'Maria', 'cpf': null},
      ]);

      final achado = catalogo.localizarRecemCadastrada(
        TipoPapel.cliente,
        fisicaSemCpf('Joao'),
      );

      expect(achado, isNull);
    });
  });

  test('a busca fica restrita a categoria pedida', () async {
    final catalogo = await catalogoCom(TipoPapel.cliente, [
      {'id': 1, 'nome': 'Joao', 'cpf': null},
    ]);

    final Pessoa joao = fisicaSemCpf('Joao');

    expect(catalogo.localizarRecemCadastrada(TipoPapel.cliente, joao)?.id, 1);
    expect(catalogo.localizarRecemCadastrada(TipoPapel.meeiro, joao), isNull);
  });
}
