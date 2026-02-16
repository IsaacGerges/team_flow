import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

// Pages
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';

// Home Page (مؤقتاً هنعمل كلاس بسيط)
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(AppStrings.home),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.go('/login');
          },
        ),
      ],
    ),
    body: const Center(child: Text(AppStrings.welcomeToTeamFlow)),
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/login', // هنخليها مؤقتاً login لحد ما نعمل check auth
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
