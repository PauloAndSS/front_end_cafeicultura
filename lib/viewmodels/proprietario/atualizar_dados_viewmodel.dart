import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_fisica.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_juridica.dart';
import 'package:frond_end_cafeicultura_mobile/model/proprietario.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class AtualizarDadosViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final ServicesProprietario _proprietarioService;

  AtualizarDadosViewModel({ServicesProprietario? service})
      : _proprietarioService = service ?? ServicesProprietario();

  Future<Proprietario?> carregarDadosProprietario(int idProprietario) {
    return cargaPrincipal.executar(
      chamada: () async {
        final proprietario = await _proprietarioService.buscarPorId(idProprietario);
        return proprietario;
      },
      aoFalhar: () => null,
    );
  }

  Future<bool> atualizar({
    required Proprietario dadosOriginais,
    required SessionViewModel session,
    required int idProprietario,
    required bool isPessoaFisica,
    required String nomeOuRazao,
    required String emailDigitado,
    required String telefoneDigitado,
    required String cepDigitado,
    required String logradouro,
    required String bairro,
    required String cidade,
    required UF uf,
    String? inscEstadualDigitada,
    String? cnpjDigitado,
    String? pais,
  }) {
    return cargaPrincipal.executar(
      chamada: () async {
        List<Future<bool>> requisicoes = [];

        if (emailDigitado.trim() != dadosOriginais.email.endereco) {
          final emailVo = Email.criar(emailDigitado);
          requisicoes.add(_proprietarioService.atualizarEmail(idProprietario, emailVo.endereco));
        }

        final telAtualNum = telefoneDigitado.replaceAll(RegExp(r'\D'), '');
        final telOrigNum = dadosOriginais.telefone.numero.replaceAll(RegExp(r'\D'), '');
        if (telAtualNum != telOrigNum) {
          Telefone.criar(telefoneDigitado);
          requisicoes.add(_proprietarioService.atualizarTelefone(idProprietario, telefoneDigitado));
        }

        String identificacaoOriginal = isPessoaFisica
            ? (dadosOriginais.pessoa as PessoaFisica).nome
            : (dadosOriginais.pessoa as PessoaJuridica).razaoSocial;

        if (nomeOuRazao.trim() != identificacaoOriginal) {
          requisicoes.add(_proprietarioService.atualizarIdentificacao(
            id: idProprietario,
            nome: isPessoaFisica ? nomeOuRazao.trim() : null,
            razaoSocial: !isPessoaFisica ? nomeOuRazao.trim() : null,
          ));
        }

        if (!isPessoaFisica && inscEstadualDigitada != null) {
          final pj = dadosOriginais.pessoa as PessoaJuridica;
          if (inscEstadualDigitada.trim() != (pj.inscricaoEstadual ?? '')) {
            if (cnpjDigitado == null || cnpjDigitado.isEmpty) {
              throw ArgumentError('CNPJ é obrigatório para atualizar a Inscrição Estadual.');
            }
            final cnpjVo = CNPJ.criar(cnpjDigitado);
            requisicoes.add(_proprietarioService.atualizarInscricaoEstadual(
              id: idProprietario,
              inscEstadual: inscEstadualDigitada.trim(),
              cnpj: cnpjVo.numero,
            ));
          }
        }

        bool mudouEndereco = false;
        final endOrig = dadosOriginais.pessoa.endereco;
        final cepAtualNum = cepDigitado.replaceAll(RegExp(r'\D'), '');

        if (endOrig == null) {
          mudouEndereco = true;
        } else {
          final cepOrigNum = endOrig.cep.numero.replaceAll(RegExp(r'\D'), '');
          if (cepAtualNum != cepOrigNum ||
              logradouro.trim() != endOrig.logradouro ||
              bairro.trim() != endOrig.bairro ||
              cidade.trim() != endOrig.cidade ||
              uf != endOrig.uf ||
              (pais?.trim() ?? '') != (endOrig.pais ?? '')) { 
            mudouEndereco = true;
          }
        }

        if (mudouEndereco) {
          final cepVo = CEP.criar(cepDigitado);
          final novoEndereco = Endereco(
            cidade: cidade.trim(),
            bairro: bairro.trim(),
            cep: cepVo,
            logradouro: logradouro.trim(),
            uf: uf,
            pais: pais?.trim(),
          );
          requisicoes.add(_proprietarioService.atualizarEndereco(idProprietario, novoEndereco));
        }

        if (requisicoes.isEmpty) {
          return true; 
        }

        await Future.wait(requisicoes);

        if (nomeOuRazao.trim() != identificacaoOriginal) {
          session.atualizarNomeUsuario(nomeOuRazao.trim());
        }

        return true;
      },
      aoFalhar: () => false,
    );
  }
}
