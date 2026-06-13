import 'package:frond_end_cafeicultura_mobile/model/auth/usuario.dart';

class Proprietario extends Usuario {
  Proprietario({
    super.id,
    required super.email,
    required super.telefone,
    required super.pessoa,
  });

}