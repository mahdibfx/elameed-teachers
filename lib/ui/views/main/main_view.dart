import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/views/groups/groups_view.dart';
import 'package:teachers_app/ui/views/payments/payments_view.dart';
import 'package:teachers_app/ui/views/sessions/sessions_view.dart';
import 'package:teachers_app/ui/views/students/students_view.dart';
import 'package:teachers_app/ui/widgets/app_bottom_nav.dart';

import 'main_viewmodel.dart';

class MainView extends StackedView<MainViewModel> {
  const MainView({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget builder(BuildContext context, MainViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: viewModel.currentIndex,
        children: const [GroupsView(), SessionsView(), StudentsView(), PaymentsView()],
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: viewModel.currentIndex, onTap: viewModel.setIndex),
    );
  }

  @override
  void onViewModelReady(MainViewModel viewModel) => viewModel.verifySession();

  @override
  MainViewModel viewModelBuilder(BuildContext context) => MainViewModel()..setIndex(initialTab);
}
