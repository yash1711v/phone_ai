import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_textfield.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'create_account_page.dart';

/// Primary login: email + password (Firebase) → login API → store & enter app.
/// "Don't have an account" → Create account. PHONE_NOT_VERIFIED → OTP screen.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    try {
      final auth = getIt<FirebaseAuth>();
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final idToken = await cred.user?.getIdToken();
      if (idToken == null || !mounted) return;
      context.read<AuthCubit>().loginWithIdToken(idToken);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Login failed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    debugPrint('[LoginPage] _loginWithGoogle: started');
    try {
      debugPrint('[LoginPage] _loginWithGoogle: getting FirebaseAuth and GoogleSignIn');
      final auth = getIt<FirebaseAuth>();
      final googleSignIn = getIt<GoogleSignIn>();
      debugPrint('[LoginPage] _loginWithGoogle: calling googleSignIn.signIn()...');
      final googleUser = await googleSignIn.signIn();
      debugPrint('[LoginPage] _loginWithGoogle: signIn() returned, googleUser==null: ${googleUser == null}');
      if (googleUser == null) {
        debugPrint('[LoginPage] _loginWithGoogle: user cancelled or null, returning');
        return;
      }
      debugPrint('[LoginPage] _loginWithGoogle: getting googleUser.authentication...');
      final googleAuth = await googleUser.authentication;
      debugPrint('[LoginPage] _loginWithGoogle: authentication received, building credential');
      final cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      debugPrint('[LoginPage] _loginWithGoogle: signing in to Firebase with credential...');
      final userCred = await auth.signInWithCredential(cred);
      debugPrint('[LoginPage] _loginWithGoogle: Firebase signIn done, user=${userCred.user?.uid}');
      debugPrint('[LoginPage] _loginWithGoogle: getting idToken...');
      final idToken = await userCred.user?.getIdToken();
      debugPrint('[LoginPage] _loginWithGoogle: idToken received: ${idToken != null}');
      if (idToken == null || !mounted) {
        debugPrint('[LoginPage] _loginWithGoogle: no idToken or not mounted, returning');
        return;
      }
      debugPrint('[LoginPage] _loginWithGoogle: calling AuthCubit.loginWithIdToken');
      context.read<AuthCubit>().loginWithIdToken(idToken);
      debugPrint('[LoginPage] _loginWithGoogle: loginWithIdToken called, done');
    } catch (e, st) {
      debugPrint('[LoginPage] _loginWithGoogle: ERROR $e');
      debugPrint('[LoginPage] _loginWithGoogle: stackTrace $st');
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

  Future<void> _loginWithApple() async {
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
      final idToken = await userCred.user?.getIdToken();
      if (idToken == null || !mounted) return;
      context.read<AuthCubit>().loginWithIdToken(idToken);
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
    final size = MediaQuery.of(context).size;

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
          if (state is AuthPhoneNotVerified) {
            final auth = getIt<FirebaseAuth>();
            auth.currentUser?.getIdToken().then((idToken) {
              if (idToken != null && context.mounted) {
                context.pushNamed(
                  'verify-phone-otp',
                  extra: {
                    'accountId': state.accountId,
                    'idToken': idToken,
                    'phoneNumber': '',
                  },
                );
              }
            });
          }
          if (state is AuthAuthenticated) {
            context.goNamed('home');
          }
        },
        builder: (BuildContext context, AuthState state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    minHeight:
                        size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Icon(
                          Icons.lock_person_rounded,
                          size: 80,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          AppStrings.welcomeTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.welcomeSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppTextField(
                                  label: AppStrings.email,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.emailRequired;
                                    }
                                    if (!value.contains('@')) {
                                      return AppStrings.emailInvalid;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
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
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.passwordRequired;
                                    }
                                    if (value.length < 8) {
                                      return AppStrings.passwordMinLength;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return AppButton(
                                      text: AppStrings.login,
                                      onPressed: state is AuthLoading
                                          ? null
                                          : _loginWithEmailPassword,
                                      isLoading: state is AuthLoading,
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _loginWithGoogle,
                                        icon: const Icon(
                                          Icons.g_mobiledata,
                                          size: 28,
                                        ),
                                        label: Text(
                                          AppStrings.signInWithGoogle,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: theme.dividerColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (Platform.isIOS) ...[
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _loginWithApple,
                                          icon: const Icon(
                                            Icons.apple,
                                            size: 24,
                                          ),
                                          label: Text(
                                            AppStrings.signInWithApple,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            side: BorderSide(
                                              color: theme.dividerColor,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.pushNamed('create-account');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Create account',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
