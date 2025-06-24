import 'package:flutter/material.dart';
import '../models/monitoring_model.dart';
import '../controllers/monitoring_controller.dart';
import '../widgets/custom_navbar.dart';

class MonitoringDataScreen extends StatefulWidget {
  const MonitoringDataScreen({super.key});

  @override
  State<MonitoringDataScreen> createState() => _MonitoringDataScreenState();
}

class _MonitoringDataScreenState extends State<MonitoringDataScreen> {
  final MonitoringController controller = MonitoringController();
  PlantData? plant;
  List<WeatherData> forecasts = [];
  String? error;

  @override
  void initState() {
    super.initState();

    controller.streamPlantData().listen((plantMap) {
      setState(() {
        plant = PlantData(
          humidity: plantMap['humidity'],
          tempDHT: plantMap['tempDHT'],
          tempDS: plantMap['tempDS'],
        );
      });
    });

    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weatherList = await controller.fetchWeatherForecast();
      setState(() {
        forecasts = weatherList
            .map((w) => WeatherData(
                  hour: w['hour'],
                  temp: w['temp'],
                  precipitationProbability: w['precipitationProbability'],
                  windSpeed: w['windSpeed'],
                  code: w['code'],
                ))
            .toList();
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather Forecast
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Prakiraan Cuaca", style: textStyle.titleMedium),
                      const SizedBox(height: 12),
                      forecasts.isEmpty
                          ? const Text("Loading forecast...")
                          : SizedBox(
                              height: 170,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: forecasts.length,
                                itemBuilder: (_, i) {
                                  final f = forecasts[i];
                                  final timeLabel = i == 0
                                      ? "Now"
                                      : "${f.hour.toString().padLeft(2, '0')}.00";

                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            WeatherData.getWeatherEmoji(f.code),
                                            style:
                                                const TextStyle(fontSize: 26)),
                                        const SizedBox(height: 6),
                                        Text(timeLabel,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500)),
                                        Text("${f.temp.toStringAsFixed(1)}°C",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            "💧 ${f.precipitationProbability.toStringAsFixed(0)}%",
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        Text(
                                            "🌬️ ${f.windSpeed.toStringAsFixed(1)} km/h",
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 10),
                      const Text("Data Provided by Open-Meteo",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              // Monitor Tanaman
              Text("Monitor Tanaman", style: textStyle.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCard(
                      "Kelembapan",
                      "${plant?.humidity.toStringAsFixed(1) ?? '--'}%",
                      Colors.green,
                      Icons.water_drop),
                  _buildCard(
                      "Suhu",
                      "${plant?.tempDHT.toStringAsFixed(1) ?? '--'}°C",
                      Colors.orange,
                      Icons.thermostat),
                  _buildCard(
                      "Suhu Air",
                      "${plant?.tempDS.toStringAsFixed(1) ?? '--'}°C",
                      Colors.blue,
                      Icons.thermostat_outlined),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("Data Provided by Blynk",
                    style: TextStyle(fontSize: 12, color: Colors.green)),
              ),

              const SizedBox(height: 24),

              // Histori Monitoring (static)
              Text("Histori Monitoring", style: textStyle.titleMedium),
              const SizedBox(height: 12),
              _historyCard("30 Juni 2025", plant),
              _historyCard("29 Juni 2025", plant),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/panen');
          }
        },
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(String date, PlantData? data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(date.split(" ")[0],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Suhu: ${data?.tempDHT.toStringAsFixed(1) ?? '--'}°C"),
                  Text(
                      "Kelembaban: ${data?.humidity.toStringAsFixed(1) ?? '--'}%"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
