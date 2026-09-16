import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/http/exceptions/api_exceptions.dart';
import 'package:frond_end_cafeicultura_mobile/model/clima/weather_model.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/estado_de_carga.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notifica_se_vivo_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum OrigemDaPrevisao { propriedade, aparelho }

const String _mensagemServicoIndisponivel =
    'Serviço meteorológico indisponível no momento.';

class WeatherViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  WeatherModel? currentWeather;
  List<WeatherModel> futureWeather = [];

  String? localidade;
  OrigemDaPrevisao? origem;
  bool permissaoDeLocalizacaoNegada = false;

  static const Duration validadeDaPrevisao = Duration(minutes: 30);
  static const Duration _tempoLimiteDaRequisicao = Duration(seconds: 15);
  static const Duration _tempoLimiteDaLocalizacao = Duration(seconds: 10);

  String? _chaveDaUltimaTentativa;
  DateTime? _horaDaUltimaTentativa;

  bool get previsaoEhDaPropriedade => origem == OrigemDaPrevisao.propriedade;
  bool get aindaNaoTentou => _horaDaUltimaTentativa == null;

  static final String _apiKey = dotenv.get('API_CLIMA_CHAVE');
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geocodeUrl = 'https://api.openweathermap.org/geo/1.0';

  List<WeatherModel> get allWeatherTimeline {
    final list = <WeatherModel>[];
    if (currentWeather != null) list.add(currentWeather!);
    list.addAll(futureWeather);
    return list;
  }

  String? _chaveDe(Propriedade? propriedade) {
    if (propriedade == null) return null;

    final endereco = propriedade.endereco;

    return '${propriedade.id}|${endereco.cidade.trim().toLowerCase()}'
        '|${endereco.uf.name}';
  }

  bool _tentativaExpirou() {
    final hora = _horaDaUltimaTentativa;
    if (hora == null) return true;

    return DateTime.now().difference(hora) >= validadeDaPrevisao;
  }

  bool precisaCarregarPara(Propriedade? propriedade) {
    if (isLoading) return false;
    if (_chaveDe(propriedade) != _chaveDaUltimaTentativa) return true;

    return _tentativaExpirou();
  }

  void _limparPrevisao() {
    currentWeather = null;
    futureWeather = [];
    localidade = null;
    origem = null;
  }

  Future<void> carregarPrevisao(
    Propriedade? propriedade, {
    bool forcar = false,
  }) async {
    if (isLoading) return;
    if (!forcar && !precisaCarregarPara(propriedade)) return;

    final chave = _chaveDe(propriedade);
    if (chave != _chaveDaUltimaTentativa) _limparPrevisao();
    _chaveDaUltimaTentativa = chave;
    permissaoDeLocalizacaoNegada = false;

    await cargaPrincipal.executar(
      chamada: () => _buscarPrevisaoDe(propriedade),
      aoFalhar: () {},
      aoFinalizar: () => _horaDaUltimaTentativa = DateTime.now(),
    );
  }

  Future<void> _buscarPrevisaoDe(Propriedade? propriedade) async {
    if (propriedade == null || propriedade.endereco.cidade.trim().isEmpty) {
      await _buscarPelaLocalizacaoDoAparelho();
      return;
    }

    origem = OrigemDaPrevisao.propriedade;
    localidade = _nomeDaLocalidade(propriedade);

    final ponto = await _geocodificar(propriedade);
    await _carregarPara(ponto);
  }

  Future<void> _buscarPelaLocalizacaoDoAparelho() async {
    origem = OrigemDaPrevisao.aparelho;
    localidade = null;

    final ponto = await _coordenadasDoAparelho();
    await _carregarPara(ponto);
  }

  Future<void> _carregarPara(_Coordenadas ponto) async {
    await _fetchCurrentWeather(ponto.latitude, ponto.longitude);
    await _fetchForecastWeather(ponto.latitude, ponto.longitude);
  }

  String _nomeDaLocalidade(Propriedade propriedade) =>
      '${propriedade.endereco.cidade.trim()} - ${propriedade.endereco.uf.name}';

  Future<dynamic> _obterJson(Uri url) async {
    final http.Response resposta;

    try {
      resposta = await http.get(url).timeout(_tempoLimiteDaRequisicao);
    } catch (e) {
      debugPrint('Requisição meteorológica falhou em ${url.path}: $e');
      throw ApiException(_mensagemServicoIndisponivel);
    }

    if (resposta.statusCode != 200) {
      debugPrint(
        'Serviço meteorológico respondeu ${resposta.statusCode} em ${url.path}',
      );
      throw ApiException(_mensagemServicoIndisponivel);
    }

    return json.decode(resposta.body);
  }

  Future<_Coordenadas> _geocodificar(Propriedade propriedade) async {
    final endereco = propriedade.endereco;
    final consulta = Uri.encodeComponent(
      '${endereco.cidade.trim()},${endereco.uf.name},BR',
    );
    final url = Uri.parse(
      '$_geocodeUrl/direct?q=$consulta&limit=1&appid=$_apiKey',
    );

    final lista = await _obterJson(url) as List<dynamic>;
    if (lista.isEmpty) {
      throw ApiException(
        'Cidade "${_nomeDaLocalidade(propriedade)}" não encontrada no serviço '
        'de previsão. Confira o endereço da propriedade.',
      );
    }

    final primeiro = lista.first as Map<String, dynamic>;
    return _Coordenadas(
      (primeiro['lat'] as num).toDouble(),
      (primeiro['lon'] as num).toDouble(),
    );
  }

  Future<void> _fetchCurrentWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&lang=pt_br&appid=$_apiKey',
    );

    final data = await _obterJson(url) as Map<String, dynamic>;

    final nome = data['name'] as String?;
    if (origem == OrigemDaPrevisao.aparelho && nome != null && nome.isNotEmpty) {
      localidade = nome;
    }

    currentWeather = WeatherModel(
      date: DateTime.now(),
      temperature: (data['main']['temp'] as num).toDouble(),
      description: data['weather'][0]['description'] ?? '',
      iconCode: data['weather'][0]['icon'] ?? '',
      humidity: (data['main']['humidity'] as num?)?.toInt(),
      windSpeed: (data['wind']?['speed'] as num?)?.toDouble(),
      windDirection: (data['wind']?['deg'] as num?)?.toInt(),
    );
  }

  Future<void> _fetchForecastWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&lang=pt_br&appid=$_apiKey',
    );

    final data = await _obterJson(url) as Map<String, dynamic>;
    final List<dynamic> list = data['list'];

    final Map<int, List<dynamic>> groupedByDay = {};
    final now = DateTime.now();
    final currentDayRainProbabilities = <double>[];

    for (var item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final probability = (item['pop'] as num?)?.toDouble();
        if (probability != null) currentDayRainProbabilities.add(probability);
        continue;
      }

      final dayKey = DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;
      groupedByDay.putIfAbsent(dayKey, () => []).add(item);
    }

    if (currentDayRainProbabilities.isNotEmpty && currentWeather != null) {
      currentWeather = currentWeather!.copyWith(
        precipitationProbability: _media(currentDayRainProbabilities),
      );
    }

    futureWeather.clear();

    final sortedKeys = groupedByDay.keys.toList()..sort();
    for (var key in sortedKeys) {
      futureWeather.add(_resumoDoDia(key, groupedByDay[key]!));
    }
  }

  WeatherModel _resumoDoDia(int dayKey, List<dynamic> dayList) {
    double minTemp = 1000.0;
    double maxTemp = -1000.0;

    for (var item in dayList) {
      final tempMin = (item['main']['temp_min'] as num).toDouble();
      final tempMax = (item['main']['temp_max'] as num).toDouble();
      if (tempMin < minTemp) minTemp = tempMin;
      if (tempMax > maxTemp) maxTemp = tempMax;
    }

    final middleItem = dayList[dayList.length ~/ 2];
    final rainProbabilities = dayList
        .map((item) => (item['pop'] as num?)?.toDouble())
        .whereType<double>()
        .toList();

    return WeatherModel(
      date: DateTime.fromMillisecondsSinceEpoch(dayKey),
      temperature: (minTemp + maxTemp) / 2,
      minTemperature: minTemp,
      maxTemperature: maxTemp,
      description: middleItem['weather'][0]['description'],
      iconCode: middleItem['weather'][0]['icon'],
      precipitationProbability:
          rainProbabilities.isEmpty ? null : _media(rainProbabilities),
      humidity: (middleItem['main']['humidity'] as num?)?.toInt(),
      windSpeed: (middleItem['wind']?['speed'] as num?)?.toDouble(),
      windDirection: (middleItem['wind']?['deg'] as num?)?.toInt(),
    );
  }

  double _media(List<double> valores) =>
      valores.reduce((a, b) => a + b) / valores.length;

  Future<_Coordenadas> _coordenadasDoAparelho() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw ApiException(
        'A propriedade não tem cidade cadastrada e a localização do aparelho '
        'está desligada. Ligue a localização ou cadastre a cidade.',
      );
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.deniedForever) {
      permissaoDeLocalizacaoNegada = true;
      throw ApiException(
        'Sem acesso à localização. Libere a permissão nas configurações ou '
        'cadastre a cidade da propriedade.',
      );
    }

    if (permissao == LocationPermission.denied) {
      throw ApiException(
        'Sem acesso à localização. Permita o acesso ou cadastre a cidade da '
        'propriedade.',
      );
    }

    try {
      final posicao =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: _tempoLimiteDaLocalizacao,
            ),
          );

      return _Coordenadas(posicao.latitude, posicao.longitude);
    } catch (e) {
      debugPrint('Localização do aparelho falhou: $e');
      throw ApiException(
        'O aparelho não conseguiu obter a localização. Tente novamente ou '
        'cadastre a cidade da propriedade.',
      );
    }
  }
}

class _Coordenadas {
  final double latitude;
  final double longitude;

  const _Coordenadas(this.latitude, this.longitude);
}
