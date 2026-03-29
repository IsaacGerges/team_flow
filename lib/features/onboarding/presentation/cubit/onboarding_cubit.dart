import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/features/onboarding/domain/usecases/save_onboarding_status_usecase.dart';
import 'package:team_flow/features/onboarding/presentation/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SaveOnboardingStatusUseCase saveOnboardingStatusUseCase;

  OnboardingCubit({required this.saveOnboardingStatusUseCase})
    : super(const OnboardingInitial());

  void changePage(int index) {
    emit(OnboardingPageChanged(index));
  }

  Future<void> completeOnboarding() async {
    await saveOnboardingStatusUseCase();
    emit(OnboardingCompleted());
  }
}
