import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';

class PanenScreen extends StatelessWidget {
  const PanenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panen')),
      body: const Center(
        child: Text(
          'Catat hasil panen kamu di sini!',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/monitoring');
          }
        },
      ),
    );
  }
}
