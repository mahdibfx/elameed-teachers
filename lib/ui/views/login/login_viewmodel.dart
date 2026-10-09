import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/services/auth_service.dart';
import 'package:teachers_app/services/push_service.dart';

class LoginViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> onLogin() async {
    if (isBusy) return;
    final email = emailController.text.trim();
    if (email.isEmpty || passwordController.text.isEmpty) {
      _snackbarService.showSnackbar(message: 'login.fill_fields'.tr(), duration: const Duration(seconds: 2));
      return;
    }
    setBusy(true);
    final result = await _authService.login(email: email, password: passwordController.text);
    setBusy(false);
    result.fold(
      (failure) => _snackbarService.showSnackbar(message: failure.message, duration: const Duration(seconds: 3)),
      (user) {
        // ponytail: the app only serves teachers; other roles get told so instead of an empty app.
        if (user.role.isNotEmpty && user.role != 'teacher') {
          _snackbarService.showSnackbar(message: 'login.not_teacher'.tr(), duration: const Duration(seconds: 3));
          _authService.logout();
          return;
        }
        locator<PushService>().register(); // this phone now belongs to this teacher
        _navigationService.clearStackAndShow(Routes.mainView);
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
