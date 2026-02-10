import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';
import 'dart:io';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static String? token;

  static Future<void> init() async {
    token = await getToken();
  }

  // ================== TOKEN STORAGE ==================
  static Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    token = newToken;
    print('🔑 Token saved: $newToken'); // debug log
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
  static Future<Response> login(String email, String password) async {
    try {
      final response = await DioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
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
      final response = await getProfile();
      if (response.statusCode == 200 && response.data != null) {
        return response.data; // return user data
      }
      return null;
    } catch (e) {
      print('⚠️ Failed to get current user: $e');
      return null;
    }
  }

  // ================== LOGOUT ==================
  static Future<void> logout() async {
    await clearToken();
    print('✅ User logged out');
  }
}
