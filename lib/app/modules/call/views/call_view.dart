import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/app_colors.dart';
import '../controllers/call_controller.dart';

class CallView extends StatefulWidget {
  const CallView({super.key});

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> with TickerProviderStateMixin {
  late final CallController controller;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CallController>();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final userId = args['userId'] ?? '';
    final userName = args['userName'] ?? 'Unknown';
    final videoCall = args['videoCall'] ?? false;

    controller.startCall(
      targetUserId: userId,
      targetUserName: userName,
      videoCall: videoCall,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final userName = args['userName'] ?? 'Unknown';
    final userAvatar = args['userAvatar'] as String?;
    final fallbackUrl =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=6C63FF&color=fff&size=256';

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
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => controller.endCall(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
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
                                    ? 'Connected'
                                    : 'Connecting...',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Avatar with pulse ─────────────────────
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.06);
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow rings
                      ...List.generate(3, (i) {
                        final size = 160.0 + (i * 30);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(
                                0.15 - (i * 0.04),
                              ),
                              width: 1.5,
                            ),
                          ),
                        );
                      }),
                      // Avatar
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.primary.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(65),
                          child: CachedNetworkImage(
                            imageUrl: userAvatar ?? fallbackUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Icon(
                              Icons.person,
                              color: Colors.white54,
                              size: 60,
                            ),
                            errorWidget: (_, __, ___) => CachedNetworkImage(
                              imageUrl: fallbackUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Name ──────────────────────────────────
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Duration / Status ─────────────────────
                Obx(() {
                  final joined = controller.isJoined.value;
                  return Text(
                    joined ? controller.formattedDuration : 'Calling…',
                    style: TextStyle(
                      color: joined ? Colors.white60 : AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  );
                }),

                const Spacer(flex: 3),

                // ── Action buttons ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: controller.isMuted.value
                              ? Iconsax.microphone_slash
                              : Iconsax.microphone,
                          label: controller.isMuted.value ? 'Unmute' : 'Mute',
                          isActive: controller.isMuted.value,
                          onTap: controller.toggleMute,
                        ),
                        _buildEndCallButton(),
                        _buildActionButton(
                          icon: controller.isSpeakerOn.value
                              ? Iconsax.volume_high
                              : Iconsax.volume_slash,
                          label: 'Speaker',
                          isActive: controller.isSpeakerOn.value,
                          onTap: controller.toggleSpeaker,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 15,
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () => controller.endCall(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
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
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'End',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
