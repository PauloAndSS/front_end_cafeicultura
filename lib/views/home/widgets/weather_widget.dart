import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/clima/weather_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/model/clima/weather_model.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_estilos.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/corpo_com_estado.dart';
import 'package:geolocator/geolocator.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  void _carregar(Propriedade? propriedade, {bool forcar = false}) {
    context.read<WeatherViewModel>().carregarPrevisao(
      propriedade,
      forcar: forcar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final propriedade = context
        .watch<PropriedadesUsuarioViewModel>()
        .propriedadeSelecionada;

    if (vm.precisaCarregarPara(propriedade)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _carregar(propriedade);
      });
    }

    return CorpoComEstado(
      isLoading: vm.isLoading,
      mensagemErro: vm.errorMessage,
      aoTentarNovamente: vm.permissaoDeLocalizacaoNegada
          ? Geolocator.openAppSettings
          : () => _carregar(propriedade, forcar: true),
      vazio: vm.allWeatherTimeline.isEmpty,
      manterConteudoAoRecarregar: true,
      construirVazio: (_) => _buildCard(child: _buildIndisponivelGeral()),
      construirConteudo: (_) => _buildCard(child: _buildConteudo(vm)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: AppEstilos.cartao(),
      child: child,
    );
  }

  Widget _buildConteudo(WeatherViewModel vm) {
    final weatherList = vm.allWeatherTimeline;

    return Column(
      key: const ValueKey('conteudo'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCabecalho(vm),
        const SizedBox(height: 16),
        SizedBox(
          height: 125,
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

  Widget _buildCabecalho(WeatherViewModel vm) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppCores.acao.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.cloud_rounded,
            size: 20,
            color: AppCores.acao,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Previsão do Tempo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppCores.acao,
                ),
              ),
              Text(
                vm.localidade ?? 'Localização do aparelho',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppCores.textoSecundario,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (!vm.previsaoEhDaPropriedade)
          const Tooltip(
            message:
                'Previsão do aparelho, não da propriedade. Cadastre a cidade '
                'da propriedade para a previsão certa.',
            triggerMode: TooltipTriggerMode.tap,
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.my_location_outlined,
                size: 18,
                color: AppCores.aviso,
              ),
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
                color: AppCores.erro.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: AppCores.erro,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Previsão do Tempo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppCores.acao,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20, color: AppCores.erro),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Serviço meteorológico indisponível',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppCores.textoPrimario,
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

  String _obterCaminhoIcone(String iconCode) {
    switch (iconCode) {
      case '01d':
        return 'assets/images/icons/clima/01_sunny.svg';
      case '01n':
        return 'assets/images/icons/clima/02_clear_night.svg';
      case '02d':
        return 'assets/images/icons/clima/03_partly_cloudy.svg';
      case '02n':
        return 'assets/images/icons/clima/03_partly_cloudy_night.svg';
      case '03d':
      case '04d':
        return 'assets/images/icons/clima/04_cloudy.svg';
      case '03n':
      case '04n':
        return 'assets/images/icons/clima/04_cloudy_night.svg';
      case '09d':
        return 'assets/images/icons/clima/11_showers.svg';
      case '09n':
        return 'assets/images/icons/clima/11_showers_night.svg';
      case '10d':
        return 'assets/images/icons/clima/12_rain.svg';
      case '10n':
        return 'assets/images/icons/clima/12_rain_night.svg';
      case '11d':
        return 'assets/images/icons/clima/16_storms.svg';
      case '11n':
        return 'assets/images/icons/clima/16_storms_night.svg';
      case '13d':
        return 'assets/images/icons/clima/15_snow.svg';
      case '13n':
        return 'assets/images/icons/clima/15_snow_night.svg';
      case '50d':
        return 'assets/images/icons/clima/10_fog.svg';
      case '50n':
        return 'assets/images/icons/clima/10_fog_night.svg';
      default:
        return iconCode.endsWith('n')
            ? 'assets/images/icons/clima/00_missing_data_night.svg'
            : 'assets/images/icons/clima/00_missing_data.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayOfWeekFormatter = DateFormat('E', 'pt_BR');
    final dateFormatter = DateFormat('dd/MM');

    final backgroundColor = isToday ? AppCores.acao : Colors.transparent;
    final textColor = isToday ? AppCores.sobreAcao : AppCores.textoPrimario;
    final secondaryTextColor = isToday
        ? AppCores.sobreAcao.withValues(alpha: 0.8)
        : AppCores.textoSecundario;

    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
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

          SizedBox(
            width: 32,
            height: 32,
            child: SvgPicture.asset(
              _obterCaminhoIcone(weather.iconCode),
              semanticsLabel: weather.description,
            ),
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
        ],
      ),
    );
  }
}
