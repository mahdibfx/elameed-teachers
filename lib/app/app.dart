import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/services/api/api_auth_service.dart';
import 'package:teachers_app/services/api/api_teacher_service.dart';
import 'package:teachers_app/services/auth_service.dart';
import 'package:teachers_app/services/dio_service.dart';
import 'package:teachers_app/services/push_service.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/views/login/login_view.dart';
import 'package:teachers_app/ui/views/evaluation/evaluation_view.dart';
import 'package:teachers_app/ui/views/group_info/group_info_view.dart';
import 'package:teachers_app/ui/views/main/main_view.dart';
import 'package:teachers_app/ui/views/session/session_view.dart';
import 'package:teachers_app/ui/views/student_attendance/student_attendance_view.dart';
import 'package:teachers_app/ui/views/student_info/student_info_view.dart';
import 'package:teachers_app/ui/views/cancel_session/cancel_session_view.dart';
import 'package:teachers_app/ui/views/signal_problem/signal_problem_view.dart';
import 'package:teachers_app/services/notification_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: LoginView, initial: true),
    MaterialRoute(page: MainView),
    MaterialRoute(page: GroupInfoView),
    MaterialRoute(page: SessionView),
    MaterialRoute(page: EvaluationView),
    MaterialRoute(page: StudentInfoView),
    MaterialRoute(page: StudentAttendanceView),
    MaterialRoute(page: CancelSessionView),
    MaterialRoute(page: SignalProblemView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: DioService),
    LazySingleton(classType: ApiAuthService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: ApiTeacherService),
    LazySingleton(classType: TeacherService),
    LazySingleton(classType: NotificationService),
    LazySingleton(classType: PushService),
// @stacked-service
  ],
)
class App {}
