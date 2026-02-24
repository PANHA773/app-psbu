import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_colors.dart';
import '../../../data/services/webrtc_service.dart';

class IncomingCallView extends StatelessWidget {
  const IncomingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    final WebRTCService service = Get.find<WebRTCService>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Avatar
              Obx(
                () => Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.person, size: 80, color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Name
              Obx(
                () => Text(
                  service.remoteUserName.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Text(
                  service.isAudioOnly.value
                      ? 'Incoming Voice Call...'
                      : 'Incoming Video Call...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 48,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reject Button
                    _buildOptionButton(
                      icon: Icons.call_end,
                      color: Colors.redAccent,
                      label: 'Decline',
                      onTap: () => service.rejectCall(),
                    ),
                    // Accept Button
                    _buildOptionButton(
                      icon: Icons.call,
                      color: Colors.greenAccent,
                      label: 'Accept',
                      onTap: () {
                        service.acceptCall();
                        if (service.isAudioOnly.value) {
                          Get.offNamed(
                            '/call',
                            arguments: {
                              'userId': service.remoteUserId.value,
                              'userName': service.remoteUserName.value,
                              'incoming': true,
                            },
                          );
                        } else {
                          Get.offNamed(
                            '/video-call',
                            arguments: {
                              'userId': service.remoteUserId.value,
                              'userName': service.remoteUserName.value,
                              'incoming': true,
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
