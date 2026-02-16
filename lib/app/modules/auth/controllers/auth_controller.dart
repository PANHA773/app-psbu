import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class AuthController extends GetxController {
  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs;
  Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  Future<void> checkLogin() async {
    // Ensure the token is refreshed from SharedPreferences
    await AuthService.init();

    if (AuthService.token != null) {
      isLoggedIn.value = true;
      await fetchUser();
    } else {
      isLoggedIn.value = false;
      user.value = null;
    }
  }

  Future<void> fetchUser() async {
    try {
      final userData = await AuthService.getCurrentUser();
      if (userData != null) {
        user.value = UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Failed to fetch user: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await AuthService.login(email, password);
      isLoggedIn.value = true;
      await fetchUser();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    isLoggedIn.value = false;
    user.value = null;
    Get.offAllNamed('/login'); // Redirect to login
  }
}
