import 'package:livekit_client/livekit_client.dart';
import '../../core/utils/logger.dart';

/// LiveKit service for handling voice calls
class LiveKitService {
  Room? _room;
  LocalAudioTrack? _localAudioTrack;
  bool _isConnected = false;

  Room? get room => _room;
  bool get isConnected => _isConnected;

  /// Connect to LiveKit room
  /// 
  /// [token] - LiveKit access token
  /// [url] - LiveKit server URL
  Future<void> connect({
    required String token,
    required String url,
  }) async {
    try {
      LogLevel.info('Connecting to LiveKit room...');

      // Create room with options
      _room = Room(
        roomOptions: const RoomOptions(
          defaultAudioCaptureOptions: AudioCaptureOptions(
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          ),
        ),
      );
      
      // Connect to room
      await _room!.connect(
        url,
        token,
      );

      _isConnected = true;
      LogLevel.info('Connected to LiveKit room');
    } catch (e) {
      LogLevel.error('Failed to connect to LiveKit room', e);
      _isConnected = false;
      throw LiveKitE2EEException("Failed to connect to LiveKit room: ${e.toString()}");
    }
  }

  /// Enable microphone
  Future<void> enableMicrophone() async {
    try {
      if (_room == null || !_isConnected) {
        throw  LiveKitE2EEException('Not connected to room');
      }

      _localAudioTrack = await LocalAudioTrack.create();
      await _room!.localParticipant?.publishAudioTrack(_localAudioTrack!);
      LogLevel.info('Microphone enabled');
    } catch (e) {
      LogLevel.error('Failed to enable microphone', e);
      if (e is LiveKitE2EEException) rethrow;
      throw LiveKitE2EEException('Failed to enable microphone: ${e.toString()}');
    }
  }

  /// Disable microphone
  Future<void> disableMicrophone() async {
    try {
      if (_localAudioTrack != null && _room?.localParticipant != null) {
        // Find the track publication and unpublish it
        final participant = _room!.localParticipant!;
        final publications = participant.trackPublications.values
            .where((pub) => pub.track == _localAudioTrack)
            .toList();
        
        for (final publication in publications) {
          await participant.unpublishAllTracks();
        }
        
        await _localAudioTrack!.stop();
        await _localAudioTrack!.dispose();
        _localAudioTrack = null;
        LogLevel.info('Microphone disabled');
      }
    } catch (e) {
      LogLevel.error('Failed to disable microphone', e);
    }
  }

  /// Disconnect from room
  Future<void> disconnect() async {
    try {
      await disableMicrophone();
      await _room?.disconnect();
      _room = null;
      _isConnected = false;
      LogLevel.info('Disconnected from LiveKit room');
    } catch (e) {
      LogLevel.error('Failed to disconnect from LiveKit room', e);
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
  }
}
