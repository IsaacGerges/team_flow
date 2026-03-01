import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/pages/create_team_page.dart';
import 'package:team_flow/features/teams/presentation/pages/teams_list_page.dart';
import 'package:team_flow/features/teams/presentation/pages/update_team_page.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/pages/profile_page.dart';
import 'package:team_flow/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:team_flow/injection_container.dart';

// Pages
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../helpers/cache_helper.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final cacheHelper = sl<CacheHelper>();
    final userId = cacheHelper.getData(key: CacheKeys.userId);
    final isLoggedIn = userId != null;

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToSignup = state.matchedLocation == '/signup';

    if (!isLoggedIn && !isGoingToLogin && !isGoingToSignup) {
      return '/login';
    }

    if (isLoggedIn && (isGoingToLogin || isGoingToSignup)) {
      return '/home';
    }

    return null;
  },
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
    // --- Teams Shell: shares the same TeamsCubit instance ---
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(create: (_) => sl<TeamsCubit>(), child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const TeamsListPage(),
        ),
        GoRoute(
          path: '/teams/create',
          name: 'createTeam',
          builder: (context, state) => const CreateTeamPage(),
        ),
        GoRoute(
          path: '/teams/update',
          name: 'updateTeam',
          builder: (context, state) {
            final team = state.extra as TeamEntity;
            return UpdateTeamPage(team: team);
          },
        ),
      ],
    ),
    // --- Profile Shell: shares the same ProfileCubit instance ---
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(create: (_) => sl<ProfileCubit>(), child: child);
      },
      routes: [
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/profile/edit',
          name: 'editProfile',
          builder: (context, state) => const EditProfilePage(),
        ),
      ],
    ),
  ],
);
