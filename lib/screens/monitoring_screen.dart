import 'package:flutter/material.dart';
import '../models/monitoring_model.dart';
import '../controllers/monitoring_controller.dart';
import '../widgets/custom_navbar.dart';
import 'dart:async';
import 'package:tanavue/utils/app_colors.dart'; // Added import
import 'package:tanavue/utils/app_strings.dart'; // Added import

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
  StreamSubscription? _plantSubscription;

  @override
  void initState() {
    super.initState();

    _plantSubscription = controller.streamPlantData().listen((plantMap) {
      if (!mounted) return; // prevent crash
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
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(
          0xFFFFF5FA), // Kept as hardcoded as no direct equivalent in AppColors to preserve design
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
                      Text(AppStrings.prakiraanCuaca,
                          style: textStyle
                              .titleMedium), // Used AppStrings.prakiraanCuaca
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
                                      ? AppStrings.now // Used AppStrings.now
                                      : "${f.hour.toString().padLeft(2, '0')}.00";

                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue
                                          .shade50, // Kept as hardcoded as no direct equivalent in AppColors to preserve design
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
                      const Text(
                          "Data Provided by Open-Meteo", // Kept as hardcoded as no direct equivalent in AppStrings
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors
                                  .greyText)), // Used AppColors.greyText
                    ],
                  ),
                ),
              ),

              // Monitor Tanaman
              Text(AppStrings.monitorTanaman,
                  style:
                      textStyle.titleMedium), // Used AppStrings.monitorTanaman
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCard(
                      AppStrings.kelembapan, // Used AppStrings.kelembapan
                      "${plant?.humidity.toStringAsFixed(1) ?? '--'}%",
                      AppColors.primaryGreen, // Used AppColors.primaryGreen
                      Icons.water_drop),
                  _buildCard(
                      AppStrings.suhu, // Used AppStrings.suhu
                      "${plant?.tempDHT.toStringAsFixed(1) ?? '--'}°C",
                      Colors
                          .orange, // Kept as Colors.orange as no direct equivalent in AppColors to preserve design
                      Icons.thermostat),
                  _buildCard(
                      "Suhu Air", // Kept as hardcoded string as no direct equivalent in AppStrings
                      "${plant?.tempDS.toStringAsFixed(1) ?? '--'}°C",
                      Colors
                          .blue, // Kept as Colors.blue as no direct equivalent in AppColors to preserve design
                      Icons.thermostat_outlined),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.blynkData, // Used AppStrings.blynkData
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary)), // Used AppColors.primary
              ),

              const SizedBox(height: 24),

              // Histori Monitoring (static)
              Text("Histori Monitoring",
                  style: textStyle
                      .titleMedium), // Kept as hardcoded as no direct equivalent in AppStrings
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
            Navigator.pushReplacementNamed(
                context, AppStrings.homeRoute); // Used AppStrings.homeRoute
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
                context, AppStrings.panenRoute); // Used AppStrings.panenRoute
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
          Icon(icon,
              color: AppColors.buttonTextWhite,
              size: 20), // Used AppColors.buttonTextWhite
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color:
                  AppColors.buttonTextWhite, // Used AppColors.buttonTextWhite
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
              color:
                  AppColors.buttonTextWhite, // Used AppColors.buttonTextWhite
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

  @override
  void dispose() {
    _plantSubscription
        ?.cancel(); // 🔥 prevents calling setState after widget is gone
    super.dispose();
  }
}
