import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Ditambahkan

  /// Mendaftarkan pengguna baru dengan email, password, dan nama.
  /// Jika berhasil, akan membuat data di Auth dan dokumen di Firestore.
  /// Mengembalikan objek User jika sukses, atau melempar Exception jika gagal.
  Future<User?> signUp({
    required String email,
    required String password,
    required String name, // Ditambahkan
  }) async {
    // Validasi sederhana agar nama tidak kosong
    if (name.isEmpty) {
      throw Exception('Nama tidak boleh kosong.');
    }

    try {
      print("📝 Mencoba mendaftar: $email");

      // LANGKAH 1: Membuat user di Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Gagal membuat user, coba lagi.');
      }

      print("✅ Autentikasi sukses untuk UID: ${user.uid}");

      // LANGKAH 2: Membuat dokumen profil di Cloud Firestore
      print("Firestore: Membuat profil untuk ${user.uid}");
      await _db.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'profilePictureUrl': null, // Nilai awal untuk foto profil
        'createdAt': FieldValue.serverTimestamp(), // Waktu pendaftaran
      });
      print("✅ Profil di Firestore berhasil dibuat!");

      // Opsional tapi bagus: update display name di sistem Auth itu sendiri
      await user.updateDisplayName(name);

      return user; // Kembalikan objek user jika semua proses berhasil
    } on FirebaseAuthException catch (e) {
      print("❌ Gagal mendaftar (Auth): ${e.code} - ${e.message}");
      // Menggunakan kembali fungsi helper Anda yang sudah bagus
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // Menangkap error lain, seperti validasi nama di atas
      print("❌ Gagal mendaftar (Umum): $e");
      throw Exception(e.toString());
    }
  }

  /// Fungsi helper Anda untuk menerjemahkan kode error (TETAP SAMA)
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      default:
        return e.message ?? 'Terjadi kesalahan tidak diketahui.';
    }
  }
}
