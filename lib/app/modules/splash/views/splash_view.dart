import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/home');
    });

    return Scaffold(
      backgroundColor: Colors.orange.shade600,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Logo with soft container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              // App Name
              const Text(
                "PSBU News",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                "Preah Sihamoniraja Buddhist University",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 40),

              // Modern Loader
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
