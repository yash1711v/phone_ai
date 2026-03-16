import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
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
import '../../../../shared/widgets/phone_with_country_field.dart';
import '../../../../shared/widgets/recaptcha_webview_dialog.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
/// Create account: Firebase (email or social) → create account API (get id) → redirect to Send OTP screen.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  String _dialCode = '+1';
  String _countryCode = 'US';

  /// Set before calling createAccount; used when navigating to OTP screen.
  String? _pendingIdToken;
  String? _pendingFullPhone;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhone =>
      '${_dialCode.replaceAll(' ', '')}${_phoneController.text.trim()}';

  Future<void> _createWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.phoneRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      final auth = getIt<FirebaseAuth>();
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = auth.currentUser;
      if (user == null) throw Exception('Failed to create user');
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      final idToken = await user.getIdToken();
      if (idToken == null) throw Exception('Failed to get token');
      _pendingIdToken = idToken;
      _pendingFullPhone = _fullPhone;
      final cubit = context.read<AuthCubit>();
      final token = await getRecaptchaToken(
        context: context,
        action: RecaptchaAction.accountCreate,
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
      cubit.createAccount(
        name: name.isNotEmpty ? name : email.split('@').first,
        email: email,
        phoneNumber: _fullPhone,
        idToken: idToken,
        recaptchaToken: token,
      );
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

  Future<void> _createWithGoogle() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.phoneRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      final auth = getIt<FirebaseAuth>();
      final googleSignIn = getIt<GoogleSignIn>();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCred = await auth.signInWithCredential(cred);
      final user = userCred.user;
      if (user == null) throw Exception('Failed to sign in');
      final displayName = user.displayName ??
          (name.isNotEmpty ? name : (user.email?.split('@').first ?? 'User'));
      final email = user.email ?? _emailController.text.trim();
      if (email.isEmpty) throw Exception('Email is required');
      final idToken = await user.getIdToken();
      if (idToken == null) throw Exception('Failed to get token');
      _pendingIdToken = idToken;
      _pendingFullPhone = _fullPhone;
      final cubit = context.read<AuthCubit>();
      final token = await getRecaptchaToken(
        context: context,
        action: RecaptchaAction.accountCreate,
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
      cubit.createAccount(
        name: displayName,
        email: email,
        phoneNumber: _fullPhone,
        idToken: idToken,
        recaptchaToken: token,
      );
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

  Future<void> _createWithApple() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.phoneRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
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
      final userCred = await auth.signInWithCredential(oauthCred);
      final user = userCred.user;
      if (user == null) throw Exception('Failed to sign in');
      final displayName =
      '${appleCred.givenName ?? ''} ${appleCred.familyName ?? ''}'
          .trim();
      final finalName =
      displayName.isNotEmpty ? displayName : (name.isNotEmpty ? name : 'User');
      final email =
          user.email ?? appleCred.email ?? _emailController.text.trim();
      if (email.isEmpty) throw Exception('Email is required');
      final idToken = await user.getIdToken();
      if (idToken == null) throw Exception('Failed to get token');
      _pendingIdToken = idToken;
      _pendingFullPhone = _fullPhone;
      final cubit = context.read<AuthCubit>();
      final token = await getRecaptchaToken(
        context: context,
        action: RecaptchaAction.accountCreate,
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
      cubit.createAccount(
        name: finalName,
        email: email,
        phoneNumber: _fullPhone,
        idToken: idToken,
        recaptchaToken: token,
      );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
      ),
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
          if (state is AuthAccountCreated) {
            final idToken = _pendingIdToken;
            final phone = _pendingFullPhone;
            if (idToken != null && phone != null) {
              context.pushNamed(
                'verify-phone-otp',
                extra: {
                  'accountId': state.accountId,
                  'idToken': idToken,
                  'phoneNumber': phone,
                },
              );
            }
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Full name',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.emailRequired;
                        if (!v.contains('@')) return AppStrings.emailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.password,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.passwordRequired;
                        if (v.length < 8) return AppStrings.passwordMinLength;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PhoneWithCountryField(
                      label: AppStrings.phoneNumber,
                      controller: _phoneController,
                      dialCode: _dialCode,
                      countryCode: _countryCode,
                      onDialCodeChanged: (c) {
                        setState(() {
                          _dialCode = c.dialCode ?? '+1';
                          _countryCode = c.code ?? 'US';
                        });
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.phoneRequired;
                        if (v.length < 10) return AppStrings.phoneInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          text: 'Sign up with email',
                          onPressed:
                          state is AuthLoading ? null : _createWithEmail,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state is AuthLoading
                                ? null
                                : _createWithGoogle,
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: const Text(AppStrings.signInWithGoogle),
                          ),
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: state is AuthLoading
                                  ? null
                                  : _createWithApple,
                              icon: const Icon(Icons.apple, size: 24),
                              label: const Text(AppStrings.signInWithApple),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(AppStrings.alreadyHaveAccount),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
