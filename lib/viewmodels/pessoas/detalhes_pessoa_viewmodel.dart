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

  late final Map<TipoPapel, dynamic> _services;

  DetalhesPessoaViewModel() {
    _services = {
      TipoPapel.funcionario: ServicesFuncionario(),
      TipoPapel.meeiro: ServicesMeeiro(),
      TipoPapel.fornecedor: ServicesFornecedor(),
      TipoPapel.prestador: ServicesPrestadorDeServico(),
      TipoPapel.cliente: ServicesCliente(),
    };
  }

  Future<void> buscarPorId(int id, TipoPapel tipoPapel) {
    _pessoaDetalhe = null;

    return cargaPrincipal.executar(
      chamada: () async {
        _pessoaDetalhe = await _services[tipoPapel]!.buscarPorId(id);
      },
      aoFalhar: () {},
    );
  }

  Future<bool> excluir(int id, TipoPapel tipoPapel) => cargaPrincipal.executar(
        chamada: () async {
          await _services[tipoPapel].excluir(id);
          return true;
        },
        aoFalhar: () => false,
      );

  Future<bool> atualizarSalario(int id, double salario) => cargaPrincipal.executar(
        chamada: () async {
          await _services[TipoPapel.funcionario].atualizarSalario(id, salario);
          return true;
        },
        aoFalhar: () => false,
      );
}
