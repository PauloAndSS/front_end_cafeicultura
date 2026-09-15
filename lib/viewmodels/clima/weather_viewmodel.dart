import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/model/clima/weather_model.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum OrigemDaPrevisao { propriedade, aparelho }

class WeatherViewModel extends ChangeNotifier {
  WeatherModel? currentWeather;
  List<WeatherModel> futureWeather = [];
  bool isLoading = false;
  String? errorMessage;

  String? localidade;
  OrigemDaPrevisao? origem;
  bool permissaoDeLocalizacaoNegada = false;

  static const Duration validadeDaPrevisao = Duration(minutes: 30);

  String? _chaveDaUltimaTentativa;
  DateTime? _horaDaUltimaTentativa;

  bool get previsaoEhDaPropriedade => origem == OrigemDaPrevisao.propriedade;
  static final String _apiKey = dotenv.get('API_CLIMA_CHAVE');
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geocodeUrl = 'https://api.openweathermap.org/geo/1.0';

  List<WeatherModel> get allWeatherTimeline {
    final list = <WeatherModel>[];
    if (currentWeather != null) list.add(currentWeather!);
    list.addAll(futureWeather);
    return list;
  }

  Future<void> fetchWeatherTimeline(double lat, double lon) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _fetchCurrentWeather(lat, lon);
      await _fetchForecastWeather(lat, lon);
    } catch (e) {
      errorMessage = 'Falha ao sincronizar dados meteorológicos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCurrentWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&lang=pt_br&appid=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final nome = data['name'] as String?;
      if (nome != null && nome.isNotEmpty) localidade = nome;

      currentWeather = WeatherModel(
        date: DateTime.now(),
        temperature: (data['main']['temp'] as num).toDouble(),
        description: data['weather'][0]['description'] ?? '',
        iconCode: data['weather'][0]['icon'] ?? '',
        humidity: (data['main']['humidity'] as num?)?.toInt(),
        windSpeed: (data['wind']?['speed'] as num?)?.toDouble(),
        windDirection: (data['wind']?['deg'] as num?)?.toInt(),
      );
    } else {
      throw Exception('Erro Atual: ${response.statusCode}');
    }
  }

  Future<void> _fetchForecastWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&lang=pt_br&appid=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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

        final dayKey = DateTime(
          dt.year,
          dt.month,
          dt.day,
        ).millisecondsSinceEpoch;
        if (!groupedByDay.containsKey(dayKey)) {
          groupedByDay[dayKey] = [];
        }
        groupedByDay[dayKey]!.add(item);
      }

      if (currentDayRainProbabilities.isNotEmpty && currentWeather != null) {
        currentWeather = currentWeather!.copyWith(
          precipitationProbability:
              currentDayRainProbabilities.reduce((a, b) => a + b) /
              currentDayRainProbabilities.length,
        );
      }

      futureWeather.clear();

      final sortedKeys = groupedByDay.keys.toList()..sort();
      for (var key in sortedKeys) {
        final dayList = groupedByDay[key]!;
        double minTemp = 1000.0;
        double maxTemp = -1000.0;

        for (var item in dayList) {
          final tempMin = (item['main']['temp_min'] as num).toDouble();
          final tempMax = (item['main']['temp_max'] as num).toDouble();
          if (tempMin < minTemp) minTemp = tempMin;
          if (tempMax > maxTemp) maxTemp = tempMax;
        }

        final middleItem = dayList[dayList.length ~/ 2];
        final icon = middleItem['weather'][0]['icon'];
        final desc = middleItem['weather'][0]['description'];
        final rainProbabilities = dayList
            .map((item) => (item['pop'] as num?)?.toDouble())
            .whereType<double>()
            .toList();

        futureWeather.add(
          WeatherModel(
            date: DateTime.fromMillisecondsSinceEpoch(key),
            temperature: (minTemp + maxTemp) / 2, // Média
            minTemperature: minTemp,
            maxTemperature: maxTemp,
            description: desc,
            iconCode: icon,
            precipitationProbability: rainProbabilities.isEmpty
                ? null
                : rainProbabilities.reduce((a, b) => a + b) /
                      rainProbabilities.length,
            humidity: (middleItem['main']['humidity'] as num?)?.toInt(),
            windSpeed: (middleItem['wind']?['speed'] as num?)?.toDouble(),
            windDirection: (middleItem['wind']?['deg'] as num?)?.toInt(),
          ),
        );
      }
    } else {
      throw Exception('Erro Previsão: ${response.statusCode}');
    }
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

    isLoading = true;
    errorMessage = null;
    permissaoDeLocalizacaoNegada = false;
    notifyListeners();

    try {
      final coordenadas = await _coordenadasDaPropriedade(propriedade);

      if (coordenadas != null) {
        origem = OrigemDaPrevisao.propriedade;
        localidade = _nomeDaLocalidade(propriedade!);
        await _carregarPara(coordenadas);
        return;
      }

      final doAparelho = await _coordenadasDoAparelho();
      origem = OrigemDaPrevisao.aparelho;
      localidade = null;
      await _carregarPara(doAparelho);
    } on _SemLocalizacao catch (falha) {
      permissaoDeLocalizacaoNegada = falha.permissaoNegada;
      errorMessage = falha.mensagem;
    } catch (e) {
      errorMessage = 'Falha ao sincronizar dados meteorológicos: $e';
    } finally {
      _horaDaUltimaTentativa = DateTime.now();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _carregarPara(_Coordenadas ponto) async {
    await _fetchCurrentWeather(ponto.latitude, ponto.longitude);
    await _fetchForecastWeather(ponto.latitude, ponto.longitude);
  }

  String _nomeDaLocalidade(Propriedade propriedade) =>
      '${propriedade.endereco.cidade} - ${propriedade.endereco.uf.name}';

  Future<_Coordenadas?> _coordenadasDaPropriedade(
    Propriedade? propriedade,
  ) async {
    if (propriedade == null) return null;

    final endereco = propriedade.endereco;
    if (endereco.cidade.trim().isEmpty) return null;

    final consulta = Uri.encodeComponent(
      '${endereco.cidade},${endereco.uf.name},BR',
    );
    final url = Uri.parse(
      '$_geocodeUrl/direct?q=$consulta&limit=1&appid=$_apiKey',
    );

    try {
      final resposta = await http.get(url);
      if (resposta.statusCode != 200) return null;

      final lista = json.decode(resposta.body) as List<dynamic>;
      if (lista.isEmpty) return null;

      final primeiro = lista.first as Map<String, dynamic>;
      return _Coordenadas(
        (primeiro['lat'] as num).toDouble(),
        (primeiro['lon'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('Geocodificação da propriedade falhou: $e');
      return null;
    }
  }

  Future<_Coordenadas> _coordenadasDoAparelho() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw const _SemLocalizacao(
        'A localização do aparelho está desligada, e a propriedade '
        'selecionada não tem cidade cadastrada.',
      );
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      throw const _SemLocalizacao(
        'Sem acesso à localização. Libere a permissão ou cadastre a cidade '
        'da propriedade para ver a previsão certa.',
        permissaoNegada: true,
      );
    }

    try {
      final posicao =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 5),
            ),
          );

      return _Coordenadas(posicao.latitude, posicao.longitude);
    } catch (e) {
      throw _SemLocalizacao('Não foi possível obter a localização: $e');
    }
  }
}

class _Coordenadas {
  final double latitude;
  final double longitude;

  const _Coordenadas(this.latitude, this.longitude);
}

class _SemLocalizacao implements Exception {
  final String mensagem;
  final bool permissaoNegada;

  const _SemLocalizacao(this.mensagem, {this.permissaoNegada = false});
}
