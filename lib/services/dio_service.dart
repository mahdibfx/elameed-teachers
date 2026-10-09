import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teachers_app/services/api/api_endpoints.dart';

/// Owns the configured [Dio] instance and the Bearer token.
class DioService {
  static const _tokenKey = 'token';
  static const _storage = FlutterSecureStorage();

  late final Dio dio;

  DioService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.base,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('[Dio] → ${options.method} ${options.uri} ${options.data ?? ''}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Some endpoints return JSON under a non-JSON content-type, which
          // leaves `data` as a raw String — decode so callers get a Map/List.
          final data = response.data;
          if (data is String && data.isNotEmpty) {
            try {
              response.data = jsonDecode(data);
            } catch (_) {
              // Not JSON — leave as-is.
            }
          }
          debugPrint('[Dio] ← ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('[Dio] ✕ ${error.response?.statusCode} ${error.requestOptions.uri} '
              '${error.response?.data ?? error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
