import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithApple();

  Future<bool> checkEmailRegistered(String email);

  Future<String> sendOtpToPhone(String phoneNumber);

  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? verificationId,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.apiClient,
  });

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('User not found');
      }

      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Failed to create user');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await firebaseAuth.signInWithCredential(oauthCredential);
      if (userCredential.user == null) {
        throw const AuthException('Failed to sign in with Apple');
      }

      // Update display name if available
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
          await userCredential.user!.reload();
        }
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<bool> checkEmailRegistered(String email) async {
    try {
      final response = await apiClient.post(
        ApiConstants.checkEmail,
        data: {'email': email},
      );

      return response.data ?? false;
    } catch (e) {
      throw ServerException('Failed to check email: ${e.toString()}');
    }
  }

  @override
  Future<String> sendOtpToPhone(String phoneNumber) async {
    try {
      String? verificationId;
      
      // Send OTP via Firebase Phone Auth
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto verification completed
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthException(_getFirebaseErrorMessage(e));
        },
        codeSent: (String vid, int? resendToken) {
          verificationId = vid;
        },
        codeAutoRetrievalTimeout: (String vid) {
          verificationId = vid;
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait for verification ID
      int attempts = 0;
      while (verificationId == null && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }

      if (verificationId == null) {
        throw const AuthException('Failed to get verification ID');
      }

      // Also send OTP via API (optional)
      try {
        await apiClient.post(
          ApiConstants.sendOtp,
          data: {'phoneNumber': phoneNumber},
        );
      } catch (e) {
        // API call is optional, continue with Firebase verification ID
      }

      return verificationId!;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? verificationId,
  }) async {
    try {
      String? vid = verificationId;
      
      // If verification ID not provided, try to get from API
      if (vid == null) {
        try {
          final response = await apiClient.post(
            ApiConstants.verifyOtp,
            data: {
              'phoneNumber': phoneNumber,
              'otp': otp,
            },
          );
          vid = response.data?['verificationId'];
        } catch (e) {
          // API call failed, will use Firebase directly
        }
      }

      if (vid == null) {
        throw const AuthException('Verification ID is required');
      }

      // Sign in with phone credential
      final credential = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otp,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw const AuthException('Failed to verify OTP');
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> refreshToken() async {
    try {
      await firebaseAuth.currentUser?.getIdToken(true);
    } catch (e) {
      throw AuthException('Failed to refresh token: ${e.toString()}');
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
