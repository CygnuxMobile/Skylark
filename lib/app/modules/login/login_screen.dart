import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/modules/login/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutExpo,
          builder: (context, double value, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: _buildAnimatedWidget(
                        delay: 0.1,
                        value: value,
                        child: Image.asset(
                          'assets/logo.png',
                          width: 180,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.airplanemode_active,
                            size: 80,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildAnimatedWidget(
                      delay: 0.2,
                      value: value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please login to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildAnimatedWidget(
                      delay: 0.3,
                      value: value,
                      child: CustomTextField(
                        controller: controller.userIdController,
                        hintText: 'User ID',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter User ID';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedWidget(
                      delay: 0.4,
                      value: value,
                      child: Obx(() => CustomTextField(
                        controller: controller.passwordController,
                        hintText: 'Password',
                        obscureText: !controller.isPasswordVisible.value,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryBlue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter password';
                          return null;
                        },
                      )),
                    ),
                    const SizedBox(height: 60),
                    _buildAnimatedWidget(
                      delay: 0.5,
                      value: value,
                      child: Obx(() => CustomButton(
                        text: 'LOGIN',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.login,
                      )),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedWidget({
    required double delay,
    required double value,
    required Widget child,
  }) {
    double opacity = (value - delay).clamp(0.0, 1.0) / (1.0 - delay);
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - opacity)),
        child: child,
      ),
    );
  }
}
