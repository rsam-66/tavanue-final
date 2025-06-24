import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tanavue/controllers/auth/sign_up_controller.dart';

// --- GANTI DENGAN PATH YANG BENAR ---
import '../controllers/auth/sign_up_controller.dart'; // <-- BENAR // DIUBAH untuk konsistensi
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- STATE & CONTROLLERS ---
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _signUpController = SignUpController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  Future<void> _signUpUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // =================================================================
      // --- PERUBAHAN DI SINI: Memanggil fungsi signUp yang baru ---
      // =================================================================
      final user = await _signUpController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _fullNameController.text.trim(), // <-- PARAMETER NAMA DITAMBAHKAN
      );

      if (!mounted) return;

      if (user != null) {
        // Komentar TODO sudah tidak relevan karena controller sudah melakukannya
        _showSuccessSnackBar("Pendaftaran berhasil!");

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Mengambil pesan error dari Exception yang kita lempar di controller
        _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ... Sisa kode Anda (semua _build... method) tetap sama persis ...
  // Anda tidak perlu mengubah apapun di bawah ini.
  // Pastikan Anda menyalin seluruh sisa kode dari file asli Anda ke sini
  // jika Anda tidak mengganti seluruh file.

  // --- UI HELPER METHODS ---
  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    // ... (kode Anda)
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: AppColors.primary),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildFormFields(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER METHODS ---
  Widget _buildHeader() {
    // ... (kode Anda)
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_tanavue.png', // Sesuaikan path jika perlu
          height: 150,
        ),
        const SizedBox(height: 20),
        Text(
          "Buat Akun", // Ganti dengan AppStrings jika perlu
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          "Isi data di bawah untuk membuat akun baru.", // Ganti dengan AppStrings jika perlu
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    // ... (kode Anda)
    return Column(
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: _buildInputDecoration(
            labelText: "Nama Lengkap",
            hintText: "Masukkan nama lengkap Anda",
            prefixIcon: Icons.person_outline,
          ),
          keyboardType: TextInputType.name,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Nama lengkap tidak boleh kosong'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: _buildInputDecoration(
            labelText: "Email",
            hintText: "Masukkan email Anda",
            prefixIcon: Icons.email_outlined,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => (value == null || !value.contains('@'))
              ? 'Masukkan email yang valid'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _buildInputDecoration(
            labelText: "Password",
            hintText: "Masukkan password",
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) => (value == null || value.length < 6)
              ? 'Password minimal 6 karakter'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: _buildInputDecoration(
            labelText: "Konfirmasi Password",
            hintText: "Ulangi password",
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Password tidak cocok';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // ... (kode Anda)
    return ElevatedButton(
      onPressed: _isLoading ? null : _signUpUser,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Daftar"),
    );
  }

  Widget _buildFooter() {
    // ... (kode Anda)
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Sudah punya akun? ",
          style: Theme.of(context).textTheme.bodyMedium,
          children: <TextSpan>[
            TextSpan(
              text: "Masuk",
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (!_isLoading) {
                    Navigator.of(context).pop();
                  }
                },
            ),
          ],
        ),
      ),
    );
  }
}
