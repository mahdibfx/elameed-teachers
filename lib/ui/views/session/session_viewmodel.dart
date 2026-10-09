import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:fpdart/fpdart.dart' hide Group, State;
import 'package:teachers_app/models/failure.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/views/main/tab_navigation.dart';
import 'package:teachers_app/ui/views/session/widgets/pickers.dart';

class SessionViewModel extends BaseViewModel with TabNavigation {
  SessionViewModel(this.sessionId);

  final int sessionId;
  final _teacherService = locator<TeacherService>();
  final _snackbarService = locator<SnackbarService>();

  Session? session;
  bool isSaving = false;
  final noteController = TextEditingController();

  /// Only what the teacher touched this visit is sent (omitted = keep the stored value).
  final _present = <int, bool>{};
  final _feedback = <int, Evaluation>{};

  List<Attendee> get attendees => session?.attendees.where((a) => a.canMark).toList() ?? [];

  /// Staff lock a session once they set it held / not_held; a stopped group is read-only too.
  bool get canEdit => session?.isEditable ?? false;
  bool get inStoppedGroup => session?.inStoppedGroup ?? false;

  /// Book unit picked on this visit; [noBookUnit] = "this session didn't follow a book unit".
  BookUnit? bookUnit;
  bool noBookUnit = false;
  bool isChangingRoom = false;

  bool get _unitChanged => bookUnit?.id != session?.bookUnit?.id;
  bool get _noteChanged => session != null && noteController.text.trim() != session!.notes;
  bool get _detailsChanged => _unitChanged || _noteChanged;

  bool get hasChanges => _present.isNotEmpty || _feedback.isNotEmpty || _detailsChanged;

  /// First save says "Submit Attendance", later ones "Save Changes".
  bool get alreadyMarked => (session?.attendanceCount ?? 0) > 0;

  String get unitLabel => bookUnit?.label ?? (noBookUnit ? 'session.no_book_unit'.tr() : session?.unit ?? '');

  bool? _state(Attendee a) => _present[a.studentId] ?? a.present;

  /// 0 = present, 1 = absent, null = not marked yet.
  int? attendanceIndex(Attendee a) => switch (_state(a)) {
    true => 0,
    false => 1,
    null => null,
  };
  bool isEvaluated(Attendee a) => (_feedback[a.studentId] ?? a.feedback) != null;

  /// The teacher's open "reopen this session" request, if any.
  EditRequest? editRequest;
  bool isAsking = false;

  bool get canAskToEdit => session?.canAskToEdit ?? false;

  Future<void> init() async {
    setBusy(true);
    final result = await _teacherService.getSession(sessionId);
    result.fold((f) => _snackbarService.showSnackbar(message: f.message), (s) {
      session = s;
      bookUnit = s.bookUnit;
      // Already marked without a unit = the teacher ticked "no book unit" last time (the API stores just null).
      noBookUnit = s.bookUnit == null && s.attendanceCount > 0;
      noteController.text = s.notes;
    });
    setBusy(false);
    if (canAskToEdit) await _loadEditRequest();
  }

  Future<void> _loadEditRequest() async {
    final result = await _teacherService.getEditRequests(sessionId);
    result.map((list) => editRequest = list.where((r) => r.isPending).firstOrNull);
    notifyListeners();
  }

  /// Held session: ask the office to put it back to pending so it can be fixed.
  Future<void> onAskToEditTap(String? reason) async {
    if (isAsking) return;
    isAsking = true;
    notifyListeners();
    final result = await _teacherService.askToEdit(sessionId, reason: reason);
    isAsking = false;
    result.fold((f) => _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3)), (r) {
      editRequest = r;
      _snackbarService.showSnackbar(message: 'edit_request.sent'.tr(), duration: const Duration(seconds: 3));
    });
    notifyListeners();
  }

  Future<void> onWithdrawEditRequest() async {
    final id = editRequest?.id;
    if (id == null || isAsking) return;
    isAsking = true;
    notifyListeners();
    final result = await _teacherService.withdrawEditRequest(id);
    isAsking = false;
    result.fold((f) => _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3)), (_) {
      editRequest = null;
      _snackbarService.showSnackbar(message: 'edit_request.withdrawn'.tr(), duration: const Duration(seconds: 2));
    });
    notifyListeners();
  }

  Future<void> onUnitTap() async {
    if (!canEdit) return;
    final books = await _teacherService.getBooks();
    await books.fold((f) async => _snackbarService.showSnackbar(message: f.message), (books) async {
      final picked = await showUnitPicker(books, bookUnit?.id);
      if (picked == null) return;
      bookUnit = picked.unit;
      noBookUnit = picked.unit == null;
      notifyListeners();
    });
  }

  /// Not in the designs, but without it a teacher who misses the "Are you at El Ameed?"
  /// notification could never confirm (and the office's attendance email needs a confirmation).
  bool get canConfirm => session != null && session!.isUpcoming && !session!.teacherConfirmed;
  bool isConfirming = false;

  Future<void> onConfirmTap() async {
    isConfirming = true;
    notifyListeners();
    final result = await _teacherService.confirmSession(sessionId);
    // Confirm answers without the roster, so re-read the session.
    final fresh = result.isRight() ? await _teacherService.getSession(sessionId) : result;
    isConfirming = false;
    fresh.fold((f) => _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3)), (s) {
      session = s;
      _snackbarService.showSnackbar(message: 'session.confirmed'.tr(), duration: const Duration(seconds: 2));
    });
    notifyListeners();
  }

  void onSignalProblemTap() => navigationService.navigateToSignalProblemView(session: session!);

  Future<void> onChangeRoomTap() async {
    final rooms = await _teacherService.getRooms();
    await rooms.fold((f) async => _snackbarService.showSnackbar(message: f.message), (rooms) async {
      final room = await showRoomPicker(rooms, session?.room?.id);
      if (room == null || room.id == session?.room?.id) return;
      isChangingRoom = true;
      notifyListeners();
      final result = await _teacherService.updateSession(sessionId, {'room_id': room.id});
      // PATCH answers without the roster, so re-read the session (unsaved marks stay in _present/_feedback).
      final fresh = result.isRight() ? await _teacherService.getSession(sessionId) : result;
      isChangingRoom = false;
      fresh.fold((f) => _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3)), (s) {
        session = s;
        _snackbarService.showSnackbar(message: 'session.room_changed'.tr(), duration: const Duration(seconds: 2));
      });
      notifyListeners();
    });
  }

  void onAttendanceChanged(Attendee a, int index) {
    _present[a.studentId] = index == 0;
    notifyListeners();
  }

  Future<void> onEvaluationTap(Attendee a) async {
    final result = await navigationService.navigateToEvaluationView(
      session: session!,
      studentName: a.name,
      evaluation: _feedback[a.studentId] ?? a.feedback,
      readOnly: !canEdit, // a closed session's evaluations are history
    );
    if (result is Evaluation) {
      _feedback[a.studentId] = result;
      // Evaluating implies the student came; a record needs a state anyway.
      if (_state(a) == null) _present[a.studentId] = true;
      notifyListeners(); // turns the button green
    }
  }

  Future<void> onStudentHistoryTap(Attendee a) async {
    final group = await _group();
    if (group == null) return;
    navigationService.navigateToStudentAttendanceView(
      student: GroupStudent(id: a.studentId, name: a.name, phone: ''),
      group: group,
    );
  }

  Future<void> onGroupHistoryTap() async {
    final group = await _group();
    if (group != null) navigationService.navigateToGroupInfoView(group: group);
  }

  Future<Group?> _group() async {
    final groups = await _teacherService.getGroups();
    return groups.fold((f) {
      _snackbarService.showSnackbar(message: f.message);
      return null;
    }, (gs) => gs.where((g) => g.id == session?.groupId).firstOrNull);
  }

  Future<void> onSubmit() async {
    if (isSaving || session == null) return;
    if (!hasChanges) {
      _snackbarService.showSnackbar(message: 'session.nothing_to_save'.tr(), duration: const Duration(seconds: 2));
      return;
    }
    final ids = {..._present.keys, ..._feedback.keys};
    // Office rule: attendance needs the unit covered, or an explicit "no book unit".
    if (ids.isNotEmpty && bookUnit == null && !noBookUnit) {
      _snackbarService.showSnackbar(message: 'session.pick_unit'.tr(), duration: const Duration(seconds: 3));
      return;
    }
    isSaving = true;
    notifyListeners();

    // Unit / note first: if that fails there is no point writing attendance.
    if (_detailsChanged) {
      final details = await _teacherService.updateSession(session!.id, {
        if (_noteChanged) 'notes': noteController.text.trim(),
        if (_unitChanged) 'book_unit_id': bookUnit?.id,
      });
      final failed = details.fold(
        (f) {
          _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3));
          return true;
        },
        // Not `session = s`: PATCH answers without the roster. If attendance fails below, the list must stay,
        // and a retry just re-sends the same PATCH.
        (_) => false,
      );
      if (failed) {
        isSaving = false;
        notifyListeners();
        return;
      }
    }

    final result = ids.isEmpty
        ? Either<Failure, Unit>.right(unit)
        : await _teacherService.saveAttendance(session!.id, [
            for (final id in ids) AttendanceWrite(studentId: id, present: _present[id], feedback: _feedback[id]),
          ]);
    isSaving = false;
    notifyListeners();
    result.fold((f) => _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3)), (_) {
      _snackbarService.showSnackbar(message: 'session.submitted'.tr(), duration: const Duration(seconds: 2));
      navigationService.back();
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
