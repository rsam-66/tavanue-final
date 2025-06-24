import 'package:flutter/material.dart';

// --- GANTI DENGAN PATH YANG BENAR ---
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart'; // Sesuaikan jika perlu
import '../utils/app_strings.dart'; // Sesuaikan jika perlu

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // =================================================================
  // BAGIAN 1: State Management & Variables
  // =================================================================
  final ProfileController _controller = ProfileController();
  late Future<UserModel?> _userProfileFuture;
  bool _appNotifications = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // =================================================================
  // BAGIAN 2: Lifecycle Methods (initState, dispose)
  // =================================================================
  @override
  void initState() {
    super.initState();
    _userProfileFuture = _controller.getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =================================================================
  // BAGIAN 3: Fungsi Logika (Handlers & Dialogs)
  // =================================================================
  void _refreshProfile() {
    setState(() {
      _userProfileFuture = _controller.getProfile();
    });
  }

  Future<void> _handleProfileSave() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Name cannot be empty!")));
      return;
    }
    Navigator.of(context).pop();
    final error = await _controller.updateProfileData(_nameController.text);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")));
      _refreshProfile();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    }
  }

  Future<void> _handleChangePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New passwords do not match!")));
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Password must be at least 6 characters long.")));
      return;
    }
    Navigator.of(context).pop();
    final error = await _controller.changePassword(
      currentPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully!")));
    }
  }

  Future<void> _handleLogout() async {
    Navigator.of(context).pop(); // Tutup dialog konfirmasi dulu
    await _controller.logout();
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  Future<void> _handlePictureChange() async {
    Navigator.of(context).pop();
    final error = await _controller.uploadProfilePicture();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading picture: $error")));
    } else {
      _refreshProfile();
    }
  }

  // --- KODE DIALOG LENGKAP DIKEMBALIKAN ---
  void _showEditProfileDialog(BuildContext context, UserModel userProfile) {
    _nameController.text = userProfile.name;
    _emailController.text = userProfile.email;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop())),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _handlePictureChange,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryGreen,
                          backgroundImage: userProfile.profilePictureUrl != null
                              ? NetworkImage(userProfile.profilePictureUrl!)
                              : null,
                        ),
                        Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle)),
                        const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  color: Colors.white, size: 30),
                              Text("Change Picture",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10))
                            ])
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: "Edit Name", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: "Email", border: OutlineInputBorder()),
                    readOnly: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _handleProfileSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: const Text("Save Changes",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- KODE DIALOG LENGKAP DIKEMBALIKAN ---
  void _showChangePasswordDialog(BuildContext context) {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop()),
                    const SizedBox(width: 10),
                    const Text("Change Password",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))
                  ]),
                  const SizedBox(height: 20),
                  TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          hintText: "Enter Old Password",
                          border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          hintText: "Enter New Password",
                          border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          hintText: "Re-Enter New Password",
                          border: OutlineInputBorder())),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _handleChangePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: const Text("Change Password",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- KODE DIALOG LENGKAP DIKEMBALIKAN ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Center(child: Text("Are You Sure?")),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          content: Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"))),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.redWarning)),
                  child: const Text("Log-out",
                      style: TextStyle(color: AppColors.redWarning)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =================================================================
  // BAGIAN 4: Widget Build Utama
  // =================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Profil & Pengaturan",
            style: TextStyle(color: AppColors.darkText, fontSize: 18)),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error memuat profil: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text("Profil pengguna tidak ditemukan."));
          }
          final userProfile = snapshot.data!;
          return ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: <Widget>[
              _buildProfileHeader(userProfile),
              const SizedBox(height: 30),
              _buildSectionTitle("Akun"),
              _buildSettingsOption("Edit Profil",
                  onTap: () => _showEditProfileDialog(context, userProfile)),
              _buildSettingsOption("Edit Password",
                  onTap: () => _showChangePasswordDialog(context)),
              _buildSectionTitle("Notifikasi"),
              _buildNotificationOption("App Notifications"),
              _buildSectionTitle("Lain-Lain"),
              _buildSettingsOption("Help", onTap: () {}),
              const SizedBox(height: 40),
              _buildLogoutOption(onTap: () => _showLogoutDialog(context)),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // =================================================================
  // BAGIAN 5: Widget Helper untuk UI
  // =================================================================
  Widget _buildProfileHeader(UserModel userProfile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.greyText.withOpacity(0.2),
          backgroundImage: userProfile.profilePictureUrl != null
              ? NetworkImage(userProfile.profilePictureUrl!)
              : null,
          child: userProfile.profilePictureUrl == null
              ? const Icon(Icons.person, size: 30, color: AppColors.greyText)
              : null,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userProfile.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText)),
            Text(userProfile.email,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.greyText)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 8.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText)),
    );
  }

  Widget _buildSettingsOption(String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: onTap != null
              ? const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.greyText)
              : null,
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildNotificationOption(String title) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: Switch(
            value: _appNotifications,
            onChanged: (bool value) {
              setState(() {
                _appNotifications = value;
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildLogoutOption({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text("Keluar",
            style: TextStyle(fontSize: 15, color: AppColors.redWarning)),
      ),
    );
  }
}
