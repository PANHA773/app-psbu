import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config.dart';
import 'auth_service.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl, // <-- now correct for emulator/device
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(AuthInterceptor());

  static Dio get dio => _dio;
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await AuthService.getToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        if (kDebugMode) {
          print('✅ Token attached to request: ${options.path}');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ No token found for request: ${options.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error getting token: $e');
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
      print('Response Data: ${response.data}');
    }

    // Unwrap 'data' field if present (common API pattern)
    if (response.data is Map && response.data.containsKey('data')) {
      response.data = response.data['data'];
      if (kDebugMode) {
        print('✅ Unwrapped response data');
      }
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path} | Message: ${err.message}',
      );
    }
    super.onError(err, handler);
  }
}
