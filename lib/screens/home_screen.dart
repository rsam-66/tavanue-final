// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // --- TAMBAHAN IMPORT ---
import 'package:cloud_firestore/cloud_firestore.dart'; // --- TAMBAHAN IMPORT ---
import 'package:tanavue/screens/profile_page.dart';
import '../controllers/home_controller.dart';
import '../controllers/monitoring_controller.dart';
import '../models/panen_model.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/panen_prediction_item.dart';
import '../controllers/news_controller.dart';
import '../models/news_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = HomeController();
  final MonitoringController monitorController = MonitoringController();

  final NewsController newsController = NewsController();
  List<NewsItem> newsList = [];

  List<PanenPrediction> predictions = [];
  double humidity = 0;
  double tempDHT = 0;
  double tempDS = 0;

  @override
  void initState() {
    super.initState();
    _loadPrediksiPanen();

    newsController.fetchNews().then((items) {
      setState(() {
        newsList = items;
      });
    });

    monitorController.streamPlantData().listen((plantMap) {
      setState(() {
        humidity = plantMap['humidity'];
        tempDHT = plantMap['tempDHT'];
        tempDS = plantMap['tempDS'];
      });
    });
  }

  Future<void> _loadPrediksiPanen() async {
    final result = await controller.fetchPanenPredictions();
    setState(() => predictions = result);
  }

  // =======================================================================
  // --- WIDGET BARU UNTUK AVATAR PROFIL ---
  // =======================================================================
  Widget _buildProfileAvatar() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Jika user tidak login, tampilkan avatar default
      return const CircleAvatar(backgroundColor: Colors.green, radius: 22);
    }

    // Gunakan StreamBuilder untuk mendengarkan perubahan data user secara real-time
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Jika data belum siap, tampilkan avatar abu-abu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(backgroundColor: Colors.grey, radius: 22);
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Jika tidak ada data, tampilkan avatar default
          return const CircleAvatar(backgroundColor: Colors.green, radius: 22);
        }

        // Ambil data user
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String? imageUrl = userData['profilePictureUrl'];

        // Buat avatar bisa diklik untuk ke halaman profil
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProfileSettingsScreen()),
            );
          },
          child: CircleAvatar(
            radius: 22, // Sesuaikan ukurannya
            backgroundColor:
                Colors.green, // Warna latar jika gambar gagal dimuat
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? const Icon(Icons.person,
                    color: Colors.white, size: 28) // Ikon jika tidak ada foto
                : null,
          ),
        );
      },
    );
  }
  // =======================================================================
  // --- AKHIR DARI WIDGET BARU ---
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Welcome", style: textStyle.headlineSmall),
                  _buildProfileAvatar(), // <--- PANGGIL WIDGET BARU DI SINI
                ],
              ),
              SizedBox(
                height: 180,
                child: newsList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          final news = newsList[index];
                          return GestureDetector(
                            onTap: () => launchUrl(Uri.parse(news.url),
                                mode: LaunchMode.externalApplication),
                            child: Container(
                              width: 280,
                              margin: const EdgeInsets.only(
                                  right: 12, left: 4, top: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(news.imageRef),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.4),
                                      BlendMode.darken),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(news.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 8),
                                  Text(
                                    news.subtitle,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Monitor Tanaman
              Text("Monitor Tanaman", style: textStyle.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMonitorCard(
                      "Kelembapan",
                      "${humidity.toStringAsFixed(1)}%",
                      Colors.green,
                      Icons.water_drop),
                  _buildMonitorCard("Suhu", "${tempDHT.toStringAsFixed(1)}°C",
                      Colors.orange, Icons.thermostat),
                  _buildMonitorCard(
                      "Suhu Air",
                      "${tempDS.toStringAsFixed(1)}°C",
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

              // Prediksi Panen
              Text("Prediksi Panen", style: textStyle.titleMedium),
              const SizedBox(height: 8),
              ...predictions.map((item) => PanenPredictionItem(item: item)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/monitoring');
          }
          if (index == 2) Navigator.pushReplacementNamed(context, '/panen');
        },
      ),
    );
  }

  Widget _buildMonitorCard(
      String title, String value, Color color, IconData icon) {
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
}
