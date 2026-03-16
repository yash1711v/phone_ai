import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../data/constants/voice_constants.dart';
import '../../data/models/voice_option.dart';
import '../../../../shared/widgets/app_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Onboarding step 3 (or profile voice update): choose voice with play/stop sample; Continue creates bot and goes home.
class ChooseVoiceStep extends StatefulWidget {
  const ChooseVoiceStep({
    super.key,
    required this.isSignupFlow,
    this.progressLabel,
    required this.onBack,
  });

  final bool isSignupFlow;
  final String? progressLabel;
  final VoidCallback onBack;

  @override
  State<ChooseVoiceStep> createState() => _ChooseVoiceStepState();
}

class _ChooseVoiceStepState extends State<ChooseVoiceStep> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingUrl;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingUrl = null);
    });
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(String url) async {
    if (_playingUrl == url) {
      await _player.stop();
      setState(() => _playingUrl = null);
      return;
    }
    await _player.stop();
    await _player.play(UrlSource(url));
    setState(() => _playingUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onboardingPrimary = Color(0xFF1A365D);
    final voices = getAgentVoiceOptions();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final selected = state.selectedVoice;
        final isCreating = state.isCreatingBot;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: widget.onBack,
                  ),
                  if (widget.progressLabel != null) ...[
                    const Spacer(),
                    Text(
                      widget.progressLabel!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isCreating)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Building AI agent for your business...',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analyzing your business hours and services.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Choose voice',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onboardingPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This is who your callers will speak to when you don't answer.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...voices.map((voice) {
                        final isSelected = selected?.id == voice.id &&
                            selected?.provider == voice.provider;
                        final isPlaying = _playingUrl == voice.sampleUrl;
                        final voiceKey = '${voice.provider}/${voice.id}';
                        final groupKey = selected == null
                            ? null
                            : '${selected.provider}/${selected.id}';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<OnboardingCubit>()
                                    .setSelectedVoice(voice);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? onboardingPrimary
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: voiceKey,
                                      groupValue: groupKey,
                                      onChanged: (_) {
                                        context
                                            .read<OnboardingCubit>()
                                            .setSelectedVoice(voice);
                                      },
                                      activeColor: onboardingPrimary,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${voice.name} - ${voice.provider}',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (voice.languages.isNotEmpty)
                                            Text(
                                              voice.languages.join(', '),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        Colors.grey.shade600,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isPlaying ? Icons.stop : Icons.play_circle_filled,
                                        color: onboardingPrimary,
                                        size: 36,
                                      ),
                                      onPressed: () => _togglePlay(voice.sampleUrl),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            if (!isCreating)
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  text: widget.isSignupFlow ? 'Continue' : 'Save',
                  backgroundColor: onboardingPrimary,
                  onPressed: selected == null
                      ? null
                      : () async {
                          if (!widget.isSignupFlow) {
                            // TODO: call update-voice API when available
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice preference saved'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            widget.onBack();
                            return;
                          }
                          final cubit = context.read<OnboardingCubit>();
                          final success = await cubit.createBot();
                          if (success && context.mounted) {
                            AppRouter.router.goNamed('home');
                          }
                        },
                ),
              ),
          ],
        );
      },
    );
  }
}
