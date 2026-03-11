import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/permission_handler.dart';
import '../services/livekit_service.dart';
import '../../di/injection.dart';

/// LiveKit call widget example
class LiveKitCallWidget extends StatefulWidget {
  final String token;
  final String url;

  const LiveKitCallWidget({
    super.key,
    required this.token,
    required this.url,
  });

  @override
  State<LiveKitCallWidget> createState() => _LiveKitCallWidgetState();
}

class _LiveKitCallWidgetState extends State<LiveKitCallWidget> {
  final LiveKitService _liveKitService = getIt<LiveKitService>();
  bool _isConnected = false;
  bool _isMicrophoneEnabled = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    setState(() {
      _isConnected = _liveKitService.isConnected;
    });
  }

  Future<void> _connectToCall() async {
    try {
      // Request microphone permission
      final hasPermission = await AppPermissionHandler.requestMicrophonePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required for calls'),
            ),
          );
        }
        return;
      }

      setState(() {
        _isConnecting = true;
      });

      await _liveKitService.connect(
        token: widget.token,
        url: widget.url,
      );

      await _liveKitService.enableMicrophone();

      if (mounted) {
        setState(() {
          _isConnected = true;
          _isMicrophoneEnabled = true;
          _isConnecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleMicrophone() async {
    try {
      if (_isMicrophoneEnabled) {
        await _liveKitService.disableMicrophone();
      } else {
        await _liveKitService.enableMicrophone();
      }

      if (mounted) {
        setState(() {
          _isMicrophoneEnabled = !_isMicrophoneEnabled;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle microphone: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _endCall() async {
    try {
      await _liveKitService.disconnect();
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isMicrophoneEnabled = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end call: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.callBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isConnecting)
            const CircularProgressIndicator(color: Colors.white)
          else if (_isConnected) ...[
            const Text(
              'Connected',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _toggleMicrophone,
                  icon: Icon(
                    _isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: _endCall,
                  icon: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.callEndButton,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ] else
            ElevatedButton(
              onPressed: _connectToCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.callBackground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Start Call'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _liveKitService.dispose();
    super.dispose();
  }
}
