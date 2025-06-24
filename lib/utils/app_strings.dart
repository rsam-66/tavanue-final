// This class holds all the static string constants for the Tanavue app.
// Centralizing strings makes localization easier in the future and
// helps avoid typos and inconsistencies.

class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // General
  static const enterYourEmail = 'Masukkan Email Anda';
  static const resetEmailInstruction =
      'Kami akan mengirimkan tautan untuk mengatur ulang kata sandi Anda.';
  static const sendResetLink = 'Kirim Tautan Reset';
  static const String enterValidEmail = 'Silakan masukkan email yang valid.';

  static const backToLogin = 'Kembali ke Login';
  static const checkEmail = 'Periksa Email Anda';
  static const checkEmailInstruction =
      'Kami telah mengirimkan tautan untuk mengatur ulang kata sandi Anda. Silakan periksa email Anda.';

  static const String appName = 'Tanavue';
  static const String logoDescription = 'App Logo';
  static const String illustrationDescription = 'Illustration';
  static const String iconDescription = 'Icon';
  static const String plantImageDescription = 'Image of a plant';

  // Splash & Onboarding
  static const String plantParent = 'Plant Parent';
  static const String onboardingTitle = 'Welcome to Tanavue!';
  static const String onboardingSubtitle =
      'Your personal plant care assistant. Let\'s grow together!';
  static const String getStarted = 'Get Started';

  // Login Screen
  static const String login = 'Masuk Akun';
  static const String message = 'Memasukkan Email untuk Masuk Aplikasi';
  static const String email = 'Email';
  static const String hintEmail = 'Masukkan Email Anda';
  static const String password = 'Password';
  static const String hintPassword = 'Masukkan Password Anda';
  static const String forgotPassword = 'Lupa Kata Sandi?';
  static const String forgotButton = 'Ganti'; // Clickable
  static const String dontHaveAccount = 'Belum memiliki akun? ';
  static const String signUpLink = 'Daftar'; // For the clickable part
  static const String loginFailed =
      'Login failed. Please check your credentials.';
  static const String googleLogin = "Masuk Menggunakan Akun Google";

  // Sign Up Screen
  static const String createAccount = 'Daftar Akun';
  static const String signUpMessage = 'Membuat Akun Baru';
  static const String fullName = 'Nama Lengkap';
  static const String hintFullName = 'Masukkan Nama Lengkap Anda!';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String hintConfirmPassword = 'Masukkan Kembali Password Anda';
  static const String signUp = 'Daftar';
  static const String alreadyHaveAccount = 'Sudah memiliki akun? ';
  static const String loginLink = 'Masuk'; // For the clickable part
  static const String signupSuccess = 'Akun berhasil dibuat!';
  static const String signupFailed = 'Signup failed. Please try again.';
  static const String googleSignUp = "Daftar Menggunakan Akun Google";

  // Home Screen
  static const String welcome = "Welcome";
  static const String apaCobaTitle = "Apa coba?";
  static const String apaCobaBody =
      "Ngeliatin apa bolo? blm ada apa2, adanya cinta harapan kasih dan juga iman, amiin.";
  static const String monitorTanaman = "Monitor Tanaman";
  static const String blynkData = "Data Provided by B Blynk";
  static const String kelembapan = "Kelembapan";
  static const String suhu = "Suhu";
  static const String phAir = "pH Air";
  static const String prediksiPanen = "Prediksi Panen";
  static const String home = "Home";
  static const String monitoring = "Monitoring";
  static const String panen = "Panen";

  // Plant Detail Screen
  static const String prakiraanCuaca = "Prakiraan Cuaca";
  static const String cuacaDesc = "Cuacanya sedap bolo, cerah ujan gmngtu";
  static const String accuWeatherData = "Data Provided by AccuWeather";
  static const String now = "Now";

  // Bottom Navigation
  static const String homeRoute = '/home';
  static const String monitoringRoute = '/monitoring';
  static const String panenRoute = '/panen';
  static const String navHome = 'Home';
  static const String navDiscover = 'Discover';
  static const String navScan = 'Scan';
  static const String navGarden = 'My Garden';
  static const String navProfile = 'Profile';

  static const String profileSettings = "Profil & Pengaturan";
  static const String account = "Akun";
  static const String editProfile = "Edit Profil";
  static const String editPassword = "Edit Password";
  static const String notifications = "Notifikasi";
  static const String appNotifications = "App Notifications";
  static const String others = "Lain-Lain";
  static const String help = "Help";
  static const String logout = "Keluar";

  // Added for Panen Screen features
  static const String daftarTanamanHidroponik = 'Daftar Tanaman Hidroponik';
  static const String tambahkanTanaman = 'Tambahkan Tanaman';
  static const String namaTanaman = 'Nama Tanaman';
  static const String durasiPanen = 'Durasi Panen';
  static const String uploadFoto = 'Upload Foto';
  static const String klikDisini = 'Klik Disini';
}
