import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  final int pageIndex;

  const OnboardingInitial({this.pageIndex = 0});

  @override
  List<Object?> get props => [pageIndex];
}

class OnboardingPageChanged extends OnboardingState {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class OnboardingCompleted extends OnboardingState {}
