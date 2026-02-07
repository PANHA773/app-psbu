import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../auth/controllers/auth_controller.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;

  void login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading(true);
        final response = await AuthService.login(
          emailController.text,
          passwordController.text,
        );

        if (response.statusCode == 200 && response.data['token'] != null) {
          await AuthService.saveToken(response.data['token']);

          // Update AuthController state
          try {
            await Get.find<AuthController>().checkLogin();
          } catch (_) {}

          Get.offAllNamed('/home');
        } else {
          throw Exception('Login failed. Please check your credentials.');
        }
      } on DioException catch (e) {
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
}
