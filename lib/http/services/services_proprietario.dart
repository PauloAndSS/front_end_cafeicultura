import 'dart:convert';
import 'package:frond_end_cafeicultura_mobile/http/dtos/cadastro_proprietario_dto.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/auth/proprietario.dart';
import 'package:http/http.dart' as http;
class ServicesProprietario extends BaseService{
  late final Uri url = Uri.parse('$baseUrl/proprietarios');
  
  Future<bool> cadastrarSemEndereco({
    required Proprietario proprietario,
    required String senha
  }) async{
    final dto = CadastroProprietarioDTO(proprietario: proprietario, senha: senha);
    try {
        final response = await http.post(
          url,
          headers: defaultHeaders,
          body: jsonEncode(dto.cadastrarSemEnderecoToJson())
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          return true; 
        } else {
          final corpoDecodificado = jsonDecode(response.body);
    
          if (corpoDecodificado.containsKey('erros') && corpoDecodificado['erros'] is List) {
            final List errosLista = corpoDecodificado['erros'];
            
            final mensagensBrutas = errosLista.map((e) => e['msg'].toString()).toList();

            throw ApiValidationException(mensagensBrutas);
            
          } else {
            final msg = corpoDecodificado['message'] ?? 'Erro desconhecido no servidor.';
            throw ApiException(msg);
          }
        }
        
    } on ApiValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Falha na comunicação: $e');
    }
  }
}