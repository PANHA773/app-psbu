import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';
import 'dart:io';
import 'package:university_news_app/app/config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static String? token;

  static Future<void> init() async {
    token = await getToken();
  }

  // ================== TOKEN & ROLE STORAGE ==================
  static Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    token = newToken;
    print('🔑 Token saved: $newToken'); // debug log
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    print('👤 Role saved: $role');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    token = null;
    print('⚠️ Token cleared');
  }

  // ================== REGISTER ==================
  static Future<Response> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
      };

      final response = await DioClient.dio.post('/auth/register', data: data);

      // Intentionally do not save token on register.
      // Users must log in before accessing protected routes.

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ================== LOGIN ==================
  static Future<Response> login(
    String email,
    String password, {
    String? role,
  }) async {
    try {
      // Ensure we clear any existing guest session before logging in
      if (token == 'guest') {
        token = null;
      }

      final response = await DioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          if (role != null) 'role': role,
        },
      );

      // ✅ Save token after successful login
      final tokenValue = response.data['token'];
      if (tokenValue != null) {
        await saveToken(tokenValue);
      } else {
        print('⚠️ No token returned from login');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> loginAsGuest() async {
    try {
      // Mock guest login or call a guest endpoint if available
      await clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'Guest');
      token = 'guest'; // Set token to bypass AuthMiddleware
      print('👤 Logged in as Guest');
    } catch (e) {
      print('❌ Guest login failed: $e');
    }
  }

  // ================== SOCIAL LOGIN ==================
  static Future<Response> loginWithGoogle(String idToken) async {
    try {
      final response = await DioClient.dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      final tokenValue = response.data['token'];
      if (tokenValue != null) {
        await saveToken(tokenValue);
      } else {
        print('⚠️ No token returned from Google login');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> loginWithFacebook(String accessToken) async {
    try {
      final response = await DioClient.dio.post(
        '/auth/facebook',
        data: {'accessToken': accessToken},
      );

      final tokenValue = response.data['token'];
      if (tokenValue != null) {
        await saveToken(tokenValue);
      } else {
        print('⚠️ No token returned from Facebook login');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ================== PROFILE ==================

  static Future<Response> updateProfile({String? name, File? image}) async {
    try {
      // Get current user to extract ID
      final currentUser = await getCurrentUser();
      if (currentUser == null || currentUser['_id'] == null) {
        throw Exception('Could not get user ID to update profile.');
      }
      final userId = currentUser['_id'];

      final Map<String, dynamic> data = {};
      if (name != null && name.isNotEmpty) data['name'] = name;

      if (image != null) {
        String fileName = image.path.split('/').last;
        data['avatar'] = await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(data);

      return await DioClient.dio.put(
        '/auth/profile/$userId', // Append user ID to the URL
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> getProfile() async {
    try {
      return await DioClient.dio.get(
        '/auth/profile',
      ); // <-- ensure backend route exists
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      // 1. Sync token from SharedPreferences if it's null in memory
      if (token == null) {
        token = await getToken();
      }

      // 2. If it's explicitly 'guest', return the mock data
      if (token == 'guest') {
        // Return a mock user for Guest mode
        return {
          '_id': 'guest_id',
          'name': 'Guest User',
          'email': 'guest@university.edu',
          'role': 'Guest',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'settings': {
            'darkMode': false,
            'emailNotifications': false,
            'pushNotifications': false,
            'language': 'English',
          },
        };
      }

      // 3. If we have a token (not guest), fetch the real profile
      if (token != null && token!.isNotEmpty) {
        final response = await getProfile();
        if (response.statusCode == 200 && response.data != null) {
          final Map<String, dynamic> userData = response.data;

          // Fix avatar URL if it exists
          if (userData['avatar'] != null) {
            userData['avatar'] = AppConfig.transformUrl(userData['avatar']);
          }

          // Oversee role with locally saved one if backend returns generic 'user'
          final localRole = await getRole();
          if (localRole != null &&
              (userData['role'] == 'user' || userData['role'] == null)) {
            userData['role'] = localRole;
            print('👤 Injected local role: $localRole');
          }

          return userData;
        }
      }

      // 4. No token found
      return null;
    } catch (e) {
      print('⚠️ Failed to get current user: $e');
      return null;
    }
  }

  // ================== LOGOUT ==================
  static Future<void> logout() async {
    await clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    print('✅ User logged out and role cleared');
  }
}
