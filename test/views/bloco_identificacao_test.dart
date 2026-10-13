import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/campos_formulario.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/formulario/bloco_identificacao.dart';

class Controladores {
  final nome = TextEditingController(text: 'Joao da Silva');
  final razaoSocial = TextEditingController(text: 'Agro Ltda');
  final cpf = TextEditingController();
  final cnpj = TextEditingController();
  final inscricaoEstadual = TextEditingController();
}

Future<GlobalKey<FormState>> montarBloco(
  WidgetTester tester, {
  required bool pessoaFisica,
  required Controladores controladores,
  bool? documentoObrigatorio,
}) async {
  final chave = GlobalKey<FormState>();

  final bloco = documentoObrigatorio == null
      ? BlocoIdentificacao(
          pessoaFisica: pessoaFisica,
          controllerNome: controladores.nome,
          controllerRazaoSocial: controladores.razaoSocial,
          controllerCpf: controladores.cpf,
          controllerCnpj: controladores.cnpj,
          controllerInscricaoEstadual: controladores.inscricaoEstadual,
        )
      : BlocoIdentificacao(
          pessoaFisica: pessoaFisica,
          documentoObrigatorio: documentoObrigatorio,
          controllerNome: controladores.nome,
          controllerRazaoSocial: controladores.razaoSocial,
          controllerCpf: controladores.cpf,
          controllerCnpj: controladores.cnpj,
          controllerInscricaoEstadual: controladores.inscricaoEstadual,
        );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: Form(key: chave, child: bloco)),
      ),
    ),
  );

  return chave;
}

Future<bool> validar(WidgetTester tester, GlobalKey<FormState> chave) async {
  final valido = chave.currentState!.validate();
  await tester.pump();
  return valido;
}

void main() {
  group('papel: documento opcional', () {
    testWidgets('CPF em branco passa e o campo leva a marca de opcional',
        (tester) async {
      final chave = await montarBloco(
        tester,
        pessoaFisica: true,
        documentoObrigatorio: false,
        controladores: Controladores(),
      );

      expect(find.byType(MarcaOpcional), findsOneWidget);
      expect(await validar(tester, chave), isTrue);
      expect(find.text('O CPF é obrigatório'), findsNothing);
    });

    testWidgets('CPF preenchido e invalido continua sendo recusado',
        (tester) async {
      final controladores = Controladores()..cpf.text = '111.444.777-34';
      final chave = await montarBloco(
        tester,
        pessoaFisica: true,
        documentoObrigatorio: false,
        controladores: controladores,
      );

      expect(await validar(tester, chave), isFalse);
      expect(find.text('CPF inválido'), findsOneWidget);
    });

    testWidgets('CPF preenchido e valido passa', (tester) async {
      final controladores = Controladores()..cpf.text = '111.444.777-35';
      final chave = await montarBloco(
        tester,
        pessoaFisica: true,
        documentoObrigatorio: false,
        controladores: controladores,
      );

      expect(await validar(tester, chave), isTrue);
    });

    testWidgets('CNPJ em branco passa e invalido e recusado', (tester) async {
      final controladores = Controladores();
      final chave = await montarBloco(
        tester,
        pessoaFisica: false,
        documentoObrigatorio: false,
        controladores: controladores,
      );

      expect(find.byType(MarcaOpcional), findsOneWidget);
      expect(await validar(tester, chave), isTrue);

      controladores.cnpj.text = '11.222.333/0001-82';
      expect(await validar(tester, chave), isFalse);
      expect(find.text('CNPJ inválido'), findsOneWidget);
    });
  });

  group('usuario: documento obrigatorio por padrao', () {
    testWidgets('sem o parametro, CPF em branco e recusado', (tester) async {
      final chave = await montarBloco(
        tester,
        pessoaFisica: true,
        controladores: Controladores(),
      );

      expect(find.byType(MarcaOpcional), findsNothing);
      expect(await validar(tester, chave), isFalse);
      expect(find.text('O CPF é obrigatório'), findsOneWidget);
    });

    testWidgets('sem o parametro, CNPJ em branco e recusado', (tester) async {
      final chave = await montarBloco(
        tester,
        pessoaFisica: false,
        controladores: Controladores(),
      );

      expect(find.byType(MarcaOpcional), findsNothing);
      expect(await validar(tester, chave), isFalse);
      expect(find.text('O CNPJ é obrigatório'), findsOneWidget);
    });
  });
}
