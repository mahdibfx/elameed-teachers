import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/firebase_options.dart';
import 'package:teachers_app/services/notification_service.dart';
import 'package:teachers_app/services/teacher_service.dart';

/// Server-sent pushes (FCM): the office changing a session, reminders, edit-request
/// answers, payments. The local 30-min / start / end reminders stay in NotificationService.
///
/// Firebase project: `elameed-system`. If it ever fails to start, every call here
/// turns into a no-op and the app keeps working on its own local reminders.
class PushService {
  final _teacherService = locator<TeacherService>();

  bool _available = false;
  String? _token;

  /// Call once at startup, before the first login check.
  Future<void> init() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _available = true;
    } catch (e) {
      debugPrint('[Push] Firebase not configured yet — pushes are off ($e)');
      return;
    }
    FirebaseMessaging.onMessage.listen(_handle);
    FirebaseMessaging.onMessageOpenedApp.listen(_handle);
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
  }

  /// After login (and on every start with a saved session): ask permission, send the token.
  Future<void> register() async {
    if (!_available) return;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('[Push] register failed: $e');
    }
  }

  /// On logout, so this phone stops receiving the previous teacher's pushes.
  Future<void> unregister() async {
    final token = _token;
    _token = null;
    if (!_available || token == null) return;
    await _teacherService.unregisterDevice(token);
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('[Push] deleteToken failed: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    await _teacherService.registerDevice(token, platform: Platform.isIOS ? 'ios' : 'android');
  }

  Future<void> _handle(RemoteMessage message) => handlePush(message.data);
}

/// Shared by the foreground listener and the background isolate.
/// The office changed something → re-read the sessions and rebuild the local reminders.
Future<void> handlePush(Map<String, dynamic> data) async {
  final type = data['type']?.toString() ?? '';
  debugPrint('[Push] $type');
  if (type != 'SESSION_CHANGED' && type != 'SESSIONS_CHANGED' && type != 'SESSION_REMINDER') return;
  // ponytail: refresh + reschedule only. An open Sessions tab still shows its last
  // load until the teacher pulls to refresh — add a reactive service if that bites.
  final sessions = await locator<TeacherService>().getSessions();
  sessions.map((list) => locator<NotificationService>().sync(list));
}
