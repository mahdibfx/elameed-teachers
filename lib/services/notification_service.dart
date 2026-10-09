import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/widgets/meta.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// The three session notifications of the design, scheduled on the device.
// ponytail: local scheduling, rebuilt from every fetch of the sessions list. A session added or
// cancelled by the office is only picked up when the app next loads Sessions; server push (FCM)
// if that ever matters.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  Future<void>? _initDone;
  bool _launchHandled = false;
  Future<void> _syncing = Future.value();

  static const _reminder = 'reminder';
  static const _start = 'start';
  static const _attendance = 'attendance';

  // Action ids.
  static const _imHere = 'im_here';
  static const _cancel = 'cancel';
  static const _mark = 'mark';
  static const _later = 'later';

  /// Android only. Runs after the UI is up so translations are loaded. One shared future (launch handling and
  /// the first sync race at startup), reset on failure so the next call retries.
  Future<void> _init() => _initDone ??= _initialize().catchError((Object e) {
        _initDone = null;
        throw e;
      });

  Future<void> _initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Algiers')); // the API's session times are Algiers time
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@drawable/ic_notification'),
      ),
      onDidReceiveNotificationResponse: _onResponse,
    );
    await _android?.requestNotificationsPermission();
    // On-time delivery needs "Alarms & reminders" (off by default on Android 14+). The request opens
    // system settings, so it's asked once per install; without it notifications fall back to inexact.
    const storage = FlutterSecureStorage();
    if (await storage.read(key: 'exact_alarm_asked') == null) {
      await storage.write(key: 'exact_alarm_asked', value: '1');
      await _android?.requestExactAlarmsPermission();
    }
  }

  /// Opened the app by tapping a notification while it was closed.
  /// Once per process: Android keeps returning the same launch intent, and MainView is rebuilt by
  /// every clearStackAndShow — reading it again would replay the tap (and loop on the reminder one).
  Future<void> handleLaunch() async {
    if (_launchHandled) return;
    _launchHandled = true;
    try {
      await _init();
      final details = await _plugin.getNotificationAppLaunchDetails();
      final response = details?.notificationResponse;
      if (details?.didNotificationLaunchApp == true && response != null) await _onResponse(response);
    } catch (e) {
      debugPrint('[Notifications] launch handling failed: $e');
    }
  }

  /// Replaces every scheduled notification with the ones for [sessions].
  Future<void> sync(List<Session> sessions) => _syncing = _syncing.then((_) => _sync(sessions)); // one at a time

  Future<void> _sync(List<Session> sessions) async {
    try {
      await _init();
      await _plugin.cancelAllPendingNotifications();
      final now = DateTime.now();
      final mode = await _android?.canScheduleExactNotifications() == true
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle; // Android may deliver a few minutes late
      for (final s in sessions.where((s) => s.isUpcoming)) {
        final room = s.room == null ? '' : ' | ${roomLabel(s.room!)}';
        await _schedule(
          s.id * 3,
          s.startsAt.subtract(const Duration(minutes: 30)),
          now,
          mode,
          title: 'notif.reminder_title'.tr(),
          body: '${s.groupName}$room | ${timeRange(s.start, s.end)}',
          payload: '$_reminder:${s.id}',
        );
        // Cancelling is refused once the session has started, so this one comes 5 min early.
        if (!s.teacherConfirmed) {
          await _schedule(
            s.id * 3 + 1,
            s.startsAt.subtract(const Duration(minutes: 5)),
            now,
            mode,
            title: 'notif.start_title'.tr(),
            body: 'notif.start_body'.tr(),
            payload: '$_start:${s.id}',
            actions: [
              AndroidNotificationAction(_imHere, 'notif.im_here'.tr(), showsUserInterface: true),
              if (s.canCancel) AndroidNotificationAction(_cancel, 'notif.cancel'.tr(), showsUserInterface: true),
            ],
          );
        }
        // ponytail: "only if attendance isn't marked" is judged at the last sync, not at fire time.
        if (!s.attendanceComplete) {
          await _schedule(
            s.id * 3 + 2,
            s.endsAt.subtract(const Duration(minutes: 15)),
            now,
            mode,
            title: 'notif.attendance_title'.tr(),
            body: 'notif.attendance_body'.tr(),
            payload: '$_attendance:${s.id}',
            actions: [
              AndroidNotificationAction(_mark, 'notif.attendance'.tr(), showsUserInterface: true),
              AndroidNotificationAction(_later, 'notif.later'.tr(), cancelNotification: true),
            ],
          );
        }
      }
    } catch (e) {
      debugPrint('[Notifications] sync failed: $e'); // never break the Sessions screen over this
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _schedule(
    int id,
    DateTime at,
    DateTime now,
    AndroidScheduleMode mode, {
    required String title,
    required String body,
    required String payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    if (!at.isAfter(now)) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime(tz.local, at.year, at.month, at.day, at.hour, at.minute),
      title: title,
      body: body,
      payload: payload,
      androidScheduleMode: mode,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails('sessions', 'Sessions', importance: Importance.high, priority: Priority.high, actions: actions),
      ),
    );
  }

  Future<void> _onResponse(NotificationResponse r) async {
    final parts = (r.payload ?? '').split(':');
    final kind = parts.first;
    final sessionId = parts.length > 1 ? int.tryParse(parts[1]) : null;
    final nav = locator<NavigationService>();
    if (r.actionId == _later) return;
    if (kind == _reminder || sessionId == null) {
      nav.clearStackAndShow(Routes.mainView, arguments: const MainViewArguments(initialTab: 1));
      return;
    }
    final teacher = locator<TeacherService>();
    if (r.actionId == _cancel) {
      final session = await teacher.getSession(sessionId);
      await session.fold((f) async => locator<SnackbarService>().showSnackbar(message: f.message), (s) async {
        // Cancelled from outside the Sessions tab: land on a fresh Sessions list, whose fetch also
        // re-syncs (drops) this session's other reminders.
        if (await nav.navigateToCancelSessionView(session: s) == true) {
          nav.clearStackAndShow(Routes.mainView, arguments: const MainViewArguments(initialTab: 1));
        }
      });
      return;
    }
    // "I'm here" = the teacher confirms they hold the session (fails harmlessly if already confirmed).
    if (r.actionId == _imHere) {
      final confirmed = await teacher.confirmSession(sessionId);
      // Already confirmed is fine; anything else (cancelled, locked…) is worth telling.
      confirmed.mapLeft((f) {
        if (!f.message.contains('already confirmed')) locator<SnackbarService>().showSnackbar(message: f.message);
      });
    }
    nav.navigateToSessionView(sessionId: sessionId);
  }
}
