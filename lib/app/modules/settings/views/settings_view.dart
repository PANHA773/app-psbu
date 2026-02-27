import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            _buildProfileCard(),

            // Account Settings
            _buildSectionCard(
              title: 'Account Settings',
              icon: Iconsax.user,
              color: Colors.blue,
              children: [
                _buildSettingItem(
                  icon: Iconsax.profile_circle,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () => Get.toNamed('/edit-profile'),
                ),
                _buildSettingItem(
                  icon: Iconsax.shield_tick,
                  title: 'Security',
                  subtitle: 'Password, 2FA, and security settings',
                  onTap: () => Get.toNamed('/security'),
                ),
                _buildSettingItem(
                  icon: Iconsax.global,
                  title: 'language'.tr,
                  subtitle: controller.currentLanguageLabel,
                  onTap: _showLanguagePicker,
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            // Notifications
            _buildSectionCard(
              title: 'Notifications',
              icon: Iconsax.notification,
              color: Colors.purple,
              children: [
                _buildToggleSettingItem(
                  icon: Iconsax.notification,
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications',
                  value: true,
                  onChanged: (value) {},
                ),
                _buildToggleSettingItem(
                  icon: Iconsax.sms,
                  title: 'Email Notifications',
                  subtitle: 'Receive email updates',
                  value: true,
                  onChanged: (value) {},
                ),
                _buildToggleSettingItem(
                  icon: Iconsax.calendar,
                  title: 'Event Reminders',
                  subtitle: 'Get reminded about events',
                  value: false,
                  onChanged: (value) {},
                ),
                _buildToggleSettingItem(
                  icon: Iconsax.message,
                  title: 'Message Sounds',
                  subtitle: 'Play sounds for new messages',
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),

            // App Preferences
            _buildSectionCard(
              title: 'App Preferences',
              icon: Iconsax.setting,
              color: Colors.orange,
              children: [
                _buildSettingItem(
                  icon: Iconsax.moon,
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  onTap: themeController.toggleDarkMode,
                  trailing: Obx(
                    () => Switch(
                      value: themeController.isDarkMode,
                      onChanged: themeController.setDarkMode,
                      activeColor: Colors.orange,
                    ),
                  ),
                ),
                _buildSettingItem(
                  icon: Iconsax.cloud,
                  title: 'Data Saver',
                  subtitle: 'Reduce data usage',
                  onTap: () => Get.toNamed('/data-saver'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Colors.orange,
                  ),
                ),
                _buildSettingItem(
                  icon: Iconsax.document_download,
                  title: 'Auto-download',
                  subtitle: 'Download images automatically',
                  onTap: () => Get.toNamed('/auto-download'),
                ),
                _buildSettingItem(
                  icon: Iconsax.cloud_connection,
                  title: 'Offline Mode',
                  subtitle: 'Access content offline',
                  onTap: () => Get.toNamed('/offline-mode'),
                ),
              ],
            ),

            // Privacy & Security
            _buildSectionCard(
              title: 'Privacy & Security',
              icon: Iconsax.security,
              color: Colors.red,
              children: [
                _buildSettingItem(
                  icon: Iconsax.lock,
                  title: 'Privacy Settings',
                  subtitle: 'Control your privacy',
                  onTap: () => Get.toNamed('/privacy'),
                ),
                _buildSettingItem(
                  icon: Iconsax.eye,
                  title: 'Activity Status',
                  subtitle: 'Control who sees your activity',
                  onTap: () => Get.toNamed('/activity-status'),
                ),
                _buildSettingItem(
                  icon: Iconsax.shield_security,
                  title: 'Blocked Users',
                  subtitle: 'Manage blocked accounts',
                  onTap: () => Get.toNamed('/blocked-users'),
                ),
                _buildSettingItem(
                  icon: Iconsax.export,
                  title: 'Data Export',
                  subtitle: 'Download your data',
                  onTap: () => Get.toNamed('/data-export'),
                ),
              ],
            ),

            // Support & About
            _buildSectionCard(
              title: 'Support & About',
              icon: Iconsax.info_circle,
              color: Colors.green,
              children: [
                _buildSettingItem(
                  icon: Iconsax.headphone,
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () => Get.toNamed('/help-center'),
                ),
                _buildSettingItem(
                  icon: Iconsax.message_question,
                  title: 'Contact Us',
                  subtitle: 'Reach out to our team',
                  onTap: () => Get.toNamed('/contact'),
                ),
                _buildSettingItem(
                  icon: Iconsax.document_text,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  onTap: () => Get.toNamed('/terms'),
                ),
                _buildSettingItem(
                  icon: Iconsax.document_copy,
                  title: 'Privacy Policy',
                  subtitle: 'Learn about our privacy policy',
                  onTap: () => Get.toNamed('/privacy-policy'),
                ),
                _buildSettingItem(
                  icon: Iconsax.document_text,
                  title: 'App Version',
                  subtitle: 'v2.1.4',
                  onTap: () => Get.snackbar(
                    'App Version',
                    'You are running version 2.1.4',
                    backgroundColor: Colors.green.withOpacity(0.9),
                    colorText: Colors.white,
                  ),
                ),
              ],
            ),

            // Logout Button
            _buildLogoutButton(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      title: Text(
        'settings'.tr,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            // Search settings
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.search_normal,
              size: 22,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.purple.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.network(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=500&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Johnson',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.crown_1,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed('/profile');
            },
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.arrow_right_3,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final theme = Get.theme;
    final isDark = Get.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Get.theme;
    final isDark = Get.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () {},
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildLogoutButton() {
    final isDark = Get.isDarkMode;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Material(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            _showLogoutConfirmation();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.red.withOpacity(0.1),
          highlightColor: Colors.red.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark
                    ? (Colors.grey[800] ?? Colors.grey)
                    : (Colors.grey[200] ?? Colors.grey),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.logout, size: 22, color: Colors.red),
                const SizedBox(width: 12),
                Text(
                  'log_out'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.logout, size: 24, color: Colors.red),
            ),
            const SizedBox(width: 16),
            Text(
              'confirm_logout_title'.tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'confirm_logout_content'.tr,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Perform logout
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('log_out'.tr),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final isDark = Get.isDarkMode;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF17181D) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          top: false,
          child: GetBuilder<SettingsController>(
            builder: (c) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Text(
                    'select_language'.tr,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _languageOption(
                    label: 'english_us'.tr,
                    selected:
                        c.currentLocale.languageCode ==
                        LanguageController.englishLocale.languageCode,
                    onTap: () async {
                      await c.setLanguage(LanguageController.englishLocale);
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 8),
                  _languageOption(
                    label: 'khmer'.tr,
                    selected:
                        c.currentLocale.languageCode ==
                        LanguageController.khmerLocale.languageCode,
                    onTap: () async {
                      await c.setLanguage(LanguageController.khmerLocale);
                      Get.back();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _languageOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF24262E) : const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Colors.orange
                  : (isDark
                        ? const Color(0xFF2F323B)
                        : const Color(0xFFE7EBF1)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: Colors.orange, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Optional: Quick Settings Grid (Alternative Layout)
// ignore: unused_element
class _QuickSettingsGrid extends StatelessWidget {
  const _QuickSettingsGrid();

  @override
  Widget build(BuildContext context) {
    const quickSettings = [
      {
        'icon': Iconsax.notification,
        'label': 'Notifications',
        'color': Colors.purple,
      },
      {'icon': Iconsax.security, 'label': 'Privacy', 'color': Colors.red},
      {'icon': Iconsax.moon, 'label': 'Theme', 'color': Colors.orange},
      {'icon': Iconsax.global, 'label': 'Language', 'color': Colors.blue},
      {'icon': Iconsax.cloud, 'label': 'Storage', 'color': Colors.green},
      {'icon': Iconsax.security, 'label': 'Help', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: quickSettings.length,
      itemBuilder: (context, index) {
        final setting = quickSettings[index];
        final color = (setting['color'] as Color?) ?? Colors.grey;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              splashColor: color.withOpacity(0.1),
              highlightColor: color.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        setting['icon'] as IconData,
                        size: 24,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      setting['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
