/// Application strings constants
class AppStrings {
  // App Info
  static const String appName = 'Openmic';

  // Auth
  static const String login = 'Sign In';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String phoneNumber = 'Phone Number';
  static const String forgotPassword = 'Forgot password?';
  static const String rememberMe = 'Remember for 30 days';
  static const String dontHaveAccount = "Don't have an account? Sign up";
  static const String alreadyHaveAccount = 'Already have an account? Sign in';
  static const String signInWithGoogle = 'Google';
  static const String signInWithApple = 'Apple';
  static const String continueText = 'Continue';
  static const String skip = 'Skip';
  static const String goLive = 'Go live!';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String otpRequired = 'OTP is required';
  static const String otpInvalid = 'Please enter a valid 6-digit OTP';

  // Error Messages
  static const String recaptchaFailed = 'Security check failed. Please try again.';
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError = 'Network error. Please check your connection';
  static const String userNotFound = 'User not found';
  static const String invalidCredentials = 'Invalid email or password';
  static const String emailAlreadyExists = 'Email already exists';
  static const String weakPassword = 'Password is too weak';
  static const String otpExpired = 'OTP has expired';
  static const String otpInvalidError = 'Invalid OTP';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Account created successfully';
  static const String otpSent = 'OTP sent to your phone number';
  static const String otpVerified = 'OTP verified successfully';

  // Onboarding
  static const String welcomeTitle = "Let Openmic handle your calls — like a pro";
  static const String welcomeSubtitle = 'Set up your AI receptionist in seconds and never miss a business call again.';
  static const String setupAgentTitle = "Welcome - let's setup our agent. It takes 2 minutes.";
  static const String setupAgentSubtitle = 'We answer your calls and handles messages, so you can focus on your business.';
  static const String chooseVoiceTitle = 'Choose voice';
  static const String chooseVoiceSubtitle = "This is who your callers will speak to when you don't answer.";
  static const String buildingAgentTitle = 'Building AI agent for your business...';
  static const String buildingAgentSubtitle = 'Analyzing your business hours and services...';
  static const String readyForDemoTitle = 'Ready for demo?';
  static const String readyForDemoSubtitle = 'Hear how Jack handles a real call to your business.';
  static const String startDemoCall = 'Start demo call';
  static const String skipDemo = 'Skip demo, Go live!';

  // Permissions
  static const String microphonePermissionRequired = 'Microphone permission is required for calls';
  static const String permissionDenied = 'Permission denied';
  static const String permissionPermanentlyDenied = 'Permission permanently denied. Please enable it in settings.';
}
