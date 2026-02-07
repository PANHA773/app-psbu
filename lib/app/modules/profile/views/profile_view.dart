import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../../core/app_colors.dart';
import '../../../config.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () =>
                _showEditProfileDialog(context, _authController.user.value!),
          ),
        ],
      ),
      body: Obx(() {
        final user = _authController.user.value;
        if (user == null) {
          return const Center(
            child: Text('No user data available. Please login first.'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Avatar + Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.2,
                      ),
                      backgroundImage:
                          (user.avatar != null && user.avatar!.isNotEmpty)
                          ? NetworkImage(
                              user.avatar!.startsWith('http')
                                  ? AppConfig.transformUrl(user.avatar!)
                                  : '${AppConfig.imageUrl}/${user.avatar}',
                            )
                          : null,
                      child: (user.avatar == null || user.avatar!.isEmpty)
                          ? Text(
                              user.name.isNotEmpty ? user.name[0] : '?',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Account Info
              _buildCard(
                title: 'Account Information',
                children: [
                  _buildInfoRow('Email', user.email),
                  _buildInfoRow('Role', user.role),
                  if (user.gender != null && user.gender!.isNotEmpty)
                    _buildInfoRow('Gender', user.gender!),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    _buildInfoRow('Bio', user.bio!),
                  _buildInfoRow('Language', user.settings.language),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Preferences
              _buildCard(
                title: 'Preferences',
                children: [
                  _buildSwitchRow('Dark Mode', user.settings.darkMode, (val) {
                    print('DarkMode toggled: $val');
                  }),
                  _buildSwitchRow(
                    'Email Notifications',
                    user.settings.emailNotifications,
                    (val) {
                      print('Email Notifications: $val');
                    },
                  ),
                  _buildSwitchRow(
                    'Push Notifications',
                    user.settings.pushNotifications,
                    (val) {
                      print('Push Notifications: $val');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Logout Button
              _buildCard(
                title: 'Account Actions',
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ================= HELPERS =================

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, user) {
    final TextEditingController nameController = TextEditingController(
      text: user.name,
    );
    _profileController.selectedImage.value = null; // Reset

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar edit
              GestureDetector(
                onTap: () => _profileController.pickImage(),
                child: Obx(() {
                  final pickedImage = _profileController.selectedImage.value;
                  ImageProvider? bgImage;
                  if (pickedImage != null) {
                    bgImage = FileImage(pickedImage);
                  } else if (user.avatar != null && user.avatar!.isNotEmpty) {
                    bgImage = NetworkImage(user.avatar!);
                  }

                  return CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: bgImage,
                    child: bgImage == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.grey,
                          )
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap image to change',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _profileController.updateUserProfile(nameController.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Confirm Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access your account.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _authController.logout(); // Perform logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
