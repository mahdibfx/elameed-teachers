// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/api/api_auth_service.dart';
import '../services/api/api_teacher_service.dart';
import '../services/auth_service.dart';
import '../services/dio_service.dart';
import '../services/notification_service.dart';
import '../services/push_service.dart';
import '../services/teacher_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
  // Register environments
  locator.registerEnvironment(
    environment: environment,
    environmentFilter: environmentFilter,
  );

  // Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => DioService());
  locator.registerLazySingleton(() => ApiAuthService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => ApiTeacherService());
  locator.registerLazySingleton(() => TeacherService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => PushService());
}
