class WeatherModel {
  final DateTime date;
  final double temperature;
  final double? minTemperature; 
  final double? maxTemperature; 
  final String description;
  final String iconCode;

  WeatherModel({
    required this.date,
    required this.temperature,
    this.minTemperature,
    this.maxTemperature,
    required this.description,
    required this.iconCode,
  });
}