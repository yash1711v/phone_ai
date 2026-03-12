import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/recaptcha_constants.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_textfield.dart';
import '../../../../shared/widgets/recaptcha_webview_dialog.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'create_account_page.dart';

/// First auth screen: phone number → OTP → then complete sign-in with idToken.
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  int? _accountId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = "+91"+_phoneController.text.trim();
    try {
      final token = await getRecaptchaToken(
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
      context.read<AuthCubit>().requestOtp(phone, token);
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

  Future<void> _handleVerifyOtp() async {
    if (_accountId == null) return;
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.otpInvalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(_accountId!, _otpController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is AuthAccountNotFound) {
            context.pushNamed('create-account');
          }
          if (state is AuthOtpSent) {
            setState(() {
              _otpSent = true;
              _accountId = state.accountId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.otpSent),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is AuthOtpVerified) {
            _accountId = state.accountId;
            _showCompleteSignInSheet();
          }
          if (state is AuthAuthenticated) {
            context.goNamed('home');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 80,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _otpSent ? 'Enter OTP' : 'Enter your phone number',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!_otpSent) ...[
                        AppTextField(
                          label: AppStrings.phoneNumber,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.phoneRequired;
                            if (v.length < 10) return AppStrings.phoneInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Send OTP',
                          onPressed: state is AuthLoading ? null : _handleSendOtp,
                          isLoading: state is AuthLoading,
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => context.pushNamed('create-account'),
                          child: const Text("Don't have an account? Sign up"),
                        ),
                      ] else ...[
                        AppTextField(
                          label: 'OTP',
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.otpRequired;
                            if (v.length != 6) return AppStrings.otpInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Verify OTP',
                          onPressed: state is AuthLoading ? null : _handleVerifyOtp,
                          isLoading: state is AuthLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _otpSent = false;
                              _otpController.clear();
                            });
                          },
                          child: const Text('Change number'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCompleteSignInSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CompleteSignInSheet(
          accountId: _accountId!,
          onSuccess: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// Bottom sheet to get idToken (email/password or Google/Apple) and call login.
class _CompleteSignInSheet extends StatefulWidget {
  final int accountId;
  final VoidCallback onSuccess;

  const _CompleteSignInSheet({
    required this.accountId,
    required this.onSuccess,
  });

  @override
  State<_CompleteSignInSheet> createState() => _CompleteSignInSheetState();
}

class _CompleteSignInSheetState extends State<_CompleteSignInSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithIdToken(String idToken) async {
    await context.read<AuthCubit>().loginWithIdToken(idToken);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Complete sign in',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in with email or social to finish',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: AppStrings.email,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: AppStrings.password,
            controller: _passwordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outlined),
          ),
          const SizedBox(height: 24),
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), behavior: SnackBarBehavior.floating),
                );
              }
              if (state is AuthAuthenticated) {
                widget.onSuccess();
              }
            },
            builder: (context, state) {
              return AppButton(
                text: AppStrings.login,
                onPressed: state is AuthLoading
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;
                        if (email.isEmpty || password.isEmpty) return;
                        try {
                          final credential = await _getFirebaseIdTokenEmail(email, password);
                          if (credential != null && mounted) {
                            await _loginWithIdToken(credential);
                          }
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
                      },
                isLoading: state is AuthLoading,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final idToken = await _getFirebaseIdTokenGoogle();
                      if (idToken != null && mounted) await _loginWithIdToken(idToken);
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
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text(AppStrings.signInWithGoogle),
                ),
              ),
              if (Platform.isIOS) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                      final idToken = await _getFirebaseIdTokenApple();
                      if (idToken != null && mounted) await _loginWithIdToken(idToken);
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
                    },
                    icon: const Icon(Icons.apple, size: 24),
                    label: const Text(AppStrings.signInWithApple),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _getFirebaseIdTokenEmail(String email, String password) async {
    final auth = getIt<FirebaseAuth>();
    final cred = await auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user?.getIdToken();
  }

  Future<String?> _getFirebaseIdTokenGoogle() async {
    final auth = getIt<FirebaseAuth>();
    final googleSignIn = getIt<GoogleSignIn>();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    final cred = await auth.signInWithCredential(credential);
    return cred.user?.getIdToken();
  }

  Future<String?> _getFirebaseIdTokenApple() async {
    final auth = getIt<FirebaseAuth>();
    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCred = OAuthProvider('apple.com').credential(
      idToken: appleCred.identityToken,
      accessToken: appleCred.authorizationCode,
    );
    final cred = await auth.signInWithCredential(oauthCred);
    return cred.user?.getIdToken();
  }
}
