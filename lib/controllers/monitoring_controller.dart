// controllers/monitoring_controller.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class MonitoringController {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("hidroponik/current");

  /// Stream real-time data from Firebase
  Stream<Map<String, dynamic>> streamPlantData() {
    return dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return {
        "humidity": data['humidity']?.toDouble(),
        "tempDHT": data['tempDHT']?.toDouble(),
        "tempDS": data['tempDS']?.toDouble(),
      };
    });
  }

  /// Fetch weather forecast from Open-Meteo API (with optimized performance)
  Future<List<Map<String, dynamic>>> fetchWeatherForecast() async {
    const url =
        'https://api.open-meteo.com/v1/forecast?latitude=-6.9222&longitude=107.6069&hourly=temperature_2m,precipitation_probability,wind_speed_10m,weather_code&timezone=auto&forecast_days=1';

    final stopwatch = Stopwatch()..start();
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch weather data: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);
    final hourly = decoded['hourly'];
    final List times = hourly['time'];

    print("✅ Weather API loaded in ${stopwatch.elapsedMilliseconds} ms");
    print("✅ Weather API response keys: ${hourly.keys}");

    // Smart indexing to avoid heavy parsing
    final now = DateTime.now();
    final nowPrefix = now.toIso8601String().substring(0, 13); // "2025-06-18T09"
    int idxNow = times.indexWhere((t) => t.toString().startsWith(nowPrefix));
    if (idxNow == -1) idxNow = 0;

    final List<Map<String, dynamic>> result = [];
    for (int i = 0; i < 3; i++) {
      final index = idxNow + i;
      if (index >= times.length) break;

      result.add({
        "hour": DateTime.parse(times[index]).hour,
        "temp": (hourly['temperature_2m'][index] as num).toDouble(),
        "precipitationProbability":
            (hourly['precipitation_probability'][index] as num).toDouble(),
        "windSpeed": (hourly['wind_speed_10m'][index] as num).toDouble(),
        "code": hourly['weather_code'][index], // this one stays as int
      });
    }

    return result;
  }
}
