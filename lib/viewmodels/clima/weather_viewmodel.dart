import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frond_end_cafeicultura_mobile/model/clima/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class WeatherViewModel extends ChangeNotifier {
  WeatherModel? currentWeather;
  List<WeatherModel> futureWeather = [];
  bool isLoading = false;
  String? errorMessage;
  static const String _apiKey = '5fe49eb837725464a65c8e346b93b109';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

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

  Future<void> fetchWeatherForCurrentLocation() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('O GPS está desativado.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão negada pelo usuário.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão negada permanentemente.');
      }

      Position? position;

      try {
        // 1. Tenta pegar a última localização conhecida na memória (Instantâneo)
        position = await Geolocator.getLastKnownPosition();

        // 2. Se não houver cache, busca a atual com limite de 5 segundos
        position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );

        // Carrega com a posição do GPS
        await _fetchCurrentWeather(position.latitude, position.longitude);
        await _fetchForecastWeather(position.latitude, position.longitude);
      } catch (e) {
        // PLANO B: Se o GPS falhar (ex: Emulador sem localização setada ou falta de sinal)
        // Usamos as coordenadas padrão do Sítio (Santa Teresa - ES)
        debugPrint(
          'Aviso: GPS falhou ou demorou. Usando localização padrão. Erro: $e',
        );

        await _fetchCurrentWeather(-19.9367, -40.6004);
        await _fetchForecastWeather(-19.9367, -40.6004);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
