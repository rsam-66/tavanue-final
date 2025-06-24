import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordReset({
    required String email,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      onSuccess();
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? "Something went wrong.";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
