class WeatherModel {
  final DateTime date;
  final double temperature;
  final double? minTemperature;
  final double? maxTemperature;
  final String description;
  final String iconCode;
  final double? precipitationProbability;
  final int? humidity;
  final double? windSpeed;
  final int? windDirection;

  WeatherModel({
    required this.date,
    required this.temperature,
    this.minTemperature,
    this.maxTemperature,
    required this.description,
    required this.iconCode,
    this.precipitationProbability,
    this.humidity,
    this.windSpeed,
    this.windDirection,
  });

  WeatherModel copyWith({double? precipitationProbability}) {
    return WeatherModel(
      date: date,
      temperature: temperature,
      minTemperature: minTemperature,
      maxTemperature: maxTemperature,
      description: description,
      iconCode: iconCode,
      precipitationProbability:
          precipitationProbability ?? this.precipitationProbability,
      humidity: humidity,
      windSpeed: windSpeed,
      windDirection: windDirection,
    );
  }
}
