import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../data/models/about_model.dart';
import '../../../data/models/contact_leader_social_model.dart' hide AboutModel;
import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  String _resolveImageUrl(String url) {
    if (url.trim().isEmpty) return '';
    if (url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingView();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.fetchAbout,
          );
        }

        final about = controller.about.value;
        if (about == null) {
          return _ErrorView(
            message: 'No About Data Available',
            onRetry: controller.fetchAbout,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAbout,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: _buildHeroCard(about, isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: _buildSection(
                    title: 'About Us',
                    icon: Iconsax.info_circle,
                    child: Text(
                      _safeText(
                        about.description,
                        fallback: 'No description available yet.',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: isDark ? Colors.grey[200] : Colors.grey[800],
                      ),
                    ),
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
              ),
              if (_hasText(about.history))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _buildSection(
                      title: 'Our History',
                      icon: Iconsax.book_1,
                      child: Text(
                        about.history,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: isDark ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: _buildSection(
                    title: 'Contact Information',
                    icon: Iconsax.call_calling,
                    child: Column(
                      children: [
                        _buildContactTile(
                          item: _ContactItem(
                            icon: Iconsax.sms,
                            label: 'Email',
                            value: _safeText(
                              about.contact.email,
                              fallback: 'Not provided',
                            ),
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildContactTile(
                          item: _ContactItem(
                            icon: Iconsax.call,
                            label: 'Phone',
                            value: _safeText(
                              about.contact.phone,
                              fallback: 'Not provided',
                            ),
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildContactTile(
                          item: _ContactItem(
                            icon: Iconsax.location,
                            label: 'Address',
                            value: _safeText(
                              about.contact.address,
                              fallback: 'Not provided',
                            ),
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildContactTile(
                          item: _ContactItem(
                            icon: Iconsax.global,
                            label: 'Website',
                            value: _safeText(
                              about.contact.website,
                              fallback: 'Not provided',
                            ),
                          ),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: _buildSection(
                    title: 'University Leadership',
                    icon: Iconsax.people,
                    child: about.leaders.isEmpty
                        ? _buildEmptyText(
                            'No leadership data available yet.',
                            isDark,
                          )
                        : Column(
                            children: about.leaders.map((leader) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildLeaderCard(leader, isDark),
                              );
                            }).toList(),
                          ),
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                  child: _buildSection(
                    title: 'Connect With Us',
                    icon: Iconsax.share,
                    child: about.socialLinks.isEmpty
                        ? _buildEmptyText(
                            'No social links available yet.',
                            isDark,
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: about.socialLinks
                                .map((link) => _buildSocialCard(link, isDark))
                                .toList(),
                          ),
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              onPressed: Get.back,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF24262C) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            )
          : null,
      titleSpacing: canPop ? 6 : 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFFFFA221), Color(0xFFFF6F3C)],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            child: const Text(
              'About',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            'University profile and contacts',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: controller.fetchAbout,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF24262C) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.refresh,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(AboutModel about, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2B241C), Color(0xFF1E1A15)]
              : const [Color(0xFFFFF1E1), Color(0xFFFFF7EE)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF3D332A) : const Color(0xFFFFE1BF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.85),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    _resolveImageUrl(about.logo),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Iconsax.buildings_2,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _safeText(about.title, fallback: 'University'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3D332A)
                            : const Color(0xFFFFE4C8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Institution profile',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFFFC98D)
                              : const Color(0xFFAB5E00),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verified campus information',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                icon: Iconsax.people,
                label: '${about.leaders.length} leaders',
                isDark: isDark,
              ),
              _buildMetricChip(
                icon: Iconsax.share,
                label: '${about.socialLinks.length} social links',
                isDark: isDark,
              ),
              _buildMetricChip(
                icon: Iconsax.verify,
                label: 'Campus verified',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C251E)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isDark ? const Color(0xFF413830) : const Color(0xFFF2D6B4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[200] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D23) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D35) : const Color(0xFFE8EBF1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA221), Color(0xFFFF6F3C)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildContactTile({required _ContactItem item, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24262E) : const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[100] : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderCard(Leader leader, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24262E) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark ? const Color(0xFF2E3038) : const Color(0xFFEFF3F8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                _resolveImageUrl(leader.image),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Iconsax.user, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _safeText(leader.name, fallback: 'Unknown Leader'),
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _safeText(
                    leader.position,
                    fallback: 'Position not specified',
                  ),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_hasText(leader.bio)) ...[
                  const SizedBox(height: 8),
                  Text(
                    leader.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard(SocialLink link, bool isDark) {
    final platform = _safeText(link.platform, fallback: 'Platform');
    final url = _safeText(link.url, fallback: 'URL not available');
    final color = _getSocialColor(platform.toLowerCase());

    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getSocialIcon(platform.toLowerCase()),
                color: color,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                platform,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyText(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.5,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String _safeText(String? value, {required String fallback}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value.trim();
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
        return const Color(0xFF0088CC);
      default:
        return AppColors.primary;
    }
  }
}

class _ContactItem {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      children: [
        Container(
          height: 152,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        ...List.generate(4, (_) {
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                size: 34,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.black54,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh, size: 17),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(132, 44),
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
