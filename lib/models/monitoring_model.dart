// models/monitoring_model.dart

class PlantData {
  final double humidity;
  final double tempDHT;
  final double tempDS;

  PlantData({
    required this.humidity,
    required this.tempDHT,
    required this.tempDS,
  });
}

class WeatherData {
  final int hour;
  final double temp;
  final double precipitationProbability;
  final double windSpeed;
  final int code;

  WeatherData({
    required this.hour,
    required this.temp,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.code,
  });

  static String getWeatherLabel(int code) {
    if (code == 0) return 'Clear';
    if (code < 4) return 'Partly Cloudy';
    if (code < 51) return 'Cloudy';
    if (code < 70) return 'Rainy';
    if (code < 90) return 'Thunderstorm';
    return 'Unknown';
  }

  static String getWeatherEmoji(int code) {
    if (code == 0) return '☀️';
    if (code < 4) return '🌤️';
    if (code < 51) return '☁️';
    if (code < 70) return '🌧️';
    if (code < 90) return '⛈️';
    return '❓';
  }
}
