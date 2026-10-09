import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/extensions/api_response_extension.dart';
import 'package:teachers_app/models/failure.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/api/api_auth_service.dart';
import 'package:teachers_app/services/dio_service.dart';
import 'package:teachers_app/services/push_service.dart';
import 'package:teachers_app/services/notification_service.dart';
import 'package:teachers_app/services/teacher_service.dart';

class AuthService {
  final _api = locator<ApiAuthService>();
  final _dioService = locator<DioService>();

  AuthUser? currentUser;

  Future<Either<Failure, AuthUser>> login({required String email, required String password}) async {
    final result = await _api.login(email: email, password: password).toEither();
    return result.fold<Future<Either<Failure, AuthUser>>>(
      (failure) async => Either.left(failure),
      (login) async {
        if (login.token.isEmpty) return Either.left(GeneralFailure('Login failed'));
        await _dioService.saveToken(login.token);
        // Login's payload has no Role; read it from the JWT itself.
        currentUser = _decode(login.token) ?? login.user;
        return Either.right(currentUser!);
      },
    );
  }

  /// Instant, offline: reads the stored JWT. null = not logged in.
  Future<AuthUser?> restore() async {
    final token = await _dioService.getToken();
    if (token == null || token.isEmpty) return null;
    return currentUser = _decode(token);
  }

  /// Server check of the stored token; saves a refreshed one when sent. Left = invalid.
  Future<Either<Failure, AuthUser>> verify() async {
    final token = await _dioService.getToken();
    if (token == null || token.isEmpty) return Either.left(GeneralFailure('No token'));
    final result = await _api.verifyToken(token).toEither();
    return result.fold<Future<Either<Failure, AuthUser>>>(
      (failure) async => Either.left(failure),
      (v) async {
        if (v.token.isNotEmpty) await _dioService.saveToken(v.token);
        return Either.right(currentUser = v.user);
      },
    );
  }

  Future<void> logout() async {
    await locator<PushService>().unregister(); // needs the token, so before it is deleted
    await _dioService.deleteToken();
    currentUser = null;
    locator<TeacherService>().clearCache();
    await locator<NotificationService>().cancelAll();
    locator<NavigationService>().clearStackAndShow(Routes.loginView);
  }

  Future<void> confirmLogout() async {
    final res = await locator<DialogService>().showConfirmationDialog(
      title: currentUser?.name ?? '',
      description: 'logout.question'.tr(),
      confirmationTitle: 'logout.confirm'.tr(),
      cancelTitle: 'logout.cancel'.tr(),
    );
    if (res?.confirmed == true) await logout();
  }

  static AuthUser? _decode(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return payload is Map<String, dynamic> ? AuthUser.fromJson(payload) : null;
    } catch (_) {
      return null;
    }
  }
}
