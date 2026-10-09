import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/models/api_response.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/api/api_endpoints.dart';
import 'package:teachers_app/services/dio_service.dart';

class ApiAuthService {
  final _dio = locator<DioService>().dio;

  Future<ApiResponse<LoginResult>> login({required String email, required String password}) async {
    final res = await _dio.post(ApiEndpoints.login, data: {'email': email, 'password': password});
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, LoginResult.fromJson);
  }

  /// Same `{ token?, data: user }` shape as login; `token` is a refreshed JWT when present.
  Future<ApiResponse<LoginResult>> verifyToken(String token) async {
    final res = await _dio.post(ApiEndpoints.verifyToken, data: {'token': token});
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, LoginResult.fromJson);
  }
}
