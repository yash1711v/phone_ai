import 'package:equatable/equatable.dart';

import '../../data/models/editable_business_data.dart';
import '../../data/models/voice_option.dart';

/// Onboarding flow step: 0 = business profile, 1 = review & edit, 2 = choose voice.
class OnboardingState extends Equatable {
  final int step;
  final EditableBusinessData? businessData;
  final List<EditableBusinessData> searchResults;
  final VoiceOption? selectedVoice;
  final bool isLoading;
  final String? errorMessage;
  final bool isCreatingBot;

  const OnboardingState({
    this.step = 0,
    this.businessData,
    this.searchResults = const [],
    this.selectedVoice,
    this.isLoading = false,
    this.errorMessage,
    this.isCreatingBot = false,
  });

  OnboardingState copyWith({
    int? step,
    EditableBusinessData? businessData,
    List<EditableBusinessData>? searchResults,
    VoiceOption? selectedVoice,
    bool? isLoading,
    String? errorMessage,
    bool? isCreatingBot,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      businessData: businessData ?? this.businessData,
      searchResults: searchResults ?? this.searchResults,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isCreatingBot: isCreatingBot ?? this.isCreatingBot,
    );
  }

  @override
  List<Object?> get props =>
      [step, businessData, searchResults, selectedVoice, isLoading, errorMessage, isCreatingBot];
}
