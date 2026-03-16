import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../di/injection.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/business_profile_step.dart';
import '../widgets/choose_voice_step.dart';
import '../widgets/review_edit_step.dart';

/// Single onboarding flow: step 0 (business profile) → 1 (review & edit) → 2 (choose voice) → create bot → home.
/// When [isSignupFlow] is false (e.g. from profile), only the voice step is shown for updating voice.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, this.isSignupFlow = true});

  final bool isSignupFlow;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: _OnboardingView(isSignupFlow: isSignupFlow),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({required this.isSignupFlow});

  final bool isSignupFlow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<OnboardingCubit, OnboardingState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<OnboardingCubit>().clearError();
            }
          },
          builder: (context, state) {
            final step = isSignupFlow ? state.step : 2;
            final totalSteps = isSignupFlow ? 3 : 1;
            final currentStepIndex = isSignupFlow ? state.step + 1 : 1;

            if (step == 0) {
              return BusinessProfileStep(
                progressLabel: '$currentStepIndex/$totalSteps',
                onBack: () => Navigator.of(context).maybePop(),
              );
            }
            if (step == 1) {
              return ReviewEditStep(
                businessData: state.businessData!,
                progressLabel: '$currentStepIndex/$totalSteps',
                onBack: () => context.read<OnboardingCubit>().goToStep(0),
              );
            }
            return ChooseVoiceStep(
              isSignupFlow: isSignupFlow,
              progressLabel: isSignupFlow ? '$currentStepIndex/$totalSteps' : null,
              onBack: isSignupFlow
                  ? () => context.read<OnboardingCubit>().goToStep(1)
                  : () => Navigator.of(context).maybePop(),
            );
          },
        ),
      ),
    );
  }
}
