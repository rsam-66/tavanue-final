// ignore_for_file: avoid_print, deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../models/panen_model.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/panen_prediction_item.dart';
import 'package:tanavue/utils/app_colors.dart'; // Added import
import 'package:tanavue/utils/app_strings.dart'; // Added import

// Firebase imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File operations
import 'package:firebase_auth/firebase_auth.dart'; // NEW: Firebase Auth for anonymous sign-in

class PanenScreen extends StatefulWidget {
  const PanenScreen({super.key});

  @override
  _PanenScreenState createState() => _PanenScreenState();
}

class _PanenScreenState extends State<PanenScreen> {
  final HomeController controller = HomeController();
  List<PanenPrediction> predictions = [];
  String? heroImageUrl; // To store the URL for the hero image
  PanenPrediction? heroPlant; // To store the data for the hero plant

  // Controllers for the "Add Plant" form
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _harvestDurationController =
      TextEditingController();
  File? _selectedImage; // To hold the selected image file

  @override
  void initState() {
    super.initState();
    _signInAnonymously(); // NEW: Sign in anonymously
    _loadPrediksiPanen();
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _harvestDurationController.dispose();
    super.dispose();
  }

  // NEW: Anonymous sign-in to provide an auth context
  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print('[FirebaseAuth] Signed in anonymously.');
    } catch (e) {
      print('[FirebaseAuth] Error signing in anonymously: $e');
      // Potentially show an error to the user if auth is critical for app function
    }
  }

  Future<void> _loadPrediksiPanen() async {
    print('[_loadPrediksiPanen] Fetching panen predictions...');
    final result = await controller.fetchPanenPredictions();
    if (!mounted) {
      print('[_loadPrediksiPanen] Widget not mounted, returning.');
      return; // Prevent setState on disposed widget
    }

    setState(() {
      predictions = result;
      print(
          '[_loadPrediksiPanen] Predictions loaded: ${predictions.length} items.');
      // Determine the hero plant: perhaps the first one or the one closest to harvest
      if (predictions.isNotEmpty) {
        // For simplicity, let's make the first prediction the hero plant
        // In a real app, you might have logic to pick the "main" plant.
        heroPlant = predictions.first;
        // The imageUrl from PanenPrediction should be the Storage path
        _fetchHeroImage(heroPlant!.imageUrl); // Fetch its image
        print('[_loadPrediksiPanen] Hero plant set: ${heroPlant?.title}');
      } else {
        heroPlant = null;
        heroImageUrl = null;
        print('[_loadPrediksiPanen] No predictions found, hero plant is null.');
      }
    });
  }

  // Updated to handle imageRef as a path (not a full URL) and handle empty paths
  Future<void> _fetchHeroImage(String imageRef) async {
    print('[_fetchHeroImage] Attempting to fetch image for path: $imageRef');
    if (imageRef.isEmpty) {
      // <-- IMPORTANT: Added check for empty imageRef
      print(
          '[_fetchHeroImage] imageRef is empty. Setting heroImageUrl to null.');
      if (!mounted) return;
      setState(() {
        heroImageUrl = null; // Prevent attempting to load an empty URL
      });
      return;
    }

    try {
      // Check if imageRef is already a full URL (from older data or direct link)
      if (imageRef.startsWith('http://') || imageRef.startsWith('https://')) {
        print(
            '[_fetchHeroImage] imageRef is already a full URL. Using directly.');
        if (!mounted) return;
        setState(() {
          heroImageUrl = imageRef;
        });
      } else {
        // Assume it's a storage path and get download URL
        final ref = FirebaseStorage.instance.ref().child(imageRef);
        final url = await ref.getDownloadURL();
        if (!mounted) return;
        setState(() {
          heroImageUrl = url;
          print('[_fetchHeroImage] Hero image URL obtained: $heroImageUrl');
        });
      }
    } catch (e) {
      print('[_fetchHeroImage] Error fetching hero image: $e');
      if (!mounted) return;
      setState(() {
        heroImageUrl = null; // Set to null on error to show fallback
      });
    }
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    print('[_pickImage] Initiating image picker...');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        print('[_pickImage] Image selected: ${_selectedImage?.path}');
      });
    } else {
      print('[_pickImage] No image selected.');
    }
  }

  // Function to add a new plant to Firestore and Storage
  Future<void> _addNewPlant() async {
    print('[_addNewPlant] Attempting to add new plant...');
    if (_plantNameController.text.isEmpty ||
        _harvestDurationController.text.isEmpty ||
        _selectedImage == null) {
      print('[_addNewPlant] Validation failed: Missing fields or image.');
      // Show a simple snackbar message (instead of alert)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('[_addNewPlant] Showing loading snackbar...');
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adding plant...'),
          duration: Duration(seconds: 2),
        ),
      );

      // 1. Upload image to Firebase Storage
      final storagePath =
          'tanaman/${DateTime.now().millisecondsSinceEpoch}_${_plantNameController.text}.jpg';
      print('[_addNewPlant] Uploading image to Storage path: $storagePath');
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = storageRef.putFile(_selectedImage!);
      await uploadTask.whenComplete(() {}); // Wait for upload to complete
      print('[_addNewPlant] Image upload task completed.');

      print('[_addNewPlant] Image uploaded. Storing data to Firestore...');
      // 2. Add data to Firestore
      await FirebaseFirestore.instance.collection('tanaman').add({
        'namaTanaman': _plantNameController.text,
        'sisaBulan': extractBulan(_harvestDurationController.text),
        'sisaHari': extractHari(_harvestDurationController.text),
        'imageRef': storageRef.fullPath,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('[_addNewPlant] Plant data added to Firestore. Clearing form...');
      // Clear the form fields and image
      _plantNameController.clear();
      _harvestDurationController.clear();
      setState(() {
        _selectedImage = null;
      });

      // Refresh the list of predictions
      print('[_addNewPlant] Refreshing plant list...');
      await _loadPrediksiPanen();

      if (!mounted) {
        print(
            '[_addNewPlant] Widget not mounted after adding plant, returning.');
        return;
      }
      // Dismiss the loading snackbar and show success
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plant added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      print('[_addNewPlant] Plant added successfully, closing dialog.');
      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      print('[_addNewPlant] Error adding new plant: $e');
      if (!mounted) {
        print(
            '[_addNewPlant] Widget not mounted during error handling, returning.');
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add plant: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to show the "Add Plant" modal
  void _showAddPlantModal(BuildContext context) {
    print('[_showAddPlantModal] Attempting to show add plant modal...');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background, // Match screen background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero, // Remove default padding
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    AppStrings.tambahkanTanaman, // "Tambahkan Tanaman"
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black, // Adjust color if needed
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _plantNameController,
                        decoration: InputDecoration(
                          hintText: AppStrings.namaTanaman, // "Nama Tanaman"
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _harvestDurationController,
                        decoration: InputDecoration(
                          hintText: AppStrings.durasiPanen, // "Durasi Panen"
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              if (_selectedImage == null)
                                const Column(
                                  children: [
                                    Icon(Icons.cloud_upload_outlined,
                                        size: 48, color: Colors.grey),
                                    Text(
                                      AppStrings.uploadFoto, // "Upload Foto"
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      AppStrings.klikDisini, // "Klik Disini"
                                      style: TextStyle(
                                          color: AppColors
                                              .primary), // Using AppColors.primary
                                    ),
                                  ],
                                )
                              else
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    height: 100, // Adjust size as needed
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addNewPlant,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary, // Using AppColors.primary
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            AppStrings.tambahkanTanaman, // "Tambahkan Tanaman"
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header for "Daftar Tanaman Hidroponik"
              Text(
                AppStrings
                    .daftarTanamanHidroponik, // "Daftar Tanaman Hidroponik"
                style: textStyle.titleMedium,
              ),
              const SizedBox(height: 16),
              // Hero Image Section
              if (heroPlant != null && heroImageUrl != null)
                Container(
                  width: double.infinity,
                  height: 180, // Height as per design
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200], // Placeholder color
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          heroImageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Text(
                          heroPlant?.title ??
                              '', // Null-aware access with fallback
                          style: textStyle.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Text(
                          heroPlant?.duration ??
                              '', // Null-aware access with fallback
                          style: textStyle.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (heroPlant != null && heroImageUrl == null)
                // Show a loading indicator if heroPlant is available but image is still loading
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else
                // Fallback if no hero plant data is available
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                  ),
                  child: const Center(
                    child: Text('No main plant to display. Add one!'),
                  ),
                ),
              const SizedBox(height: 24),
              // Prediksi Panen
              Text(
                AppStrings.prediksiPanen,
                style: textStyle.titleMedium,
              ),
              const SizedBox(height: 8),
              // Use FutureBuilder to display PanenPredictionItem only when predictions are loaded
              ...predictions.map((item) => PanenPredictionItem(item: item)),
              const SizedBox(height: 24),
              // Tambahkan Tanaman Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('[Button] Tambahkan Tanaman pressed.');
                    _showAddPlantModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary, // Using AppColors.primary
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    AppStrings.tambahkanTanaman, // "Tambahkan Tanaman"
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Space below the button
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: CustomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppStrings.homeRoute);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, AppStrings.monitoringRoute);
          }
        },
      ),
    );
  }
}

String extractBulan(String input) {
  final match = RegExp(r'(\d+)\s*Bulan').firstMatch(input);
  return match != null ? '${match.group(1)} Bulan' : '';
}

String extractHari(String input) {
  final match = RegExp(r'(\d+)\s*Hari').firstMatch(input);
  return match != null ? '${match.group(1)} Hari' : '';
}

Widget buildPlantCard(Map<String, dynamic> plant) {
  if (plant['sisaHari'] == 'Panen Hari Ini! Cek Tanaman Kamu!') {
    return Card(
      color: Colors.green[50],
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.agriculture, color: Colors.green),
        title: Text(
          '🌾 Panen Hari Ini!',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        subtitle: Text('Tanaman: ${plant['namaTanaman']}'),
      ),
    );
  } else {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(plant['namaTanaman']),
        subtitle: Text('${plant['sisaBulan']} • ${plant['sisaHari']}'),
      ),
    );
  }
}
