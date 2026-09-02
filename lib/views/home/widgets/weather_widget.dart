import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:frond_end_cafeicultura_mobile/viewmodels/clima/weather_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/model/clima/weather_model.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<WeatherViewModel>();
      if (vm.allWeatherTimeline.isEmpty && !vm.isLoading) {
        vm.fetchWeatherForCurrentLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    return CorpoComEstado(
      isLoading: vm.isLoading,
      mensagemErro: vm.errorMessage,
      aoTentarNovamente: () => vm.fetchWeatherForCurrentLocation(),
      vazio: vm.allWeatherTimeline.isEmpty && !vm.isLoading,
      construirVazio: (_) => _buildCard(child: _buildIndisponivelGeral()),
      construirConteudo: (_) => _buildCard(child: _buildConteudo(vm)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: child,
      ),
    );
  }

  Widget _buildConteudo(WeatherViewModel vm) {
    final weatherList = vm.allWeatherTimeline;

    return Column(
      key: const ValueKey('conteudo'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCabecalho(),
        const SizedBox(height: 16),
        SizedBox(
          height: 165, // Altura ajustada para caber os novos detalhes
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: weatherList.length,
            itemBuilder: (context, index) {
              final weather = weatherList[index];
              final isToday = index == 0;

              return _WeatherDayCard(weather: weather, isToday: isToday);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCabecalho() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppCores.verdePrimario.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.cloud_rounded,
            size: 20,
            color: AppCores.verdePrimario,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Previsão do Tempo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppCores.verdePrimario,
                ),
              ),
              Text(
                'Localização atual',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndisponivelGeral() {
    return Column(
      key: const ValueKey('indisponivel-geral'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Previsão do Tempo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppCores.verdePrimario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: Colors.redAccent,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Serviço meteorológico indisponível',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherDayCard extends StatelessWidget {
  final WeatherModel weather;
  final bool isToday;

  const _WeatherDayCard({
    Key? key,
    required this.weather,
    required this.isToday,
  }) : super(key: key);

  String _obterCaminhoSvg(String iconCode) {
    const assetPrefix = 'assets/images/icons/clima/';
    final normalizedCode = iconCode.trim().toLowerCase();

    switch (normalizedCode) {
      case '01d':
        return '${assetPrefix}01_sunny.svg';
      case '01n':
        return '${assetPrefix}02_clear_night.svg';
      case '02d':
        return '${assetPrefix}03_partly_cloudy.svg';
      case '02n':
        return '${assetPrefix}03_partly_cloudy_night.svg';
      case '03d':
      case '04d':
        return '${assetPrefix}04_cloudy.svg';
      case '03n':
      case '04n':
        return '${assetPrefix}04_cloudy_night.svg';
      case '09d':
        return '${assetPrefix}11_showers.svg';
      case '09n':
        return '${assetPrefix}11_showers_night.svg';
      case '10d':
        return '${assetPrefix}12_rain.svg';
      case '10n':
        return '${assetPrefix}12_rain_night.svg';
      case '11d':
        return '${assetPrefix}16_storms.svg';
      case '11n':
        return '${assetPrefix}16_storms_night.svg';
      case '13d':
        return '${assetPrefix}15_snow.svg';
      case '13n':
        return '${assetPrefix}15_snow_night.svg';
      case '50d':
        return '${assetPrefix}10_fog.svg';
      case '50n':
        return '${assetPrefix}10_fog_night.svg';
      default:
        return normalizedCode.endsWith('n')
            ? '${assetPrefix}00_missing_data_night.svg'
            : '${assetPrefix}00_missing_data.svg';
    }
  }

  String _windDirection(int degrees) {
    const directions = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
    return directions[((degrees % 360) / 45).round() % directions.length];
  }

  Widget _buildWeatherDetails(Color textColor, Color secondaryTextColor) {
    final rain = weather.precipitationProbability == null
        ? '—'
        : '${(weather.precipitationProbability! * 100).round()}%';
    final humidity = weather.humidity == null ? '—' : '${weather.humidity}%';
    final wind = weather.windSpeed == null
        ? '—'
        : '${weather.windSpeed!.toStringAsFixed(1)} m/s';
    final direction = weather.windDirection == null
        ? ''
        : ' ${_windDirection(weather.windDirection!)}';

    return Column(
      children: [
        Text(
          'Chuva $rain  •  Umid. $humidity',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: secondaryTextColor),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Vento $wind$direction',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: textColor),
            ),
            if (weather.windDirection != null) ...[
              const SizedBox(width: 4),
              Transform.rotate(
                angle: (weather.windDirection! * math.pi / 180) + math.pi,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 12,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayOfWeekFormatter = DateFormat('E', 'pt_BR');
    final dateFormatter = DateFormat('dd/MM');

    final backgroundColor = isToday
        ? AppCores.verdePrimario
        : Colors.transparent;
    final textColor = isToday ? Colors.white : Colors.black87;
    final secondaryTextColor = isToday
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black54;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: isToday ? null : Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isToday
                ? 'Hoje'
                : '${dayOfWeekFormatter.format(weather.date).toLowerCase()}.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateFormatter.format(weather.date),
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),

          const Spacer(),

          SvgPicture.asset(
            _obterCaminhoSvg(weather.iconCode),
            width: 28,
            height: 28,
            semanticsLabel: weather.description,
          ),

          const Spacer(),

          if (weather.maxTemperature != null && weather.minTemperature != null)
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: textColor),
                children: [
                  TextSpan(
                    text: '${weather.maxTemperature!.round()}° ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${weather.minTemperature!.round()}°',
                    style: TextStyle(color: secondaryTextColor, fontSize: 11),
                  ),
                ],
              ),
            )
          else
            Text(
              '${weather.temperature.round()}°',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

          const SizedBox(height: 6),
          _buildWeatherDetails(textColor, secondaryTextColor),
        ],
      ),
    );
  }
}
