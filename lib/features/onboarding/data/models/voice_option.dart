import 'package:equatable/equatable.dart';

/// Single voice option for agent (OpenAI, ElevenLabs, etc.).
class VoiceOption extends Equatable {
  final String provider;
  final String id;
  final String name;
  final String sampleUrl;
  final String voiceModel;
  final List<String> languages;

  const VoiceOption({
    required this.provider,
    required this.id,
    required this.name,
    required this.sampleUrl,
    required this.voiceModel,
    this.languages = const ['English'],
  });

  @override
  List<Object?> get props => [provider, id, name];
}
