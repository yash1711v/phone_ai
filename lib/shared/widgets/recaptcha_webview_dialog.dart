import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';
import 'package:flutter_gcaptcha_v3/web_view.dart';

import '../../core/constants/recaptcha_constants.dart';

/// reCAPTCHA v3 tokens from this module must be verified on the backend only.
/// Never trust or verify the token in the app; backend calls Google siteverify.

Completer<String?>? _pendingTokenCompleter;

/// Called when the hidden WebView receives a reCAPTCHA token; completes the pending completer.
void _onRecaptchaTokenReceived(String token) {
  _pendingTokenCompleter?.complete(token);
  _pendingTokenCompleter = null;
}

/// Requests a reCAPTCHA v3 token for the given [action].
/// Requires [HiddenRecaptchaWebView] to be in the widget tree and [RecaptchaHandler] site key set.
/// Returns the token or null on timeout/error.
/// Security: send the token to your backend; verify it with Google siteverify on the server only.
Future<String?> getRecaptchaToken({required String action}) async {
  _pendingTokenCompleter = Completer<String?>();
  RecaptchaHandler.executeV3(action: action);
  try {
    return await _pendingTokenCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingTokenCompleter = null;
        return null;
      },
    );
  } catch (_) {
    _pendingTokenCompleter = null;
    rethrow;
  }
}

/// Minimum size so iOS WKWebView actually loads and runs JavaScript (1x1 can fail with FWFEvaluateJavaScriptError).
const double _kRecaptchaWebViewSize = 100;

/// Hidden WebView that loads the reCAPTCHA v3 HTML from [kRecaptchaHostedHtmlUrl].
/// Uses a non-zero size so the WebView runs on iOS; positioned off-screen in the app.
/// Place once in the app (e.g. in [App] widget) so tokens can be obtained via [getRecaptchaToken].
class HiddenRecaptchaWebView extends StatelessWidget {
  const HiddenRecaptchaWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kRecaptchaWebViewSize,
      height: _kRecaptchaWebViewSize,
      child: Opacity(
        opacity: 0.01,
        child: IgnorePointer(
          ignoring: true,
          child: ReCaptchaWebView(
            width: _kRecaptchaWebViewSize,
            height: _kRecaptchaWebViewSize,
            url: kRecaptchaHostedHtmlUrl,
            onTokenReceived: _onRecaptchaTokenReceived,
          ),
        ),
      ),
    );
  }
}
