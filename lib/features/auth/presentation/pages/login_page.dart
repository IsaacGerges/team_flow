import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: const _LoginForm(),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/home');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // 1. اللوجو والأنيميشن
                Center(
                  child: Lottie.asset(
                    'assets/animations/login.json',
                    height: size.height * 0.3,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. عنوان ترحيبي
                Text(
                  AppStrings.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. الحقول (Inputs)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.emailAddress,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) => val!.isEmpty ? AppStrings.required : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? AppStrings.required : null,
                ),

                // 4. "Forgot Password?" (هسيبلك دي تحدي تعمله بعدين)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. زرار الـ Login
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                        child: const Text(AppStrings.login),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 6. Social Login & Register Link
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.or,
                        style: const TextStyle(color: AppColors.textHint),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Image.asset(
                      'assets/icons/google.png',
                      height: 24,
                    ), // هات صورة لوجو جوجل وحطها
                    label: const Text(AppStrings.signInWithGoogle),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Call Cubit
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                  ),
                ),
                // Center(child: SocialLoginButtons()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.dontHaveAccount,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: const Text(AppStrings.signUp),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
