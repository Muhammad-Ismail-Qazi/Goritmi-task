import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validator.dart';
import '../../../shared/widgets/textfield.dart';
import '../../../shared/widgets/button.dart';
import '../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setError(null);
      authProvider.checkLoginStatus(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF19013B), Color(0xFF8E2DE2), Color(0xFF19013B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 500,
                maxWidth: 600,
              ),
              child: IntrinsicWidth(
                stepWidth: 400,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 5.h,
                            backgroundColor: const Color(0xFF19013B),
                            child: const Icon(Icons.login, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Center(
                          child: Text(
                            'Welcome Back!',
                            style: TextStyle(fontSize: 3.h, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Center(
                          child: Text(
                            'Login to your account to continue',
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
                          obscureText: authProvider.obscurePassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: authProvider.togglePasswordVisibility,
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

                        /// Login Button
                        ButtonWidget(
                          label: "Login",
                          textColor: Colors.white,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final result = await authProvider.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                              if (result == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Login successful")),
                                );
                                await Future.delayed(const Duration(milliseconds: 500));
                                Navigator.pushReplacementNamed(context, AppRoutes.home);
                              }
                            }
                          },
                        ),

                        SizedBox(height: 2.h),

                        /// Don't have an account?
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signup),
                                child: Text(
                                  "Signup",
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
          ),
        ),
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
