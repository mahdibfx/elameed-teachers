import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/fade_in_up.dart';

import 'login_viewmodel.dart';

// ponytail: no login design was provided — built from the app's existing components.
class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(BuildContext context, LoginViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.screenPadding),
            child: FadeInUp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryColorLight,
                      child: Icon(Icons.school_outlined, size: 34, color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(child: CustomText.titleLarge(text: 'login.title'.tr())),
                  const SizedBox(height: 6),
                  CustomText.bodySmall(text: 'login.subtitle'.tr(), textAlign: TextAlign.center, maxLines: 2),
                  const SizedBox(height: 32),
                  CustomInput(
                    controller: viewModel.emailController,
                    hintText: 'login.email'.tr(),
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: viewModel.passwordController,
                    hintText: 'login.password'.tr(),
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  CustomButton.submit(onPressed: viewModel.onLogin, text: 'login.submit'.tr(), isLoading: viewModel.isBusy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}
