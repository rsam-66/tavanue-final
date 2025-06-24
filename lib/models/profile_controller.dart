// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'user_model.dart'; // Pastikan path ini benar

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<UserModel?> getProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  Future<String?> updateProfileData(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not found. Please log in again.';

      // Update name di Firestore
      await _db.collection('users').doc(user.uid).update({'name': name});

      // Update name di profil Firebase Auth
      await user.updateDisplayName(name);

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return 'User not found. Please log in again.';
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'The current password you entered is incorrect.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // =======================================================================
  // --- INI FUNGSI YANG SUDAH DIPERBAIKI ---
  // =======================================================================
  Future<String?> uploadProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not found.';

      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return null; // User membatalkan pemilihan

      // Buat nama file yang lebih generik. Kita bisa menimpa foto profil lama.
      String fileName = 'profile.jpg';

      // Buat path yang BENAR sesuai ATURAN BARU: /profile_pictures/{userId}/{fileName}
      final ref = _storage
          .ref()
          .child('profile_pictures') // Folder utama
          .child(user.uid) // Folder khusus untuk user ini
          .child(fileName); // Nama file di dalam folder user

      // --- BARIS DEBUGGING ---
      // Baris ini akan mencetak path yang sebenarnya ke konsol Anda
      print("DEBUG: Mencoba upload ke path Storage: ${ref.fullPath}");
      // ----------------------

      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _db
          .collection('users')
          .doc(user.uid)
          .update({'profilePictureUrl': downloadUrl});
      await user.updatePhotoURL(downloadUrl);

      return null; // Sukses
    } on FirebaseException catch (e) {
      print("ERROR FIREBASE: ${e.code} - ${e.message}");
      return e.message;
    } catch (e) {
      print("ERROR UMUM: ${e.toString()}");
      return e.toString();
    }
  }
  // =======================================================================
  // --- AKHIR DARI FUNGSI YANG DIPERBAIKI ---
  // =======================================================================

  Future<void> logout() async {
    await _auth.signOut();
  }
}
