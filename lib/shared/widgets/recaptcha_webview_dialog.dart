import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gcaptcha_v3/constants.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/recaptcha_constants.dart';

Completer<String?>? _pendingTokenCompleter;

void _onRecaptchaTokenReceived(String token) {
  if (_pendingTokenCompleter?.isCompleted == false) {
    _pendingTokenCompleter?.complete(token);
  }
}

/// Requests a reCAPTCHA v3 token for the given [action].
/// Returns the token or null on timeout/error.
/// Security: send the token to your backend; verify it with Google siteverify on the server only.
Future<String?> getRecaptchaToken({
  required BuildContext context,
  required String action,
}) async {
  if (_pendingTokenCompleter != null) {
    return null;
  }

  _pendingTokenCompleter = Completer<String?>();
  final tokenCompleter = _pendingTokenCompleter!;
  final dialogFuture = showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dialogContext) => _RecaptchaChallengeDialog(
      action: action,
      onTokenReceived: (token) {
        _onRecaptchaTokenReceived(token);
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
      },
    ),
  );

  try {
    return await tokenCompleter.future.timeout(const Duration(seconds: 30));
  } on TimeoutException {
    if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    return null;
  } finally {
    _pendingTokenCompleter = null;
    await dialogFuture;
  }
}

class _RecaptchaChallengeDialog extends StatefulWidget {
  const _RecaptchaChallengeDialog({
    required this.action,
    required this.onTokenReceived,
  });

  final String action;
  final ValueChanged<String> onTokenReceived;

  @override
  State<_RecaptchaChallengeDialog> createState() =>
      _RecaptchaChallengeDialogState();
}

class _RecaptchaChallengeDialogState extends State<_RecaptchaChallengeDialog> {
  final Completer<void> _controllerReadyCompleter = Completer<void>();
  late final WebViewController _webController;
  bool _executed = false;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        AppConstants.readyJsName,
        onMessageReceived: (_) {},
      )
      ..addJavaScriptChannel(
        AppConstants.captchaJsName,
        onMessageReceived: (message) {
          final token = message.message.trim();
          if (token.isNotEmpty) {
            widget.onTokenReceived(token);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (_controllerReadyCompleter.isCompleted == false) {
              _controllerReadyCompleter.complete();
            }
          },
          onPageStarted: (_) {
            if (_controllerReadyCompleter.isCompleted) {
              _controllerReadyCompleter.complete();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(kRecaptchaHostedHtmlUrl));

    unawaited(_runRecaptchaAfterReady());
  }

  Future<void> _runRecaptchaAfterReady() async {
    try {
      await _controllerReadyCompleter.future;
      if (!mounted || _executed) return;
      _executed = true;

      RecaptchaHandler.instance.updateController(controller: _webController);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      RecaptchaHandler.executeV3(action: widget.action);
    } catch (_) {
      // Keep dialog alive; timeout on caller side will close it.
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Checking security',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 240,
              height: 180,
              child: WebViewWidget(controller: _webController),
            ),
          ],
        ),
      ),
    );
  }
}
