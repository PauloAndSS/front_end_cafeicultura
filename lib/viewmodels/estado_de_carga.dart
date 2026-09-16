import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';

const String mensagemErroInterno = 'Ocorreu um erro inesperado no aplicativo. Tente novamente mais tarde.';

class EstadoDeCarga {
  EstadoDeCarga({
    required VoidCallback aoMudar,
    EstadoDeCarga? erroCompartilhadoCom,
  })  : _aoMudar = aoMudar,
        _donoDoErro = erroCompartilhadoCom;

  final VoidCallback _aoMudar;
  final EstadoDeCarga? _donoDoErro;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;

  String? get mensagemErro => _donoDoErro?.mensagemErro ?? _mensagemErro;

  set mensagemErro(String? mensagem) {
    final dono = _donoDoErro;

    if (dono == null) {
      _mensagemErro = mensagem;
    } else {
      dono.mensagemErro = mensagem;
    }
  }

  void abandonar() {
    _isLoading = false;
    mensagemErro = null;
  }

  Future<T> executar<T>({
    required Future<T> Function() chamada,
    required T Function() aoFalhar,
    bool Function()? aindaVale,
    FutureOr<void> Function()? aoFinalizar,
  }) async {
    _isLoading = true;
    mensagemErro = null;
    _aoMudar();

    String? erro;

    try {
      return await chamada();
    } on ApiException catch (e) {
      erro = e.mensagem;
      return aoFalhar();
    } catch (_) {
      erro = mensagemErroInterno;
      return aoFalhar();
    } finally {
      if (aoFinalizar != null) await aoFinalizar();

      if (aindaVale?.call() ?? true) {
        if (erro != null) mensagemErro = erro;

        _isLoading = false;
        _aoMudar();
      }
    }
  }
}

mixin EstadoDeCarregamentoMixin on NotificaSeVivoMixin {
  @protected
  late final EstadoDeCarga cargaPrincipal = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  bool get isLoading => cargaPrincipal.isLoading;

  String? get mensagemErro => cargaPrincipal.mensagemErro;

  @protected
  set mensagemErro(String? mensagem) => cargaPrincipal.mensagemErro = mensagem;
}
