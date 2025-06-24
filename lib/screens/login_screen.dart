import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// Pastikan path ke controller Anda sudah benar
import 'package:tanavue/controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // --- PENYESUAIAN --- Controller di-final agar tidak bisa diubah setelah inisialisasi
  final SignInController _signInController = SignInController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _loginUser() async {
    // Validasi form
    if (_formKey.currentState?.validate() ?? false) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      print('🔐 Login attempt: $email');

      try {
        final user = await _signInController.signInWithEmail(email, password);
        // --- PENYESUAIAN --- Gunakan pengecekan 'mounted'
        if (user != null && mounted) {
          print('✅ Login success: ${user.email}');
          // Gunakan navigasi bernama agar konsisten dengan setup di main.dart
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        print('❌ Login failed: $e');
        // --- PENYESUAIAN --- Gunakan pengecekan 'mounted'
        if (mounted) {
          _showErrorDialog(e.toString());
        }
      }
    }
  }

  // --- TAMBAHAN --- Fungsi baru untuk menangani Login dengan Google
  void _loginWithGoogle() async {
    print('🔐 Google Login attempt');
    try {
      final user = await _signInController.signInWithGoogle();
      // Jika user tidak null (login berhasil) dan widget masih ada di tree
      if (user != null && mounted) {
        print('✅ Google Login success: ${user.email}');
        Navigator.of(context).pushReplacementNamed('/home');
      }
      // Jika user null (misalnya pengguna membatalkan), tidak perlu melakukan apa-apa
    } catch (e) {
      // --- INI BARIS YANG BERBEDA DAN SANGAT PENTING ---
      print('❌❌❌ GOOGLE SIGN IN FAILED - SPECIFIC ERROR: $e');

      if (mounted) {
        // Dialog ini akan tetap menampilkan pesan, tapi kita butuh yang di console
        _showErrorDialog(e.toString());
      }
    }
  }

  // --- TAMBAHAN --- Helper function untuk menampilkan dialog error agar tidak duplikat kode
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Gagal"),
        content: Text(message.replaceAll('Exception:', '').trim()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48, // Padding vertikal total
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: screenHeight * 0.01),
                    Center(
                      child: Image.asset(
                        'assets/images/logo_tanavue.png',
                        width: 180,
                        height: 180,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.eco,
                              size: 80, color: AppColors.primary);
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      AppStrings.login,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: AppStrings.hintEmail,
                        prefixIcon: const Icon(Icons.person_outline,
                            color: AppColors.iconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20.0),
                      ),
                      keyboardType:
                          TextInputType.emailAddress, // Lebih spesifik
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Email Anda';
                        }
                        // Validasi format email sederhana
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Masukkan format email yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        hintText: AppStrings.hintPassword,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.iconColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.iconColor,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20.0),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Password Anda';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                          text: AppStrings.forgotPassword,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          children: <TextSpan>[
                            TextSpan(
                              text: " ${AppStrings.forgotButton}",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                      context, '/forgot-password');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loginUser,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('Masuk'),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: AppStrings.dontHaveAccount,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          children: <TextSpan>[
                            TextSpan(
                              text: AppStrings.signUpLink,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushNamed('/signup');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 0.8,
                            endIndent: 10,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "atau",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 0.8,
                            indent: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // --- PENYESUAIAN --- Hubungkan tombol ke fungsi _loginWithGoogle
                    ElevatedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset(
                        'assets/images/logo_google.png',
                        height: 20.0,
                        width: 20.0,
                      ),
                      label: const Text(AppStrings.googleLogin),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 1,
                          side:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
