import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/news_model.dart';

class NewsController {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Future<List<NewsItem>> fetchNews() async {
    final querySnapshot = await firestore.collection('berita').get();
    final List<NewsItem> news = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final imageRef = data['imageRef'] as String? ?? '';
      final imageUrl = imageRef.isNotEmpty
          ? await storage.ref(imageRef.trim()).getDownloadURL()
          : 'https://via.placeholder.com/300x150';

      news.add(NewsItem.fromMap({
        ...data,
        'imageRef': imageUrl,
      }));
    }

    return news;
  }
}
