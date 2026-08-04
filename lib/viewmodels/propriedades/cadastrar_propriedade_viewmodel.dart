import 'package:flutter/widgets.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services_propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/model/tamanho.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/session_viewmodel.dart';

class CadastrarPropriedadeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;
  String? get mensagemErro => _mensagemErro;

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
  }) async {
    _isLoading = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final tamanho = Tamanho(
        valor: valorTamanho, 
        medida: Medida.fromString(medidaTamanho),
      );
      
      final endereco = Endereco(
        cep: CEP.criar(cep),
        logradouro: logradouro.trim(),
        bairro: bairro.trim(),
        cidade: cidade.trim(),
        uf: uf,
      );

      final novaPropriedade = Propriedade(
        nome: nome.trim(),
        tamanho: tamanho,
        endereco: endereco,
      );

      final resultado = await _propriedadeService.cadastrar(novaPropriedade);
      return resultado;
    } on ApiException catch (e) {
      _mensagemErro = e.mensagem;
      return false;
    } catch (e) {
      _mensagemErro = 'Ocorreu um erro interno no aplicativo. Tente novamente mais tarde.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}