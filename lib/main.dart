import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Tambahkan import ini
import 'firebase_options.dart';

// Import semua screen yang akan digunakan dalam rute navigasi
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/panen_screen.dart';
import 'screens/profile_page.dart';

void main() async {
  // Inisialisasi Firebase, tidak ada perubahan di sini
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- PENAMBAHAN LOGIKA AUTO SIGN-IN ---
  // Periksa apakah ada pengguna yang sedang login saat aplikasi dimulai.
  // FirebaseAuth.instance.currentUser akan berisi objek User jika ada sesi yang aktif,
  // dan akan null jika tidak ada.
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Tentukan rute awal berdasarkan status login pengguna
  final String initialRoute = currentUser == null ? '/login' : '/home';
  // Jika currentUser null -> arahkan ke '/login'
  // Jika currentUser tidak null -> arahkan ke '/home'

  // Jalankan aplikasi dengan rute awal yang sudah ditentukan
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  // Tambahkan variabel untuk menampung initialRoute
  final String initialRoute;

  // Modifikasi constructor untuk menerima initialRoute
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tanavue',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),

      // Gunakan variabel initialRoute yang sudah ditentukan di fungsi main
      initialRoute: initialRoute,

      // Definisi rute Anda tetap sama dan tidak diubah
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/monitoring': (context) => const MonitoringDataScreen(),
        '/panen': (context) => const PanenScreen(),
        '/profile': (context) => const ProfileSettingsScreen(),
      },
    );
  }
}
