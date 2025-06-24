import 'package:flutter/material.dart';
import '../models/panen_model.dart';

class PanenPredictionItem extends StatelessWidget {
  final PanenPrediction item;

  const PanenPredictionItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(item.title),
        trailing: Text(item.duration),
      ),
    );
  }
}
