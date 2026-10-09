import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/firebase_options.dart';
import 'package:teachers_app/services/auth_service.dart';
import 'package:teachers_app/services/push_service.dart';
import 'package:teachers_app/ui/common/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupLocator();
  // A stored token skips login (decoded locally, no network). If the server
  // rejects it later, the first 401 sends the user back to login.
  final user = await locator<AuthService>().restore();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundPush);
  await locator<PushService>().init();
  if (user != null) locator<PushService>().register(); // new FCM token on this phone, if any
  runApp(
    EasyLocalization(
      // First launch follows the device language; the picker's choice is saved and wins after that.
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MainApp(initialRoute: user == null ? Routes.loginView : Routes.mainView),
    ),
  );
}

/// Runs in its own isolate, so it sets the locator up again.
@pragma('vm:entry-point')
Future<void> _onBackgroundPush(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();
  await handlePush(message.data);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = context.locale.languageCode; // day/month names in DateFormat
    return MaterialApp(
      title: 'Elameed Teachers',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor, surface: AppColors.backgroundColor),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        // ponytail: google_fonts fetches Plus Jakarta Sans at runtime; bundle the .ttf under assets/fonts for offline-first.
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      initialRoute: initialRoute,
      // Otherwise '/main-view' also stacks '/' (login) underneath it.
      onGenerateInitialRoutes: (name) => [StackedRouter().onGenerateRoute(RouteSettings(name: name))!],
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
