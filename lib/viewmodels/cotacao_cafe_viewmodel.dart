import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/model/model_cotacao_cafe.dart';


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
      final json = await _buscarCotacaoDeExemplo();
      resposta = RespostaCotacaoCafe.fromJson(json);
    } catch (e) {
      mensagemErro = 'Não foi possível carregar a cotação do café.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<Map<String, dynamic>> _buscarCotacaoDeExemplo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'data_coleta': DateTime.now().toIso8601String(),
      'cooabriel': [
        {'Tipo': 'Conilon 7', 'Data': '01/09/2026', 'Hora': '10:03', 'Preço': 'R\$ 950,00'},
        {'Tipo': 'Conilon 7/8', 'Data': '01/09/2026', 'Hora': '10:03', 'Preço': 'R\$ 945,00'},
        {'Tipo': 'Conilon 8', 'Data': '01/09/2026', 'Hora': '10:03', 'Preço': 'R\$ 940,00'},
        {'Tipo': 'Escolha Conilon', 'Data': '01/09/2026', 'Hora': '10:03', 'Preço': 'R\$ 400,00'},
        {'Tipo': 'PIMENTA PRETA ASTA', 'Data': '01/09/2026', 'Hora': '10:03', 'Preço': 'R\$ 25,80'},
      ],
      'painel_do_cafe': [
        {'name': 'Conilon 7/8', 'value': 979.1049734423473},
        {'name': 'Arábica RIO', 'value': 1262.0859995120004},
      ],
      'erros': ['Falha ao atualizar a tabela da Cooabriel.'],
    };
  }
}