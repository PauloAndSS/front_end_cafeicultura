import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/model/model_cotacao_cafe.dart';
import 'package:http/http.dart' as http;

class CotacaoCafeViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? mensagemErro;
  RespostaCotacaoCafe? resposta;
  bool get temDados => resposta?.temAlgumDado ?? false;
  Future<void> carregar() async {
    isLoading = true;
    mensagemErro = null;
    notifyListeners();
    try {
      final json = await _buscarCotacao();
      resposta = RespostaCotacaoCafe.fromJson(json);
    } catch (e) {
      mensagemErro = 'Não foi possível carregar a cotação do café.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _buscarCotacao() async {
    final response = await http
        .get(Uri.parse('https://scrapping-coffe.onrender.com/cotacoes'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao consultar cotação: ${response.statusCode}');
    }

    final dados = jsonDecode(utf8.decode(response.bodyBytes));
    if (dados is! Map<String, dynamic>) {
      throw const FormatException('Resposta inválida da API de cotação.');
    }

    return dados;
  }
}
