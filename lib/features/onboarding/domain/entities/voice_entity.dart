import 'package:equatable/equatable.dart';

/// Domain entity for selected voice (provider + id + model).
class VoiceEntity extends Equatable {
  final String provider;
  final String id;
  final String name;
  final String voiceModel;

  const VoiceEntity({
    required this.provider,
    required this.id,
    required this.name,
    required this.voiceModel,
  });

  @override
  List<Object?> get props => [provider, id, name, voiceModel];
}
