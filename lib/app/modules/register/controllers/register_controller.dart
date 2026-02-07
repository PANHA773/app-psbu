import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;

  void register() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading(true);
        await AuthService.register(
          nameController.text,
          emailController.text,
          passwordController.text,
        );
        Get.offAllNamed('/home');
        Get.snackbar('Success', 'Registration successful! You are now logged in.');
      } catch (e) {
        String errorMessage = 'Registration failed. Please try again.';
        if (e is DioException) {
          if (e.response?.data is Map && e.response?.data['message'] != null) {
            errorMessage = e.response?.data['message'];
          } else if (e.message != null) {
            errorMessage = e.message!;
          }
        }
        Get.snackbar('Error', errorMessage);
      } finally {
        isLoading(false);
      }
    }
  }
}
