import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';

class ServicesTalhao extends BaseService {
  late final Uri url = Uri.parse('$baseUrl/talhoes');

  Future<bool> cadastrar(Talhao talhao) async {
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: defaultHeaders,
        body: jsonEncode(talhao.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if(response.statusCode == 400){
        throw ApiException('Erro ao cadastrar talhão. Verifique seus dados e tente novamente.');
      }else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg =
            jsonResponse['error'] ??
            jsonResponse['mensagem'] ??
            'Erro ao cadastrar talhão.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  //getters
Future<List<Talhao>> buscarTodosTalhoesPorPropriedade(
    int idPropriedade, {
    int pagina = 1,
    int limite = 10,
  }) async {
    try {
      final limiteFinal = limite > 10 ? 10 : limite;

      final uri = Uri.parse('$url/propriedade/todos/$idPropriedade').replace(
        queryParameters: {
          'pagina': pagina.toString(),
          'limite': limiteFinal.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        final List<dynamic> jsonList = jsonBody['talhoes'] ?? [];

        return jsonList.map((json) => Talhao.fromJson(json)).toList();
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg =
            jsonResponse['error'] ??
            jsonResponse['mensagem'] ??
            'Erro ao buscar talhões da propriedade.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<List<Variedade>> buscarVariedades() async {
    try {
      final response = await http.get(
        Uri.parse('$url/variedades'),
        headers: defaultHeaders,
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return jsonList.map((json) => Variedade.fromJson(json)).toList();
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg =
            jsonResponse['error'] ??
            jsonResponse['mensagem'] ??
            'Erro ao buscar variedades.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  //patch
  Future<bool> encerrarTalhao(int idTalhao, DateTime dataFim) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/talhoes/$idTalhao/encerrar'),
        headers: defaultHeaders,
        body: jsonEncode({'dataFim': dataFim.toIso8601String()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg =
            jsonResponse['error'] ??
            jsonResponse['mensagem'] ??
            'Erro ao encerrar talhão.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }

  Future<bool> excluirTalhao(int idTalhao) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/talhoes/$idTalhao'),
        headers: defaultHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if(response.statusCode == 403){
        throw ApiException('Talhão não pode ser excluído pois há atividades cadastradas nele.');
      }else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg =
            jsonResponse['error'] ??
            jsonResponse['mensagem'] ??
            'Erro ao excluir talhão.';
        throw ApiException(msg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}
