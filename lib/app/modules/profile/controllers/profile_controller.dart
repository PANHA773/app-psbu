import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  // Observable user
  Rx<UserModel?> user = Rx<UserModel?>(null);

  // Loading state
  RxBool isLoading = false.obs;

  // Error message
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  /// Load the current user profile from AuthService
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final currentUserData = await AuthService.getCurrentUser();
      if (currentUserData != null) {
        user.value = UserModel.fromJson(currentUserData);
      } else {
        errorMessage.value = 'User data is not available.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user locally and optionally send update to backend
  void updateUser(UserModel updatedUser) {
    user.value = updatedUser;
  }

  // Image Picker
  final ImagePicker _picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> updateUserProfile(String name) async {
    try {
      isLoading.value = true;
      await AuthService.updateProfile(name: name, image: selectedImage.value);

      // Refresh AuthController user
      final authController = Get.find<AuthController>();
      await authController.fetchUser();

      // Refresh local user data
      await loadUserProfile();

      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await AuthService.logout();
    user.value = null;
  }
}
