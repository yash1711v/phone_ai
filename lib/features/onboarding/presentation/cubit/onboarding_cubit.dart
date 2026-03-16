import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/constants/voice_constants.dart';
import '../../data/models/editable_business_data.dart';
import '../../data/models/voice_option.dart';
import '../../domain/entities/editable_business_entity.dart';
import '../../domain/entities/voice_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'onboarding_state.dart';

/// Cubit for the 3-step onboarding flow: business profile → review & edit → choose voice → create bot.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository) : super(const OnboardingState());

  final OnboardingRepository _repository;

  /// Search businesses (Google Business tab). On success stores results and stays on step 0 until user picks one.
  Future<void> searchBusiness({
    required String textQuery,
    double? latitude,
    double? longitude,
  }) async {
    if (textQuery.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a business name'));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.searchBusiness(
      textQuery: textQuery,
      latitude: latitude,
      longitude: longitude,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (entities) {
        final asData = entities
            .map((e) => EditableBusinessData(
                  businessName: e.businessName,
                  phoneNumber: e.phoneNumber,
                  address: e.address,
                  summary: e.summary,
                  services: List.from(e.services),
                  website: e.website,
                ))
            .toList();
        emit(state.copyWith(
          isLoading: false,
          searchResults: asData,
          errorMessage: asData.isEmpty ? 'No businesses found' : null,
        ));
      },
    );
  }

  /// Analyze website (Website tab). On success sets businessData and moves to step 1.
  Future<void> analyzeWebsite(String websiteUrl) async {
    final url = websiteUrl.trim();
    if (url.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a website address'));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.analyzeWebsite(url);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (entity) {
        final data = EditableBusinessData(
          businessName: entity.businessName,
          phoneNumber: entity.phoneNumber,
          address: entity.address,
          summary: entity.summary,
          services: List.from(entity.services),
          website: null,
        );
        emit(state.copyWith(
          isLoading: false,
          businessData: data,
          searchResults: [],
          step: 1,
        ));
      },
    );
  }

  /// Clear search results (e.g. when user clears the search field).
  void clearSearchResults() {
    emit(state.copyWith(searchResults: [], errorMessage: null));
  }

  /// Pick a search result by index and go to step 1.
  void selectSearchResult(int index) {
    final list = state.searchResults;
    if (index < 0 || index >= list.length) return;
    emit(state.copyWith(
      businessData: list[index],
      searchResults: [],
      step: 1,
    ));
  }

  /// Update business data (review & edit screen).
  void updateBusiness(EditableBusinessData data) {
    emit(state.copyWith(businessData: data));
  }

  /// Go to step 2 (choose voice) with current business data.
  /// Sets first voice as default if none selected.
  void goToChooseVoice() {
    if (state.businessData == null) return;
    final options = getAgentVoiceOptions();
    final defaultVoice =
        state.selectedVoice ?? (options.isNotEmpty ? options.first : null);
    emit(state.copyWith(step: 2, selectedVoice: defaultVoice));
  }

  /// Set selected voice.
  void setSelectedVoice(VoiceOption? voice) {
    emit(state.copyWith(selectedVoice: voice));
  }

  /// Create quick bot and then caller should navigate to home.
  Future<bool> createBot() async {
    final business = state.businessData;
    final voice = state.selectedVoice;
    if (business == null || voice == null) return false;
    emit(state.copyWith(isCreatingBot: true, errorMessage: null));
    final businessEntity = EditableBusinessEntity(
      businessName: business.businessName,
      phoneNumber: business.phoneNumber,
      address: business.address,
      summary: business.summary,
      services: List.from(business.services),
      website: business.website,
    );
    final voiceEntity = VoiceEntity(
      provider: voice.provider,
      id: voice.id,
      name: voice.name,
      voiceModel: voice.voiceModel,
    );
    final result = await _repository.createQuickBot(
      business: businessEntity,
      voice: voiceEntity,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(
          isCreatingBot: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(isCreatingBot: false));
        return true;
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void goToStep(int step) {
    emit(state.copyWith(step: step, errorMessage: null));
  }
}
