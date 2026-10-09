import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';
import 'package:teachers_app/ui/widgets/meta.dart';
import 'package:teachers_app/utils/formatters.dart';

import 'payments_viewmodel.dart';

// ponytail: no design for this tab — built from the app's own components.
// It shows what the office PAID; the amount owed isn't computed anywhere yet.
class PaymentsView extends StackedView<PaymentsViewModel> {
  const PaymentsView({super.key});

  @override
  Widget builder(BuildContext context, PaymentsViewModel viewModel, Widget? child) {
    final summary = viewModel.summary;
    return AppPage(
      title: 'payments.title'.tr(),
      onRefresh: viewModel.onRefresh,
      children: [
        AsyncBody(
          isBusy: viewModel.isBusy,
          isEmpty: summary == null,
          emptyMessage: 'payments.empty'.tr(),
          child: summary == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DarkHeaderCard(children: [
                      CustomText.bodySmall(text: 'payments.total_paid'.tr(), textColor: Colors.white70),
                      const SizedBox(height: 4),
                      CustomText.headline(text: viewModel.money(summary.totalPaid), textColor: Colors.white),
                      const SizedBox(height: 10),
                      MetaRow([
                        MetaItem(Icons.event_available_outlined, 'payments.this_year'.tr(args: [viewModel.money(summary.paidThisYear)])),
                        MetaItem(Icons.receipt_long_outlined, 'payments.count'.tr(args: ['${summary.paymentsCount}'])),
                      ], dark: true),
                    ]),
                    if (summary.groups.isNotEmpty) ...[
                      SectionTitle('payments.groups'.tr()),
                      for (final g in summary.groups)
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: CustomText.bodyLarge(text: g.name)),
                                  CustomText.bodyMedium(
                                    text: viewModel.money(g.paidForGroup),
                                    textColor: AppColors.greenColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              CustomText.bodySmall(
                                text: viewModel.salaryLabel(g) ?? 'payments.no_terms'.tr(),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                    ],
                    SectionTitle('payments.history'.tr()),
                    if (viewModel.payments.isEmpty)
                      EmptyState(message: 'payments.no_payments'.tr(), icon: Icons.payments_outlined)
                    else
                      for (final p in viewModel.payments) _PaymentCard(payment: p, viewModel: viewModel),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  void onViewModelReady(PaymentsViewModel viewModel) => viewModel.init();

  @override
  PaymentsViewModel viewModelBuilder(BuildContext context) => PaymentsViewModel();
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.viewModel});

  final TeacherPayment payment;
  final PaymentsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final period = viewModel.period(payment);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText.titleSmall(text: viewModel.money(payment.amount), textColor: AppColors.greenColor),
              ),
              if (payment.paidAt != null) CustomText.bodySmall(text: shortDate(payment.paidAt!), fontWeight: FontWeight.w600),
            ],
          ),
          if (payment.groupName.isNotEmpty) ...[
            const SizedBox(height: 6),
            CustomText.bodyMedium(text: payment.groupName, maxLines: 2),
          ],
          if (period.isNotEmpty) ...[
            const SizedBox(height: 4),
            MetaRow([MetaItem(Icons.date_range_outlined, period)]),
          ],
          if (payment.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            CustomText.bodySmall(text: payment.note, maxLines: 3),
          ],
        ],
      ),
    );
  }
}
