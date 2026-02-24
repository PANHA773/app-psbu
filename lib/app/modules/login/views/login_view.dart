import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController ctrl = controller;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF171A23), Color(0xFF0F1117)]
                : const [Color(0xFFFFF6EA), Color(0xFFF7FAFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 22),
                  _buildAuthCard(context, ctrl, isDark, formKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC15A), Color(0xFFFF8E4E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 52,
                height: 52,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.secondary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to see campus updates and connect with your community.',
          style: TextStyle(
            fontSize: 14.5,
            height: 1.4,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(
    BuildContext context,
    LoginController ctrl,
    bool isDark,
    GlobalKey<FormState> formKey,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF171B25).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3140) : const Color(0xFFFFE5C7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Login as',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          _buildRoleSelector(ctrl, isDark),
          const SizedBox(height: 18),
          _buildTextFormField(
            controller: ctrl.emailController,
            hintText: 'Email address',
            prefixIcon: Iconsax.direct_right,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            validator: (value) {
              if (value == null || !GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextFormField(
            controller: ctrl.passwordController,
            hintText: 'Password',
            prefixIcon: Iconsax.lock,
            isPassword: true,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Get.snackbar(
                  'Info',
                  'Forgot password flow is not connected yet.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isLoading.value
                    ? null
                    : () {
                        final isValid =
                            formKey.currentState?.validate() ?? false;
                        if (isValid) {
                          ctrl.login();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: ctrl.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSocialSection(context, ctrl, isDark),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No account yet?',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: const Text(
                  'Create one',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(child: _buildGuestLink(ctrl, isDark)),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(LoginController ctrl, bool isDark) {
    return Obx(
      () => Row(
        children: ctrl.roles.map((role) {
          final isSelected = ctrl.selectedRole.value == role;
          return Expanded(
            child: GestureDetector(
              onTap: () => ctrl.setRole(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(
                  right: role == ctrl.roles.first ? 8 : 0,
                  left: role == ctrl.roles.last ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.17)
                      : (isDark
                            ? const Color(0xFF1E2431)
                            : const Color(0xFFF7F9FC)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? const Color(0xFF323A4C)
                              : const Color(0xFFE6EAF1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      role == 'Student' ? Iconsax.user : Iconsax.teacher,
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.grey[200] : AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGuestLink(LoginController ctrl, bool isDark) {
    return TextButton(
      onPressed: ctrl.isLoading.value ? null : () => ctrl.loginAsGuest(),
      child: Text(
        'Continue as Guest',
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[500],
          fontSize: 14,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 18),
        filled: true,
        fillColor: isDark ? const Color(0xFF1D2330) : const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF30384A) : const Color(0xFFE8EDF4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.7),
        ),
      ),
      style: TextStyle(
        color: isDark ? Colors.grey[100] : AppColors.secondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSocialSection(
    BuildContext context,
    LoginController ctrl,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark
                    ? const Color(0xFF32394A)
                    : const Color(0xFFE4E8EF),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Or continue with',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Divider(
                color: isDark
                    ? const Color(0xFF32394A)
                    : const Color(0xFFE4E8EF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _promptToken(
                  context,
                  title: 'Google Sign-In',
                  hint: 'Paste Google idToken',
                  onSubmit: ctrl.loginWithGoogleToken,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF333B4D)
                        : const Color(0xFFE3E8EF),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  backgroundColor: isDark
                      ? const Color(0xFF1D2330)
                      : Colors.white,
                  foregroundColor: isDark ? Colors.white : AppColors.secondary,
                ),
                icon: const Icon(
                  Iconsax.google,
                  color: Colors.redAccent,
                  size: 18,
                ),
                label: Text(
                  'Google',
                  style: TextStyle(
                    color: isDark ? Colors.grey[200] : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _promptToken(
                  context,
                  title: 'Facebook Sign-In',
                  hint: 'Paste Facebook accessToken',
                  onSubmit: ctrl.loginWithFacebookToken,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF333B4D)
                        : const Color(0xFFE3E8EF),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  backgroundColor: isDark
                      ? const Color(0xFF1D2330)
                      : Colors.white,
                  foregroundColor: isDark ? Colors.white : AppColors.secondary,
                ),
                icon: const Icon(
                  Iconsax.facebook,
                  color: Colors.blue,
                  size: 18,
                ),
                label: Text(
                  'Facebook',
                  style: TextStyle(
                    color: isDark ? Colors.grey[200] : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _promptToken(
    BuildContext context, {
    required String title,
    required String hint,
    required void Function(String token) onSubmit,
  }) async {
    final tokenController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: tokenController,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          minLines: 1,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onSubmit(tokenController.text);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
