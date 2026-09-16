import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';

void main() {
  group('validarNome aceita o que o backend aceita', () {
    final valoresLegitimos = {
      'logradouro com rodovia e quilometro': 'Rodovia ES 080, Km 12',
      'logradouro com numero': 'Rua 7 de Setembro, 100',
      'nome de propriedade com digito': 'Fazenda 3 Irmãos',
      'nome de insumo com percentual': 'Ureia Agrícola 46% N',
      'bairro comum': 'Vila Velha',
      'cidade com preposicao': 'Santa Teresa',
    };

    valoresLegitimos.forEach((descricao, valor) {
      test('aceita $descricao', () {
        expect(
          Validator.validarNome(valor),
          isNull,
          reason: '"$valor" e aceito pelo backend e nao pode ser barrado aqui',
        );
      });
    });

    test('exige preenchimento', () {
      expect(Validator.validarNome(null), 'O nome é obrigatório');
      expect(Validator.validarNome('   '), 'O nome é obrigatório');
    });

    test('exige pelo menos 3 caracteres, como o backend', () {
      expect(
        Validator.validarNome('Jo'),
        'O nome deve conter pelo menos 3 caracteres',
      );
    });

    test('recusa acima de 100 caracteres, como o backend', () {
      expect(Validator.validarNome('a' * 100), isNull);
      expect(
        Validator.validarNome('a' * 101),
        'O nome deve ter no máximo 100 caracteres',
      );
    });
  });

  group('validarNomePessoaFisica mantem a regra estrita de nome de gente', () {
    test('recusa digito e ordinal', () {
      expect(
        Validator.validarNomePessoaFisica('Ana Maria 2'),
        'O nome deve conter apenas letras',
      );
      expect(
        Validator.validarNomePessoaFisica('José 3º'),
        'O nome deve conter apenas letras',
      );
    });

    test('aceita acento, apostrofo e hifen', () {
      expect(Validator.validarNomePessoaFisica('Ana Maria'), isNull);
      expect(Validator.validarNomePessoaFisica("José D'Ávila"), isNull);
      expect(Validator.validarNomePessoaFisica('Jean-Pierre'), isNull);
    });

    test('herda as regras de tamanho de validarNome', () {
      expect(Validator.validarNomePessoaFisica(null), 'O nome é obrigatório');
      expect(
        Validator.validarNomePessoaFisica('Jo'),
        'O nome deve conter pelo menos 3 caracteres',
      );
      expect(
        Validator.validarNomePessoaFisica('a' * 101),
        'O nome deve ter no máximo 100 caracteres',
      );
    });
  });

  group('a inversao separa os dois mundos', () {
    const textosDeCampoLivre = [
      'Rodovia ES 080, Km 12',
      'Ureia Agrícola 46% N',
      'Fazenda 3 Irmãos',
    ];

    for (final texto in textosDeCampoLivre) {
      test('"$texto" passa no generico e para no de pessoa fisica', () {
        expect(
          Validator.validarNome(texto),
          isNull,
          reason: 'logradouro, insumo e propriedade usam o generico',
        );
        expect(
          Validator.validarNomePessoaFisica(texto),
          'O nome deve conter apenas letras',
          reason: 'se este falhar, um campo de pessoa ficou no validador '
              'errado e "João 2" passaria a ser aceito',
        );
      });
    }
  });

  group('selecaoObrigatoria', () {
    test('recusa nulo e aceita qualquer valor selecionado', () {
      expect(Validator.selecaoObrigatoria(null), 'Obrigatório');
      expect(Validator.selecaoObrigatoria(TipoPapel.funcionario), isNull);
      expect(Validator.selecaoObrigatoria(UF.ES), isNull);
    });
  });

  group('Email.isValid bate com o isEmail() do backend', () {
    final recusados = [
      '.joao@teste.com',
      'joao.@teste.com',
      'joao..silva@teste.com',
      'a@b',
      'joao@',
      '@teste.com',
      'joao teste@teste.com',
    ];

    for (final email in recusados) {
      test('recusa "$email"', () {
        expect(
          Email.isValid(email),
          isFalse,
          reason: 'o backend devolve 400 para "$email"',
        );
      });
    }

    final aceitos = [
      'joao.silva@teste.com',
      'joao+tag@teste.com.br',
      'a@b.co',
      'joao_silva@sub.teste.com',
      'financeiro.qa@sysgrano.dev',
    ];

    for (final email in aceitos) {
      test('aceita "$email"', () {
        expect(Email.isValid(email), isTrue);
      });
    }

    test('divergencia conhecida: TLD numerico o app aceita e o backend nao', () {
      expect(
        Email.isValid('joao@teste.123'),
        isTrue,
        reason: 'medido em 03/09/2026: POST /proprietarios devolve 400 para '
            'este e-mail (allow_numeric_tld: false). Ninguem digita isso por '
            'acidente, entao a divergencia fica registrada em vez de fechada',
      );
    });

    test('validarEmail devolve a mensagem em pt-BR', () {
      expect(Validator.validarEmail(''), 'O e-mail é obrigatório');
      expect(Validator.validarEmail('joao..silva@teste.com'),
          'Digite um e-mail válido');
      expect(Validator.validarEmail('joao.silva@teste.com'), isNull);
    });
  });

  group('senha: cadastro exige forte, login nao', () {
    test('validarSenha exige maiuscula, minuscula, numero e simbolo', () {
      expect(Validator.validarSenha('Senha@123'), isNull);
      expect(
        Validator.validarSenha('senha@123'),
        contains('maiúscula'),
        reason: 'sem maiuscula o backend tambem recusa',
      );
      expect(Validator.validarSenha('Senha123'), contains('símbolo'));
      expect(
        Validator.validarSenha('Se@1'),
        'A senha deve ter no mínimo 8 caracteres',
      );
    });

    test('validarSenha recusa emoji', () {
      expect(
        Validator.validarSenha('Senha@1\u{1F600}23'),
        'A senha não pode conter emojis',
      );
    });

    test('validarSenhaLogin so exige preenchimento', () {
      expect(
        Validator.validarSenhaLogin('123'),
        isNull,
        reason: 'POST /auth/autenticar so faz notEmpty na senha; exigir senha '
            'forte no login barraria conta antiga',
      );
      expect(Validator.validarSenhaLogin(''), 'A senha é obrigatória');
    });
  });

  group('documentos ficaram intactos', () {
    test('CPF recusa digito repetido e aceita com ou sem mascara', () {
      expect(CPF.isValid('111.444.777-35'), isTrue);
      expect(CPF.isValid('11144477735'), isTrue);
      expect(CPF.isValid('111.111.111-11'), isFalse);
      expect(CPF.isValid('111.444.777-34'), isFalse);
    });

    test('CNPJ recusa digito repetido e aceita com ou sem mascara', () {
      expect(CNPJ.isValid('11.222.333/0001-81'), isTrue);
      expect(CNPJ.isValid('11222333000181'), isTrue);
      expect(CNPJ.isValid('11.111.111/1111-11'), isFalse);
      expect(CNPJ.isValid('11.222.333/0001-82'), isFalse);
    });

    test('Telefone exige DDD valido e 10 ou 11 digitos', () {
      expect(Telefone.isValid('(27) 99999-8888'), isTrue);
      expect(Telefone.isValid('2733334444'), isTrue);
      expect(Telefone.isValid('0999998888'), isFalse);
      expect(Telefone.isValid('279999888'), isFalse);
    });
  });
}
