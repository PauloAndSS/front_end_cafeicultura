import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class CadastrarPropriedadeViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  final _propriedadeService = ServicesPropriedade();

  Future<bool?> cadastrarPropriedade({
    required SessionViewModel session,
    required String nome,
    required double valorTamanho,
    required String medidaTamanho,
    required String cep,
    required String logradouro,
    required String bairro,
    required String cidade,
    required UF uf,
    required String pais,
  }) {
    return cargaPrincipal.executar(
      chamada: () {
        final novaPropriedade = Propriedade(
          nome: nome.trim(),
          tamanho: Tamanho(
            valor: valorTamanho,
            medida: Medida.fromString(medidaTamanho),
          ),
          endereco: Endereco(
            cep: CEP.criar(cep),
            logradouro: logradouro.trim(),
            bairro: bairro.trim(),
            cidade: cidade.trim(),
            uf: uf,
          ),
        );

        return _propriedadeService.cadastrar(novaPropriedade);
      },
      aoFalhar: () => false,
    );
  }
}
