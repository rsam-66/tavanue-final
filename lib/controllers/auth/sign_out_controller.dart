import 'package:firebase_auth/firebase_auth.dart';

class SignOutController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    print("🚪 Signing out user: ${_auth.currentUser?.email}");
    await _auth.signOut();
    print("✅ Sign out success");
  }

  User? get currentUser => _auth.currentUser;
}
