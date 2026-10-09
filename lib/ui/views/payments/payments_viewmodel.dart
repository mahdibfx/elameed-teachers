import 'package:easy_localization/easy_localization.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/utils/formatters.dart';

class PaymentsViewModel extends BaseViewModel {
  final _teacherService = locator<TeacherService>();
  final _snackbarService = locator<SnackbarService>();

  PaymentSummary? summary;
  List<TeacherPayment> payments = [];

  String money(double v) => 'common.da'.tr(args: [amount(v.round())]);

  /// "Fixed amount · 1 500 DA" / "Percentage · 40%" — what the office agreed, not what is owed.
  String? salaryLabel(PaymentGroup g) {
    if (g.salaryAmount == null && g.salaryType.isEmpty) return null;
    final type = switch (g.salaryType) {
      'static' => 'group_info.fixed'.tr(),
      'percentage' => 'payments.percentage'.tr(),
      _ => g.salaryType,
    };
    if (g.salaryAmount == null) return type;
    final value = g.salaryType == 'percentage' ? '${amount(g.salaryAmount!.round())}%' : money(g.salaryAmount!);
    return type.isEmpty ? value : '$type · $value';
  }

  String period(TeacherPayment p) => p.periodFrom == null || p.periodTo == null
      ? ''
      : '${shortDate(p.periodFrom!)} ~ ${shortDate(p.periodTo!)}';

  Future<void> init({bool refresh = false}) async {
    setBusy(summary == null);
    final (s, list) = await (_teacherService.getPaymentSummary(), _teacherService.getPayments()).wait;
    s.fold((f) => _snackbarService.showSnackbar(message: f.message), (v) => summary = v);
    list.fold((f) => _snackbarService.showSnackbar(message: f.message), (v) => payments = v);
    setBusy(false);
  }

  Future<void> onRefresh() => init(refresh: true);
}
