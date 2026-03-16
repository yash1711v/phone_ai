import '../models/voice_option.dart';

/// Base URL for OpenMic voice assets.
const String kVoiceAssetsBaseUrl = 'https://content.openmic.ai/assets';

/// OpenAI TTS voice model used for create-quick-bot.
const String kOpenAIVoiceModel = 'tts-1';

/// Flattened list of agent voices (OpenAI first to match design; more providers can be added).
/// Used for onboarding Choose Voice and profile voice selection.
List<VoiceOption> getAgentVoiceOptions() {
  return [
    // OpenAI (design shows Alloy, Nova, Fable, Onyx, Echo)
    const VoiceOption(
      provider: 'OpenAI',
      id: 'alloy',
      name: 'Alloy',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/alloy.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'ash',
      name: 'Ash',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/ash.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'coral',
      name: 'Coral',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/coral.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'echo',
      name: 'Echo',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/echo.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'fable',
      name: 'Fable',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/fable.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'onyx',
      name: 'Onyx',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/onyx.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'nova',
      name: 'Nova',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/nova.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'shimmer',
      name: 'Shimmer',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/shimmer.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'OpenAI',
      id: 'sage',
      name: 'Sage',
      sampleUrl: 'https://cdn.openai.com/API/docs/audio/sage.wav',
      voiceModel: kOpenAIVoiceModel,
      languages: ['English'],
    ),
    // ElevenLabs (sample subset)
    VoiceOption(
      provider: 'ElevenLabs',
      id: '7EzWGsX10sAS4c9m9cPf',
      name: 'Joe',
      sampleUrl: '$kVoiceAssetsBaseUrl/elevenlabs/joe.mp3',
      voiceModel: 'eleven_turbo_v2_5',
      languages: ['English'],
    ),
    VoiceOption(
      provider: 'ElevenLabs',
      id: 'h2I5OFX58E5TL5AitYwR',
      name: 'Jammy',
      sampleUrl: '$kVoiceAssetsBaseUrl/elevenlabs/jammy.mp3',
      voiceModel: 'eleven_turbo_v2_5',
      languages: ['English'],
    ),
    VoiceOption(
      provider: 'ElevenLabs',
      id: 'kdmDKE6EkgrWrrykO9Qt',
      name: 'Alex - Multilingual',
      sampleUrl: '$kVoiceAssetsBaseUrl/elevenlabs/alex.mp3',
      voiceModel: 'eleven_multilingual_v2',
      languages: ['English'],
    ),
    // Rime
    const VoiceOption(
      provider: 'Rime',
      id: 'luna',
      name: 'Luna',
      sampleUrl:
          'https://pub-51596c8bfd8e406ca4cc7238f28b1ee3.r2.dev/audio/luna/ffa7397bd94e333b_filtered.mp3',
      voiceModel: 'mistv2',
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'Rime',
      id: 'celeste',
      name: 'Celeste',
      sampleUrl:
          'https://pub-51596c8bfd8e406ca4cc7238f28b1ee3.r2.dev/audio/celeste/ff334bbfe1307cbb_filtered.mp3',
      voiceModel: 'mistv2',
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'Rime',
      id: 'orion',
      name: 'Orion',
      sampleUrl:
          'https://pub-51596c8bfd8e406ca4cc7238f28b1ee3.r2.dev/audio/orion/ff334bbfe1307cbb_filtered.mp3',
      voiceModel: 'mistv2',
      languages: ['English'],
    ),
    // Deepgram
    const VoiceOption(
      provider: 'Deepgram',
      id: 'aura-2-thalia-en',
      name: 'Thalia',
      sampleUrl: 'https://static.deepgram.com/examples/Aura-2-thalia.wav',
      voiceModel: 'aura-2',
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'Deepgram',
      id: 'aura-2-andromeda-en',
      name: 'Andromeda',
      sampleUrl: 'https://static.deepgram.com/examples/Aura-2-andromeda.wav',
      voiceModel: 'aura-2',
      languages: ['English'],
    ),
    const VoiceOption(
      provider: 'Deepgram',
      id: 'aura-2-apollo-en',
      name: 'Apollo',
      sampleUrl: 'https://static.deepgram.com/examples/Aura-2-apollo.wav',
      voiceModel: 'aura-2',
      languages: ['English'],
    ),
  ];
}
