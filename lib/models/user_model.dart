// models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePictureUrl; // <-- TAMBAHKAN FIELD INI

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePictureUrl, // <-- TAMBAHKAN DI CONSTRUCTOR
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl, // <-- TAMBAHKAN DI MAP
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePictureUrl: map['profilePictureUrl'], // <-- AMBIL DARI MAP
    );
  }
}
