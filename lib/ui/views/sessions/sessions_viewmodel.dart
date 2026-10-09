import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/notification_service.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/utils/formatters.dart';

class SessionsViewModel extends BaseViewModel {
  final _teacherService = locator<TeacherService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final searchController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();

  final _notificationService = locator<NotificationService>();

  List<Session> _sessions = [];
  DateTime? _from;
  DateTime? _to;

  /// Upcoming tab (default) vs History tab.
  bool showUpcoming = true;

  void setTab(bool upcoming) {
    showUpcoming = upcoming;
    notifyListeners();
  }

  List<(String title, List<Session> sessions)> get sections => showUpcoming ? _upcomingSections : _historySections;

  /// Pending sessions not over yet, soonest first.
  List<(String, List<Session>)> get _upcomingSections {
    final byDay = <DateTime, List<Session>>{};
    for (final s in _sessions.reversed.where((s) => s.isUpcoming)) {
      byDay.putIfAbsent(DateUtils.dateOnly(s.date), () => []).add(s);
    }
    return [for (final e in byDay.entries) (_dayTitle(e.key), e.value..sort((a, b) => a.start.compareTo(b.start)))];
  }

  /// Filtered past / closed sessions grouped per day, newest day first.
  List<(String, List<Session>)> get _historySections {
    final q = searchController.text.trim().toLowerCase();
    final byDay = <DateTime, List<Session>>{};
    for (final s in _sessions.where((s) => !s.isUpcoming)) {
      if (q.isNotEmpty && !s.groupName.toLowerCase().contains(q)) continue;
      final day = DateUtils.dateOnly(s.date);
      if (_from != null && day.isBefore(_from!)) continue;
      if (_to != null && day.isAfter(_to!)) continue;
      byDay.putIfAbsent(day, () => []).add(s);
    }
    return [for (final e in byDay.entries) (_dayTitle(e.key), e.value..sort((a, b) => b.start.compareTo(a.start)))];
  }

  String _dayTitle(DateTime d) {
    final days = daysAgo(d, DateTime.now());
    if (days == 0) return 'date.today'.tr();
    if (days == 1) return 'date.yesterday'.tr();
    if (days == -1) return 'date.tomorrow'.tr();
    return fullDate(d);
  }

  Future<void> init() async {
    setBusy(_sessions.isEmpty);
    final result = await _teacherService.getSessions();
    result.fold((f) => _snackbarService.showSnackbar(message: f.message), (s) => _sessions = s);
    setBusy(false);
    if (result.isRight()) _notificationService.sync(_sessions);
  }

  void onSearchChanged(String _) => notifyListeners();

  Future<void> onFromTap() async {
    _from = await _pickDate(_from);
    fromController.text = _from == null ? '' : shortDate(_from!);
    notifyListeners();
  }

  Future<void> onToTap() async {
    _to = await _pickDate(_to);
    toController.text = _to == null ? '' : shortDate(_to!);
    notifyListeners();
  }

  /// Cancel clears the filter.
  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
    context: StackedService.navigatorKey!.currentContext!,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  Future<void> onSessionTap(Session s) async {
    await _navigationService.navigateToSessionView(sessionId: s.id);
    await init(); // counts/status may have changed
  }

  Future<void> onCancelTap(Session s) async {
    final cancelled = await _navigationService.navigateToCancelSessionView(session: s);
    if (cancelled == true) await init();
  }

  @override
  void dispose() {
    searchController.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
}
