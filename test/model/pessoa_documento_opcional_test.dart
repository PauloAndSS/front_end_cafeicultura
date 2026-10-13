import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/cliente.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';

void main() {
  group('criarSeInformado: vazio e ausencia, nunca documento invalido', () {
    test('CPF em branco, so espacos ou nulo vira nulo', () {
      expect(CPF.criarSeInformado(null), isNull);
      expect(CPF.criarSeInformado(''), isNull);
      expect(CPF.criarSeInformado('   '), isNull);
    });

    test('CNPJ em branco, so espacos ou nulo vira nulo', () {
      expect(CNPJ.criarSeInformado(null), isNull);
      expect(CNPJ.criarSeInformado(''), isNull);
      expect(CNPJ.criarSeInformado('   '), isNull);
    });

    test('documento valido, com ou sem mascara, guarda so os digitos', () {
      expect(CPF.criarSeInformado('111.444.777-35')!.numero, '11144477735');
      expect(CPF.criarSeInformado('11144477735')!.numero, '11144477735');
      expect(CNPJ.criarSeInformado('11.222.333/0001-81')!.numero, '11222333000181');
    });

    test('documento preenchido e invalido continua lancando', () {
      expect(() => CPF.criarSeInformado('111.444.777-34'), throwsArgumentError);
      expect(() => CNPJ.criarSeInformado('11.222.333/0001-82'), throwsArgumentError);
    });

    test('criar continua exigindo o documento', () {
      expect(() => CPF.criar(''), throwsArgumentError);
      expect(() => CNPJ.criar(''), throwsArgumentError);
    });
  });

  group('PessoaFisica sem CPF', () {
    test('fromJson aceita cpf nulo, vazio ou ausente', () {
      for (final json in [
        {'id': 1, 'nome': 'Joao', 'cpf': null},
        {'id': 1, 'nome': 'Joao', 'cpf': ''},
        {'id': 1, 'nome': 'Joao'},
      ]) {
        expect(PessoaFisica.fromJson(json).cpf, isNull, reason: '$json');
      }
    });

    test('toJson omite a chave cpf', () {
      final json = PessoaFisica(nome: 'Joao', cpf: null).toJson();

      expect(json.containsKey('cpf'), isFalse);
      expect(json['nome'], 'Joao');
      expect(json['tipoPessoa'], 'fisica');
    });

    test('documentoFormatado e nulo e a exibicao avisa a ausencia', () {
      final pessoa = PessoaFisica(nome: 'Joao', cpf: null);

      expect(pessoa.documentoFormatado, isNull);
      expect(pessoa.documentoParaExibicao, 'CPF não informado');
    });
  });

  group('PessoaFisica com CPF segue igual', () {
    final pessoa = PessoaFisica(nome: 'Joao', cpf: CPF.criar('11144477735'));

    test('toJson manda o CPF com mascara, como o backend exige', () {
      expect(pessoa.toJson()['cpf'], '111.444.777-35');
    });

    test('documentoFormatado e documentoParaExibicao coincidem', () {
      expect(pessoa.documentoFormatado, '111.444.777-35');
      expect(pessoa.documentoParaExibicao, '111.444.777-35');
    });
  });

  group('PessoaJuridica sem CNPJ', () {
    test('fromJson aceita cnpj nulo, vazio ou ausente', () {
      for (final json in [
        {'id': 2, 'razaoSocial': 'Agro Ltda', 'cnpj': null},
        {'id': 2, 'razaoSocial': 'Agro Ltda', 'cnpj': ''},
        {'id': 2, 'razaoSocial': 'Agro Ltda'},
      ]) {
        expect(PessoaJuridica.fromJson(json).cnpj, isNull, reason: '$json');
      }
    });

    test('toJson omite a chave cnpj e mantem a inscricao estadual', () {
      final json = PessoaJuridica(
        razaoSocial: 'Agro Ltda',
        cnpj: null,
        inscricaoEstadual: '12345678',
      ).toJson();

      expect(json.containsKey('cnpj'), isFalse);
      expect(json['inscrEstadual'], '12345678');
      expect(json['tipoPessoa'], 'juridica');
    });

    test('documentoFormatado e nulo e a exibicao avisa a ausencia', () {
      final pessoa = PessoaJuridica(razaoSocial: 'Agro Ltda', cnpj: null);

      expect(pessoa.documentoFormatado, isNull);
      expect(pessoa.documentoParaExibicao, 'CNPJ não informado');
    });

    test('com CNPJ, toJson manda o documento com mascara', () {
      final pessoa = PessoaJuridica(
        razaoSocial: 'Agro Ltda',
        cnpj: CNPJ.criar('11222333000181'),
      );

      expect(pessoa.toJson()['cnpj'], '11.222.333/0001-81');
      expect(pessoa.documentoParaExibicao, '11.222.333/0001-81');
    });
  });

  group('PessoaFactory decide o tipo sem depender do documento', () {
    test('tipoPessoa juridica com cnpj nulo vira PessoaJuridica', () {
      final pessoa = PessoaFactory.fromJson(
        {'id': 3, 'tipoPessoa': 'juridica', 'razaoSocial': 'Agro Ltda', 'cnpj': null},
      );

      expect(pessoa, isA<PessoaJuridica>());
      expect(pessoa.nomeParaExibicao, 'Agro Ltda');
    });

    test('tipoPessoa fisica com cpf nulo vira PessoaFisica', () {
      final pessoa = PessoaFactory.fromJson(
        {'id': 4, 'tipoPessoa': 'fisica', 'nome': 'Joao', 'cpf': null},
      );

      expect(pessoa, isA<PessoaFisica>());
    });

    test('sem tipoPessoa, como a rota por papel manda, a razao social decide',
        () {
      final pessoa = PessoaFactory.fromJson(
        {'id': 6, 'razaoSocial': 'Agro Ltda', 'cnpj': null, 'inscrEstadual': null},
      );

      expect(pessoa, isA<PessoaJuridica>());
      expect(pessoa.nomeParaExibicao, 'Agro Ltda');
      expect(pessoa.documentoParaExibicao, 'CNPJ não informado');
    });

    test('sem tipoPessoa e sem razao social continua pessoa fisica', () {
      final pessoa = PessoaFactory.fromJson({'id': 7, 'nome': 'Joao', 'cpf': null});

      expect(pessoa, isA<PessoaFisica>());
      expect(pessoa.nomeParaExibicao, 'Joao');
    });

    test('tipoPessoa explicito vence a heuristica', () {
      final pessoa = PessoaFactory.fromJson(
        {'id': 8, 'tipoPessoa': 'fisica', 'nome': 'Joao', 'razaoSocial': 'Lixo'},
      );

      expect(pessoa, isA<PessoaFisica>());
    });

    test('papel lido da rota sem documento nao derruba a desserializacao', () {
      final cliente = Cliente.fromJson({'id': 5, 'nome': 'Joao', 'cpf': null});

      expect(cliente.id, 5);
      expect(cliente.pessoa.documentoParaExibicao, 'CPF não informado');
    });
  });
}
