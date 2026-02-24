import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/app_colors.dart';
import '../controllers/call_controller.dart';

class VideoCallView extends StatefulWidget {
  const VideoCallView({super.key});

  @override
  State<VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<VideoCallView>
    with SingleTickerProviderStateMixin {
  late final CallController controller;
  late final AnimationController _controlsFadeController;
  bool _showControls = true;
  Offset _pipOffset = const Offset(16, 80);
  late final Map<String, dynamic> args;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CallController>();

    _controlsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );

    args = Get.arguments as Map<String, dynamic>? ?? {};
    final userName = args['userName'] ?? 'Unknown';
    final videoCall = args['videoCall'] ?? true;

    controller.startCall(
      targetUserId: args['userId'] ?? '',
      targetUserName: userName,
      videoCall: videoCall,
    );

    // Auto-hide controls after 5 seconds
    Future.delayed(const Duration(seconds: 5), _hideControls);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _controlsFadeController.forward();
      Future.delayed(const Duration(seconds: 5), _hideControls);
    } else {
      _controlsFadeController.reverse();
    }
  }

  void _hideControls() {
    if (_showControls && mounted) {
      setState(() => _showControls = false);
      _controlsFadeController.reverse();
    }
  }

  @override
  void dispose() {
    _controlsFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final userName = args['userName'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // ── Remote video (full screen) ────────────
            Obx(() {
              if (controller.isJoined.value) {
                return RTCVideoView(
                  controller.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                );
              }

              // Waiting for remote user
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1a1a2e), Color(0xFF0a0a0a)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white38,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.isJoined.value ? 'Connected' : 'Calling...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ── Local camera PIP ──────────────────────
            Positioned(
              left: _pipOffset.dx,
              top: _pipOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _pipOffset = Offset(
                      (_pipOffset.dx + details.delta.dx).clamp(
                        0.0,
                        MediaQuery.of(context).size.width - 130,
                      ),
                      (_pipOffset.dy + details.delta.dy).clamp(
                        0.0,
                        MediaQuery.of(context).size.height - 180,
                      ),
                    );
                  });
                },
                child: Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 120,
                    height: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a1a),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: controller.isCameraOff.value
                          ? Center(
                              child: Icon(
                                Icons.videocam_off,
                                color: Colors.white24,
                                size: 32,
                              ),
                            )
                          : RTCVideoView(
                              controller.localRenderer,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Top bar with status ───────────────────
            FadeTransition(
              opacity: _controlsFadeController,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => controller.endCall(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: controller.isJoined.value
                                    ? const Color(0xFF00E676)
                                    : Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.isJoined.value
                                  ? controller.formattedDuration
                                  : 'Connecting...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // ── Bottom controls ───────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _controlsFadeController,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: controller.isMuted.value
                              ? Icons.mic_off
                              : Iconsax.microphone,
                          isActive: controller.isMuted.value,
                          onTap: controller.toggleMute,
                        ),
                        _buildControlButton(
                          icon: controller.isCameraOff.value
                              ? Icons.videocam_off
                              : Iconsax.video,
                          isActive: controller.isCameraOff.value,
                          onTap: controller.toggleCamera,
                        ),
                        _buildEndCallButton(),
                        _buildControlButton(
                          icon: Iconsax.refresh,
                          isActive: false,
                          onTap: controller.switchCamera,
                        ),
                        _buildControlButton(
                          icon: controller.isSpeakerOn.value
                              ? Iconsax.volume_high
                              : Icons.volume_off,
                          isActive: controller.isSpeakerOn.value,
                          onTap: controller.toggleSpeaker,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(isActive ? 0.35 : 0.12),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () => controller.endCall(),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4757).withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.call_end_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
