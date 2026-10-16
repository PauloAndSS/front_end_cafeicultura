import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_pessoas.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/papel_pessoa/papel_pessoa.dart';
import 'package:frond_end_cafeicultura_mobile/model/pessoa/pessoa_factory.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class DetalhesPessoaViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  PapelPessoa? _pessoaDetalhe;
  PapelPessoa? get pessoaDetalhe => _pessoaDetalhe;

  final ServicesFuncionario _servicoFuncionario = ServicesFuncionario();
  final ServicesDiarista _servicoDiarista = ServicesDiarista();

  late final EstadoDeCarga _cargaEdicaoDeValor = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  bool get isSalvandoValor => _cargaEdicaoDeValor.isLoading;
  String? get mensagemErroValor => _cargaEdicaoDeValor.mensagemErro;

  Future<void> buscarPorId(int id, TipoPapel tipoPapel) {
    _pessoaDetalhe = null;

    return cargaPrincipal.executar(
      chamada: () async {
        _pessoaDetalhe = await servicoDoPapel(tipoPapel).buscarPorId(id);
      },
      aoFalhar: () {},
    );
  }

  Future<bool> excluir(int id, TipoPapel tipoPapel) => cargaPrincipal.executar(
        chamada: () async {
          await servicoDoPapel(tipoPapel).excluir(id);
          return true;
        },
        aoFalhar: () => false,
      );

  Future<bool> atualizarSalario(int id, double salario) => _salvarValor(
        gravar: () => _servicoFuncionario.atualizarSalario(id, salario),
        reler: () => _servicoFuncionario.buscarPorId(id),
      );

  Future<bool> atualizarValorHora(int id, double valorHora) => _salvarValor(
        gravar: () => _servicoDiarista.atualizarValorHora(id, valorHora),
        reler: () => _servicoDiarista.buscarPorId(id),
      );

  Future<bool> _salvarValor({
    required Future<void> Function() gravar,
    required Future<PapelPessoa> Function() reler,
  }) {
    if (_cargaEdicaoDeValor.isLoading) return Future.value(false);

    return _cargaEdicaoDeValor.executar(
      chamada: () async {
        await gravar();
        _pessoaDetalhe = await reler();
        return true;
      },
      aoFalhar: () => false,
    );
  }
}
