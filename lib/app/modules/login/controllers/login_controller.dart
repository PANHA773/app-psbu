import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../../data/services/auth_service.dart';
import '../../auth/controllers/auth_controller.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var selectedRole = 'Student'.obs; // Default role

  final List<String> roles = ['Student', 'Teacher'];

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> _handleLoginResponse(dio.Response response) async {
    if (response.statusCode == 200 && response.data['token'] != null) {
      await AuthService.saveToken(response.data['token']);
      await AuthService.saveRole(selectedRole.value);

      // Update AuthController state
      try {
        await Get.find<AuthController>().checkLogin();
      } catch (_) {}

      Get.offAllNamed('/home');
    } else {
      throw Exception('Login failed. Please try again.');
    }
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading(true);
        final response = await AuthService.login(
          emailController.text,
          passwordController.text,
          role: selectedRole.value,
        );

        await _handleLoginResponse(response);
      } on dio.DioException catch (e) {
        final errorMsg =
            e.response?.data?['message'] ?? 'Login failed. Please try again.';
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } finally {
        isLoading(false);
      }
    }
  }

  void loginAsGuest() async {
    try {
      isLoading(true);
      await AuthService.loginAsGuest();

      // Navigate to home without token
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Guest login failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void loginWithGoogleToken(String idToken) async {
    if (idToken.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Google idToken is required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    try {
      isLoading(true);
      final response = await AuthService.loginWithGoogle(idToken.trim());
      await _handleLoginResponse(response);
    } on dio.DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Google login failed. Please try again.';
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void loginWithFacebookToken(String accessToken) async {
    if (accessToken.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Facebook accessToken is required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    try {
      isLoading(true);
      final response = await AuthService.loginWithFacebook(accessToken.trim());
      await _handleLoginResponse(response);
    } on dio.DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Facebook login failed. Please try again.';
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
