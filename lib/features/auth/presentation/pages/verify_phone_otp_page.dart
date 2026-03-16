import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/recaptcha_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/recaptcha_webview_dialog.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// After create account: send OTP → show pin field → verify → login API (no redirect, status: Verifying → Logging in) → home.
class VerifyPhoneOtpPage extends StatefulWidget {
  final int accountId;
  final String idToken;
  final String phoneNumber;

  const VerifyPhoneOtpPage({
    super.key,
    required this.accountId,
    required this.idToken,
    required this.phoneNumber,
  });

  @override
  State<VerifyPhoneOtpPage> createState() => _VerifyPhoneOtpPageState();
}

class _VerifyPhoneOtpPageState extends State<VerifyPhoneOtpPage> {
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isVerifying = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    try {
      final token = await getRecaptchaToken(
        context: context,
        action: RecaptchaAction.sendOtp,
      );
      if (!mounted) return;
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.recaptchaFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      context.read<AuthCubit>().sendOtp(widget.accountId, token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;
    setState(() => _isVerifying = true);
    context.read<AuthCubit>().verifyOtp(widget.accountId, otp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify phone'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() => _isVerifying = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is AuthOtpSent) {
            setState(() => _otpSent = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent to your phone'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is AuthOtpVerified) {
            setState(() {
              _isVerifying = false;
              _isLoggingIn = true;
            });
            context.read<AuthCubit>().loginWithIdToken(
              widget.idToken,
              needsOnboarding: true,
            );
          }
          if (state is AuthAuthenticated) {
            if (state.needsOnboarding) {
              context.goNamed('onboarding');
            } else {
              context.goNamed('home');
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Phone number',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    enabled: false,
                    initialValue: widget.phoneNumber,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                  if (!_otpSent && isLoading) ...[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Sending OTP...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  if (_otpSent) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Enter OTP',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Pinput(
                      controller: _otpController,
                      length: 6,
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 52,
                        textStyle: theme.textTheme.titleLarge,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 52,
                        textStyle: theme.textTheme.titleLarge,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: _isVerifying
                          ? 'Verifying...'
                          : _isLoggingIn
                          ? 'Logging in...'
                          : 'Verify OTP',
                      onPressed: (_isVerifying || _isLoggingIn)
                          ? null
                          : _verifyOtp,
                      isLoading: _isVerifying || _isLoggingIn,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
