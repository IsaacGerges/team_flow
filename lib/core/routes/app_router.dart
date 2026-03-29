import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/widgets/main_scaffold.dart';
import 'package:team_flow/features/home/presentation/pages/home_dashboard_page.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/pages/add_member_page.dart';
import 'package:team_flow/features/teams/presentation/pages/create_team_page.dart';
import 'package:team_flow/features/teams/presentation/pages/team_details_page.dart';
import 'package:team_flow/features/teams/presentation/pages/teams_list_page.dart';
import 'package:team_flow/features/teams/presentation/pages/update_team_page.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/pages/profile_page.dart';
import 'package:team_flow/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/pages/create_task_page.dart';
import 'package:team_flow/features/tasks/presentation/pages/my_tasks_page.dart';
import 'package:team_flow/features/tasks/presentation/pages/task_assignment_page.dart';
import 'package:team_flow/features/tasks/presentation/pages/task_details_page.dart';
import 'package:team_flow/features/tasks/presentation/create_task_page_args.dart';

import 'package:team_flow/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:team_flow/features/notifications/presentation/pages/notifications_page.dart';
import 'package:team_flow/features/splash/presentation/pages/splash_page.dart';
import 'package:team_flow/injection_container.dart';
import 'package:team_flow/features/onboarding/presentation/pages/onboarding_page.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../helpers/cache_helper.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'homeNav',
);
final GlobalKey<NavigatorState> _tasksNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'tasksNav',
);
final GlobalKey<NavigatorState> _teamsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'teamsNav',
);
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profileNav');
final GlobalKey<NavigatorState> _notificationsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'notificationsNav');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) {
    final cacheHelper = sl<CacheHelper>();
    final userId = cacheHelper.getData(key: CacheKeys.userId);
    final hasSeenOnboarding =
        cacheHelper.getData(key: CacheKeys.hasSeenOnboarding) ?? false;
    final isLoggedIn = userId != null;

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToSignup = state.matchedLocation == '/signup';
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToOnboarding = state.matchedLocation == '/onboarding';

    if (isGoingToSplash) return null;

    if (!hasSeenOnboarding && !isGoingToOnboarding) {
      return '/onboarding';
    }

    if (hasSeenOnboarding && isGoingToOnboarding) {
      if (isLoggedIn) return '/home';
      return '/login';
    }

    if (!isLoggedIn &&
        !isGoingToLogin &&
        !isGoingToSignup &&
        !isGoingToOnboarding) {
      return '/login';
    }
    if (isLoggedIn &&
        (isGoingToLogin || isGoingToSignup || isGoingToOnboarding)) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ProfileCubit>()),
            BlocProvider(create: (_) => sl<TeamsCubit>()),
            BlocProvider(create: (_) => sl<TasksCubit>()),
            BlocProvider(create: (_) => sl<NotificationsCubit>()),
          ],
          child: MainScaffoldWithNavBar(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeDashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _teamsNavigatorKey,
          routes: [
            GoRoute(
              path: '/teams',
              name: 'teams',
              builder: (context, state) => const TeamsListPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'createTeam',
                  builder: (context, state) => const CreateTeamPage(),
                ),
                GoRoute(
                  path: 'update',
                  name: 'updateTeam',
                  builder: (context, state) {
                    final team = state.extra as TeamEntity;
                    return UpdateTeamPage(team: team);
                  },
                ),
                GoRoute(
                  path: 'details',
                  name: 'teamDetails',
                  builder: (context, state) {
                    final team = state.extra as TeamEntity;
                    return TeamDetailsPage(team: team);
                  },
                ),
                GoRoute(
                  path: 'add-member',
                  name: 'addMember',
                  builder: (context, state) {
                    final team = state.extra as TeamEntity;
                    return AddMemberPage(team: team);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _tasksNavigatorKey,
          routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (context, state) => const MyTasksPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'createTask',
                  builder: (context, state) {
                    final args = state.extra as CreateTaskPageArgs?;
                    return CreateTaskPage(args: args);
                  },
                ),

                GoRoute(
                  path: 'details',
                  name: 'taskDetails',
                  builder: (context, state) {
                    final task = state.extra as TaskEntity;
                    return TaskDetailsPage(task: task);
                  },
                ),
                GoRoute(
                  path: 'assign',
                  name: 'taskAssignment',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return TaskAssignmentPage(
                      teamId: extra['teamId'] as String,
                      currentAssigneeIds:
                          extra['currentAssigneeIds'] as List<String>,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'editProfile',
                  builder: (context, state) => const EditProfilePage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _notificationsNavigatorKey,
          routes: [
            GoRoute(
              path: '/notifications',
              name: 'notifications',
              builder: (context, state) => const NotificationsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
