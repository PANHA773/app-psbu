import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  // Reactive state variables
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var progressValue = 0.0.obs;
  var connectionStatus = true.obs;

  // App info
  var appVersion = '1.0.0'.obs;
  var isFirstLaunch = false.obs;
  var lastUpdateCheck = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  @override
  void onReady() {
    super.onReady();
    _startNavigation();
  }

  /// Main initialization
  Future<void> _initializeApp() async {
    try {
      isLoading(true);
      hasError(false);
      progressValue(0.0);

      await _checkConnectivity(); // 20%
      progressValue(0.2);

      await _checkFirstLaunch(); // 40%
      progressValue(0.4);

      await _loadAppSettings(); // 60%
      progressValue(0.6);

      await _checkForUpdates(); // 80%
      progressValue(0.8);

      await _preloadData(); // 95%
      progressValue(0.95);

      await AuthService.init(); // 100%
      progressValue(1.0);

      isLoading(false);
    } catch (e) {
      hasError(true);
      errorMessage(e.toString());
      isLoading(false);
      _handleInitializationError(e);
    }
  }

  /// Check internet connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    connectionStatus.value = connectivityResult != ConnectivityResult.none;
    if (!connectionStatus.value) {
      throw Exception('No internet connection');
    }
  }

  /// Check first launch
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getBool('first_launch') ?? true;
    isFirstLaunch.value = firstLaunch;

    if (firstLaunch) {
      await prefs.setBool('first_launch', false);
      await prefs.setString(
        'first_launch_date',
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// Load saved app settings
  Future<void> _loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode') ?? 'light';
      final savedLocale = prefs.getString('locale') ?? 'en_US';
      final notificationsEnabled = prefs.getBool('notifications') ?? true;

      Get.find<SettingsController>().applySavedSettings(
        themeMode: savedTheme,
        locale: savedLocale,
        notifications: notificationsEnabled,
      );
    } catch (_) {
      // Non-critical
    }
  }

  /// Check for updates (placeholder)
  Future<void> _checkForUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckString = prefs.getString('last_update_check');

      if (lastCheckString != null) {
        lastUpdateCheck.value = DateTime.parse(lastCheckString);
      }

      final now = DateTime.now();
      if (lastUpdateCheck.value.difference(now).inDays.abs() >= 1) {
        await prefs.setString('last_update_check', now.toIso8601String());
        lastUpdateCheck.value = now;
      }
    } catch (_) {}
  }

  /// Preload essential data
  Future<void> _preloadData() async {
    // Simulate a small delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Start navigation when ready
  void _startNavigation() {
    // Listen for loading completion
    ever(isLoading, (loading) {
      if (!loading && !hasError.value) _navigateToNextScreen();
    });

    // Timeout fallback (optional)
    Future.delayed(const Duration(seconds: 5), () {
      if (isLoading.value) {
        isLoading(false);
        _navigateToNextScreen();
      }
    });
  }

  /// Navigate to the correct screen
  void _navigateToNextScreen() {
    if (hasError.value && !connectionStatus.value) {
      Get.offAllNamed('/no-connection');
    } else if (hasError.value) {
      Get.offAllNamed(
        '/error',
        arguments: {
          'message': errorMessage.value,
          'retryCallback': _retryInitialization,
        },
      );
    } else if (AuthService.token == null) {
      Get.offAllNamed(Routes.REGISTER);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  /// Retry initialization
  Future<void> _retryInitialization() async => _initializeApp();

  /// Handle initialization error
  void _handleInitializationError(dynamic error) {
    Get.snackbar(
      'Initialization Error',
      'Failed to initialize app. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Progress percentage for UI
  String get progressPercentage => '${(progressValue.value * 100).toInt()}%';

  /// Manual skip splash (for debugging)
  void skipSplash() {
    isLoading(false);
    hasError(false);
    _navigateToNextScreen();
  }
}

/// Supporting controllers
class SettingsController extends GetxController {
  void applySavedSettings({
    required String themeMode,
    required String locale,
    required bool notifications,
  }) {
    // Apply theme, locale, notifications
  }
}
