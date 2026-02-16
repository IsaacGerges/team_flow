import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container.dart'; // عشان نجيب sl
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createAccount)),
      body: BlocProvider(
        create: (_) => sl<AuthCubit>(), // نفس الـ Cubit بس هنا هنستخدم register
        child: const _SignUpForm(),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  // 1. زودنا Controller للاسم
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // لو نجح، وديه ع الصفحة الرئيسية
            context.go('/home');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.accountCreated),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AuthFailure) {
            // لو فشل، طلع رسالة خطأ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // لو بيحمل، طلع Loading Indicator
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // 2. خانة الاسم (Name Field)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.fullName,
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? AppStrings.enterYourName : null,
                  ),
                  const SizedBox(height: 15),

                  // خانة الإيميل
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        !val!.contains('@') ? AppStrings.enterValidEmail : null,
                  ),
                  const SizedBox(height: 15),

                  // خانة الباسورد
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (val) =>
                        val!.length < 6 ? AppStrings.passwordMinLength : null,
                  ),
                  const SizedBox(height: 30),

                  // 3. زرار التسجيل (Register Button)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // هنا بننادي على دالة Register في الـ Cubit
                          context.read<AuthCubit>().register(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _nameController.text.trim(), // بعتنا الاسم كمان
                          );
                        }
                      },
                      child: const Text(
                        AppStrings.signUp,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  // زرار يوديك لصفحة الـ Login لو عندك حساب
                  TextButton(
                    onPressed: () {
                      context.pop(); // ارجع للصفحة اللي قبلها (Login)
                    },
                    child: const Text(AppStrings.alreadyHaveAccount),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
