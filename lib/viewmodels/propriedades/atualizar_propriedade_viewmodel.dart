import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/eventos/services_trato_cultural.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

class AtualizarPropriedadeViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  Propriedade? _propriedade;
  Propriedade? get propriedade => _propriedade;

  final _service = ServicesPropriedade();

  final _tratoService = ServicesTratoCultural();

  late final EstadoDeCarga _cargaAtividades = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  bool? _temAtividades;

  bool get temAtividades => _temAtividades ?? false;

  bool get sabeSeTemAtividades => _temAtividades != null;

  Future<void> conferirAtividades(int idPropriedade) {
    return _cargaAtividades.executar(
      chamada: () async {
        for (final status in StatusEvento.values) {
          final pagina = await _tratoService.buscarPorStatus(
            idPropriedade,
            status: status,
            pagina: 1,
          );

          if (pagina.data.isNotEmpty) {
            _temAtividades = true;
            return;
          }
        }

        _temAtividades = false;
      },
      aoFalhar: () {},
    );
  }

  Future<void> carregarPropriedade(int id) => cargaPrincipal.executar(
        chamada: () async {
          _propriedade = await _service.buscarPorId(id);
        },
        aoFalhar: () {},
      );

  Future<bool> atualizarPropriedadeCompleta({
    required int id,
    required String nome,
    required Tamanho tamanho,
    required Endereco endereco,
  }) {
    return cargaPrincipal.executar(
      chamada: () async {
        await Future.wait([
          _service.atualizarNome(id, nome),
          _service.atualizarTamanho(id, tamanho),
          _service.atualizarEndereco(id, endereco),
        ]);

        return true;
      },
      aoFalhar: () => false,
    );
  }

  Future<bool> excluir(int id) => cargaPrincipal.executar(
        chamada: () async {
          await _service.excluir(id);
          return true;
        },
        aoFalhar: () => false,
      );
}
