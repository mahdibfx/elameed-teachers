import 'package:stacked/stacked.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/models/failure.dart';
import 'package:teachers_app/services/auth_service.dart';
import 'package:teachers_app/services/notification_service.dart';
import 'package:teachers_app/ui/common/app_strings.dart';

class MainViewModel extends IndexTrackingViewModel {
  final _authService = locator<AuthService>();

  /// Server-side token check in the background (refreshes the token when the API sends one).
  /// Only a real rejection logs out — being offline or slow must not.
  Future<void> verifySession() async {
    locator<NotificationService>().handleLaunch(); // app opened from a session notification
    final result = await _authService.verify();
    result.mapLeft((f) {
      if (f is! NoInternetFailure && f.message != AppStrings.timeout) _authService.logout();
    });
  }
}
