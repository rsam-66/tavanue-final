import 'package:cloud_firestore/cloud_firestore.dart'; // Required for DocumentSnapshot

class PanenPrediction {
  final String title;
  final String duration;
  final String imageUrl; // This should store the Storage path

  PanenPrediction({
    required this.title,
    required this.duration,
    required this.imageUrl,
  });

  // Factory constructor to create PanenPrediction from Firestore document
  factory PanenPrediction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String parsedTitle = data['namaTanaman'] ?? data['name'] ?? 'Unknown Plant';

    // Combine sisaBulan and sisaHari
    String bulan = data['sisaBulan'] ?? '';
    String hari = data['sisaHari'] ?? '';
    String parsedDuration = [bulan, hari].where((e) => e.isNotEmpty).join(' ');

    String imagePath = data['imageRef'] ?? data['imageUrl'] ?? '';

    return PanenPrediction(
      title: parsedTitle,
      duration: parsedDuration,
      imageUrl: imagePath,
    );
  }
}
