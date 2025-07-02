import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validator.dart';
import '../../../shared/widgets/textfield.dart';
import '../../../shared/widgets/button.dart';
import '../provider/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final cardWidth = isMobile ? 90.w : (constraints.maxWidth > 1200 ? 30.w : 40.w);

          return SingleChildScrollView(
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF19013B), Color(0xFF8E2DE2), Color(0xFF19013B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 5.h,
                            backgroundColor: const Color(0xFF19013B),
                            child: const Icon(Icons.person_add, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 3.h,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Center(
                          child: Text(
                            'Sign up to get started with your tasks',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        /// Email
                        Text('Email Address', style: _labelStyle()),
                        SizedBox(height: 1.h),
                        TextFieldWidget(
                          controller: emailController,
                          label: "Email",
                          inputType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),

                        /// Password
                        SizedBox(height: 2.h),
                        Text('Password', style: _labelStyle()),
                        SizedBox(height: 1.h),
                        TextFieldWidget(
                          controller: passwordController,
                          label: "Password",
                          obscureText: true,
                          validator: Validators.validatePassword,
                        ),

                        /// Confirm Password
                        SizedBox(height: 2.h),
                        Text('Confirm Password', style: _labelStyle()),
                        SizedBox(height: 1.h),
                        TextFieldWidget(
                          controller: confirmPassController,
                          label: "Confirm Password",
                          obscureText: true,
                          validator: (val) => Validators.validateConfirmPassword(
                            val,
                            passwordController.text,
                          ),
                        ),

                        if (authProvider.error != null)
                          Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(
                              authProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        SizedBox(height: 3.h),

                        /// Signup Button
                        ButtonWidget(
                          label: "Sign Up",
                          textColor: Colors.white,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final result = await authProvider.signup(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              if (result == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Account created successfully! Please login."),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                await Future.delayed(const Duration(milliseconds: 500));
                                Navigator.pushReplacementNamed(context, AppRoutes.login);
                              }
                            }
                          },
                        ),

                        SizedBox(height: 2.h),

                        /// Already have an account
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: const Color(0xFF4A00E0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TextStyle _labelStyle() {
    return const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }
}
