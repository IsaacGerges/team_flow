import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_assets.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:team_flow/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:team_flow/features/onboarding/presentation/widgets/onboarding_content_widget.dart';
import 'package:team_flow/injection_container.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    context.read<OnboardingCubit>().completeOnboarding();
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/login');
        } else if (state is OnboardingPageChanged) {
          // handled by PageView directly as the user scrolls,
          // but we listen here in case we want to programmatically change tab and sink state.
        }
      },
      builder: (context, state) {
        int currentPage = 0;
        if (state is OnboardingInitial) {
          currentPage = state.pageIndex;
        } else if (state is OnboardingPageChanged) {
          currentPage = state.pageIndex;
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16,
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: _onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.slate500,
                          ),
                          child: Text(
                            AppStrings.skip,
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          context.read<OnboardingCubit>().changePage(index);
                        },
                        children: const [
                          OnboardingContentWidget(
                            imagePath: AppAssets.onboardingManageTeams,
                            title: AppStrings.onboardingManageTeamsTitle,
                            subtitle: AppStrings.onboardingManageTeamsSub,
                          ),
                          OnboardingContentWidget(
                            imagePath: AppAssets.onboardingTrackTasks,
                            title: AppStrings.onboardingTrackTasksTitle,
                            subtitle: AppStrings.onboardingTrackTasksSub,
                          ),
                          OnboardingContentWidget(
                            imagePath: AppAssets.onboardingStayConnected,
                            title: AppStrings.onboardingStayConnectedTitle,
                            subtitle: AppStrings.onboardingStayConnectedSub,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              3,
                              (index) => _buildDot(
                                index: index,
                                currentIndex: currentPage,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: currentPage == 2 ? _onSkip : _onNext,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentPage == 2
                                        ? AppStrings.getStarted
                                        : AppStrings.next,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (currentPage != 2) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.white,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot({required int index, required int currentIndex}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentIndex == index
            ? AppColors.primaryBlue
            : AppColors.slate300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
