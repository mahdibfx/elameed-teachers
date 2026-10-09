import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';

/// Back + bottom-nav handling for screens pushed on top of MainView.
mixin TabNavigation on BaseViewModel {
  final navigationService = locator<NavigationService>();

  void onBack() => navigationService.back();

  // ponytail: tapping a tab from a pushed screen resets to MainView on that tab
  // (loses the other tabs' scroll). Nested navigators per tab if that bothers anyone.
  void onTabTap(int index) =>
      navigationService.clearStackAndShow(Routes.mainView, arguments: MainViewArguments(initialTab: index));
}
