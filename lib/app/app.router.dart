// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter/foundation.dart' as _i12;
import 'package:flutter/material.dart' as _i11;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i14;
import 'package:teachers_app/models/models.dart' as _i13;
import 'package:teachers_app/ui/views/cancel_session/cancel_session_view.dart'
    as _i9;
import 'package:teachers_app/ui/views/evaluation/evaluation_view.dart' as _i6;
import 'package:teachers_app/ui/views/group_info/group_info_view.dart' as _i4;
import 'package:teachers_app/ui/views/login/login_view.dart' as _i2;
import 'package:teachers_app/ui/views/main/main_view.dart' as _i3;
import 'package:teachers_app/ui/views/session/session_view.dart' as _i5;
import 'package:teachers_app/ui/views/signal_problem/signal_problem_view.dart'
    as _i10;
import 'package:teachers_app/ui/views/student_attendance/student_attendance_view.dart'
    as _i8;
import 'package:teachers_app/ui/views/student_info/student_info_view.dart'
    as _i7;

class Routes {
  static const loginView = '/';

  static const mainView = '/main-view';

  static const groupInfoView = '/group-info-view';

  static const sessionView = '/session-view';

  static const evaluationView = '/evaluation-view';

  static const studentInfoView = '/student-info-view';

  static const studentAttendanceView = '/student-attendance-view';

  static const cancelSessionView = '/cancel-session-view';

  static const signalProblemView = '/signal-problem-view';

  static const all = <String>{
    loginView,
    mainView,
    groupInfoView,
    sessionView,
    evaluationView,
    studentInfoView,
    studentAttendanceView,
    cancelSessionView,
    signalProblemView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(Routes.loginView, page: _i2.LoginView),
    _i1.RouteDef(Routes.mainView, page: _i3.MainView),
    _i1.RouteDef(Routes.groupInfoView, page: _i4.GroupInfoView),
    _i1.RouteDef(Routes.sessionView, page: _i5.SessionView),
    _i1.RouteDef(Routes.evaluationView, page: _i6.EvaluationView),
    _i1.RouteDef(Routes.studentInfoView, page: _i7.StudentInfoView),
    _i1.RouteDef(Routes.studentAttendanceView, page: _i8.StudentAttendanceView),
    _i1.RouteDef(Routes.cancelSessionView, page: _i9.CancelSessionView),
    _i1.RouteDef(Routes.signalProblemView, page: _i10.SignalProblemView),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.LoginView(key: args.key),
        settings: data,
      );
    },
    _i3.MainView: (data) {
      final args = data.getArgs<MainViewArguments>(
        orElse: () => const MainViewArguments(),
      );
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i3.MainView(key: args.key, initialTab: args.initialTab),
        settings: data,
      );
    },
    _i4.GroupInfoView: (data) {
      final args = data.getArgs<GroupInfoViewArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i4.GroupInfoView(key: args.key, group: args.group),
        settings: data,
      );
    },
    _i5.SessionView: (data) {
      final args = data.getArgs<SessionViewArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i5.SessionView(key: args.key, sessionId: args.sessionId),
        settings: data,
      );
    },
    _i6.EvaluationView: (data) {
      final args = data.getArgs<EvaluationViewArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.EvaluationView(
          key: args.key,
          session: args.session,
          studentName: args.studentName,
          evaluation: args.evaluation,
          readOnly: args.readOnly,
        ),
        settings: data,
      );
    },
    _i7.StudentInfoView: (data) {
      final args = data.getArgs<StudentInfoViewArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i7.StudentInfoView(key: args.key, student: args.student),
        settings: data,
      );
    },
    _i8.StudentAttendanceView: (data) {
      final args = data.getArgs<StudentAttendanceViewArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.StudentAttendanceView(
          key: args.key,
          student: args.student,
          group: args.group,
        ),
        settings: data,
      );
    },
    _i9.CancelSessionView: (data) {
      final args = data.getArgs<CancelSessionViewArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i9.CancelSessionView(key: args.key, session: args.session),
        settings: data,
      );
    },
    _i10.SignalProblemView: (data) {
      final args = data.getArgs<SignalProblemViewArguments>(nullOk: false);
      return _i11.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i10.SignalProblemView(key: args.key, session: args.session),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class LoginViewArguments {
  const LoginViewArguments({this.key});

  final _i12.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class MainViewArguments {
  const MainViewArguments({this.key, this.initialTab = 0});

  final _i12.Key? key;

  final int initialTab;

  @override
  String toString() {
    return '{"key": "$key", "initialTab": "$initialTab"}';
  }

  @override
  bool operator ==(covariant MainViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.initialTab == initialTab;
  }

  @override
  int get hashCode {
    return key.hashCode ^ initialTab.hashCode;
  }
}

class GroupInfoViewArguments {
  const GroupInfoViewArguments({this.key, required this.group});

  final _i12.Key? key;

  final _i13.Group group;

  @override
  String toString() {
    return '{"key": "$key", "group": "$group"}';
  }

  @override
  bool operator ==(covariant GroupInfoViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.group == group;
  }

  @override
  int get hashCode {
    return key.hashCode ^ group.hashCode;
  }
}

class SessionViewArguments {
  const SessionViewArguments({this.key, required this.sessionId});

  final _i12.Key? key;

  final int sessionId;

  @override
  String toString() {
    return '{"key": "$key", "sessionId": "$sessionId"}';
  }

  @override
  bool operator ==(covariant SessionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ sessionId.hashCode;
  }
}

class EvaluationViewArguments {
  const EvaluationViewArguments({
    this.key,
    required this.session,
    required this.studentName,
    this.evaluation,
    this.readOnly = false,
  });

  final _i12.Key? key;

  final _i13.Session session;

  final String studentName;

  final _i13.Evaluation? evaluation;

  final bool readOnly;

  @override
  String toString() {
    return '{"key": "$key", "session": "$session", "studentName": "$studentName", "evaluation": "$evaluation", "readOnly": "$readOnly"}';
  }

  @override
  bool operator ==(covariant EvaluationViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.session == session &&
        other.studentName == studentName &&
        other.evaluation == evaluation &&
        other.readOnly == readOnly;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        session.hashCode ^
        studentName.hashCode ^
        evaluation.hashCode ^
        readOnly.hashCode;
  }
}

class StudentInfoViewArguments {
  const StudentInfoViewArguments({this.key, required this.student});

  final _i12.Key? key;

  final _i13.GroupStudent student;

  @override
  String toString() {
    return '{"key": "$key", "student": "$student"}';
  }

  @override
  bool operator ==(covariant StudentInfoViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.student == student;
  }

  @override
  int get hashCode {
    return key.hashCode ^ student.hashCode;
  }
}

class StudentAttendanceViewArguments {
  const StudentAttendanceViewArguments({
    this.key,
    required this.student,
    required this.group,
  });

  final _i12.Key? key;

  final _i13.GroupStudent student;

  final _i13.Group group;

  @override
  String toString() {
    return '{"key": "$key", "student": "$student", "group": "$group"}';
  }

  @override
  bool operator ==(covariant StudentAttendanceViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.student == student && other.group == group;
  }

  @override
  int get hashCode {
    return key.hashCode ^ student.hashCode ^ group.hashCode;
  }
}

class CancelSessionViewArguments {
  const CancelSessionViewArguments({this.key, required this.session});

  final _i12.Key? key;

  final _i13.Session session;

  @override
  String toString() {
    return '{"key": "$key", "session": "$session"}';
  }

  @override
  bool operator ==(covariant CancelSessionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.session == session;
  }

  @override
  int get hashCode {
    return key.hashCode ^ session.hashCode;
  }
}

class SignalProblemViewArguments {
  const SignalProblemViewArguments({this.key, required this.session});

  final _i12.Key? key;

  final _i13.Session session;

  @override
  String toString() {
    return '{"key": "$key", "session": "$session"}';
  }

  @override
  bool operator ==(covariant SignalProblemViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.session == session;
  }

  @override
  int get hashCode {
    return key.hashCode ^ session.hashCode;
  }
}

extension NavigatorStateExtension on _i14.NavigationService {
  Future<dynamic> navigateToLoginView({
    _i12.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.loginView,
      arguments: LoginViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToMainView({
    _i12.Key? key,
    int initialTab = 0,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key, initialTab: initialTab),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToGroupInfoView({
    _i12.Key? key,
    required _i13.Group group,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.groupInfoView,
      arguments: GroupInfoViewArguments(key: key, group: group),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSessionView({
    _i12.Key? key,
    required int sessionId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.sessionView,
      arguments: SessionViewArguments(key: key, sessionId: sessionId),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToEvaluationView({
    _i12.Key? key,
    required _i13.Session session,
    required String studentName,
    _i13.Evaluation? evaluation,
    bool readOnly = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.evaluationView,
      arguments: EvaluationViewArguments(
        key: key,
        session: session,
        studentName: studentName,
        evaluation: evaluation,
        readOnly: readOnly,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToStudentInfoView({
    _i12.Key? key,
    required _i13.GroupStudent student,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.studentInfoView,
      arguments: StudentInfoViewArguments(key: key, student: student),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToStudentAttendanceView({
    _i12.Key? key,
    required _i13.GroupStudent student,
    required _i13.Group group,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.studentAttendanceView,
      arguments: StudentAttendanceViewArguments(
        key: key,
        student: student,
        group: group,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCancelSessionView({
    _i12.Key? key,
    required _i13.Session session,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.cancelSessionView,
      arguments: CancelSessionViewArguments(key: key, session: session),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSignalProblemView({
    _i12.Key? key,
    required _i13.Session session,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.signalProblemView,
      arguments: SignalProblemViewArguments(key: key, session: session),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLoginView({
    _i12.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.loginView,
      arguments: LoginViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithMainView({
    _i12.Key? key,
    int initialTab = 0,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key, initialTab: initialTab),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithGroupInfoView({
    _i12.Key? key,
    required _i13.Group group,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.groupInfoView,
      arguments: GroupInfoViewArguments(key: key, group: group),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSessionView({
    _i12.Key? key,
    required int sessionId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.sessionView,
      arguments: SessionViewArguments(key: key, sessionId: sessionId),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithEvaluationView({
    _i12.Key? key,
    required _i13.Session session,
    required String studentName,
    _i13.Evaluation? evaluation,
    bool readOnly = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.evaluationView,
      arguments: EvaluationViewArguments(
        key: key,
        session: session,
        studentName: studentName,
        evaluation: evaluation,
        readOnly: readOnly,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithStudentInfoView({
    _i12.Key? key,
    required _i13.GroupStudent student,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.studentInfoView,
      arguments: StudentInfoViewArguments(key: key, student: student),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithStudentAttendanceView({
    _i12.Key? key,
    required _i13.GroupStudent student,
    required _i13.Group group,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.studentAttendanceView,
      arguments: StudentAttendanceViewArguments(
        key: key,
        student: student,
        group: group,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithCancelSessionView({
    _i12.Key? key,
    required _i13.Session session,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.cancelSessionView,
      arguments: CancelSessionViewArguments(key: key, session: session),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSignalProblemView({
    _i12.Key? key,
    required _i13.Session session,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.signalProblemView,
      arguments: SignalProblemViewArguments(key: key, session: session),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }
}
