import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Tambahkan import ini
import 'firebase_options.dart';

import 'firebase_options.dart';
import 'backend/server.dart';
import 'screens/home_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/panen_screen.dart';
import 'screens/profile_page.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/check_email_screen.dart';
import 'screens/forgot_password.dart';
import 'utils/custom_page_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final server = BackendServer();
  await server.startServer();

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
      title: 'Tanavue 2.1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ), // Gunakan variabel initialRoute yang sudah ditentukan di fungsi main
      initialRoute: initialRoute,

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/profile': (context) => const ProfileSettingsScreen(),
        // DO NOT put /home, /monitoring, /panen here
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/check-email') {
          final email = settings.arguments as String?;
          if (email != null) {
            return MaterialPageRoute(
              builder: (_) => CheckEmailScreen(email: email),
            );
          }
        }

        switch (settings.name) {
          case '/monitoring':
            return FadePageRoute(page: const MonitoringDataScreen());
          case '/panen':
            return FadePageRoute(page: const PanenScreen());
          default:
            return FadePageRoute(page: const HomeScreen());
        }
      },
    );
  }
}
