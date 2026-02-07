import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/app_colors.dart';
import '../../../data/models/contact_leader_social_model.dart'; // ✅ unified model
import '../controllers/about_controller.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  // Fix localhost image URLs for Android emulator
  String fixImageUrl(String url) {
    if (url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AboutController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState();
        if (controller.errorMessage.value.isNotEmpty) return _buildErrorState(controller.errorMessage.value);

        final about = controller.about.value;
        if (about == null) {
          return const Center(child: Text('No About Data Available', style: TextStyle(fontSize: 16)));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          fixImageUrl(about.logo),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        about.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      context,
                      title: 'About Us',
                      icon: Iconsax.info_circle,
                      child: Text(
                        about.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: theme.colorScheme.onBackground.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      context,
                      title: 'Contact Information',
                      icon: Iconsax.call_calling,
                      child: Column(
                        children: [
                          _buildContactItem(Iconsax.sms, 'Email', about.contact.email),
                          const SizedBox(height: 12),
                          _buildContactItem(Iconsax.call, 'Phone', about.contact.phone),
                          const SizedBox(height: 12),
                          _buildContactItem(Iconsax.location, 'Address', about.contact.address),
                          const SizedBox(height: 12),
                          _buildContactItem(Iconsax.global, 'Website', about.contact.website),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      context,
                      title: 'University Leadership',
                      icon: Iconsax.people,
                      child: Column(
                        children: about.leaders.map((leader) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.network(
                                      fixImageUrl(leader.image),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Iconsax.user),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                /// 🔥 THIS FIXES THE OVERFLOW
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        leader.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        leader.position,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        leader.bio,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: theme.colorScheme.onBackground.withOpacity(0.75),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (about.socialLinks.isNotEmpty)
                      _buildCard(
                        context,
                        title: 'Connect With Us',
                        icon: Iconsax.share,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: about.socialLinks.map(_buildSocialButton).toList(), // ✅ clean
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ================= HELPERS =================
  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: theme.colorScheme.primary), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(SocialLink link) {
    final color = _getSocialColor(link.platform.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_getSocialIcon(link.platform.toLowerCase()), color: color), const SizedBox(width: 10), Text(link.platform, style: TextStyle(color: color, fontWeight: FontWeight.w600))]),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform) {
      case 'facebook':
        return Iconsax.facebook;
      case 'instagram':
        return Iconsax.instagram;
      case 'linkedin':
        return Iconsax.link;
      case 'youtube':
        return Iconsax.video_play;
      case 'telegram':
        return Iconsax.send_2;
      default:
        return Iconsax.global;
    }
  }

  Color _getSocialColor(String platform) {
    switch (platform) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'telegram':
        return const Color(0xFF0088cc);
      default:
        return Colors.blueAccent;
    }
  }

  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());

  Widget _buildErrorState(String message) => Center(child: Text(message));
}
