import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frond_end_cafeicultura_mobile/http/services/services.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';

void main() {
  test('deve parsear uma safra com campos básicos', () {
    final safra = Safra.fromJson({
      'id': 1,
      'nome': 'Safra 2025',
      'descricao': 'Safra principal',
      'dataInicio': '2025-01-01T00:00:00.000Z',
      'dataFim': '2025-12-31T00:00:00.000Z',
      'status': 'Ativa',
      'ativa': true,
    });

    expect(safra.id, 1);
    expect(safra.nome, 'Safra 2025');
    expect(safra.status, 'Ativa');
    expect(safra.ativa, true);
  });

  test('deve resolver o host da API para o ambiente correto', () {
    expect(
      BaseService.resolveBaseUrl(isWeb: true, platform: TargetPlatform.android),
      'http://localhost:3333/api/v1',
    );
    expect(
      BaseService.resolveBaseUrl(isWeb: false, platform: TargetPlatform.android),
      'http://10.0.2.2:3333/api/v1',
    );
    expect(
      BaseService.resolveBaseUrl(isWeb: false, platform: TargetPlatform.windows),
      'http://localhost:3333/api/v1',
    );
  });
}
