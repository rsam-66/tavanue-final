import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/panen_model.dart';

class HomeController {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Future<List<PanenPrediction>> fetchPanenPredictions() async {
    final querySnapshot = await firestore.collection('tanaman').get();
    final List<PanenPrediction> predictions = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final imageRef = data['imageRef'] as String? ?? "";
      final imageUrl = imageRef.isNotEmpty
          ? await storage.ref(imageRef.trim()).getDownloadURL()
          : "https://via.placeholder.com/48";

      final duration =
          "${data['sisaBulan'] ?? ''} ${data['sisaHari'] ?? ''}".trim();

      predictions.add(PanenPrediction(
        title: data['namaTanaman'] ?? 'Tanaman',
        duration: duration,
        imageUrl: imageUrl,
      ));
    }

    return predictions;
  }
}
