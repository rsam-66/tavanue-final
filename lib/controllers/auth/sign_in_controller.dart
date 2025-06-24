import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Untuk menangani kasus web

class SignInController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Mendapatkan status autentikasi pengguna saat ini (untuk auto sign-in)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Fungsi untuk sign in menggunakan Email dan Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      print("🔐 Trying to sign in with email: $email");
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("✅ Email login success: ${cred.user?.uid}");
      return cred.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Email login failed: ${e.code} - ${e.message}");
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception('Email atau password salah. Silakan coba lagi.');
      }
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Fungsi untuk sign in menggunakan Akun Google
  Future<User?> signInWithGoogle() async {
    try {
      print("🔐 Trying to sign in with Google");

      // Memulai proses sign in Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Pengguna membatalkan proses sign-in
        print("❌ Google sign in cancelled by user.");
        return null;
      }

      // Mendapatkan detail autentikasi dari request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Membuat kredensial baru untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in ke Firebase dengan kredensial Google
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print("✅ Google login success: ${userCredential.user?.uid}");

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Google login failed: ${e.code} - ${e.message}");
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      print("❌ An unexpected error occurred during Google sign in: $e");
      throw Exception('Terjadi kesalahan saat mencoba masuk dengan Google.');
    }
  }

  /// Fungsi untuk sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    print("👋 User signed out");
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'account-exists-with-different-credential':
        return 'Akun sudah ada dengan metode masuk yang berbeda.';
      default:
        return e.message ?? 'Terjadi kesalahan tidak diketahui.';
    }
  }
}
