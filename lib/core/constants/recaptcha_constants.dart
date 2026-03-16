/// reCAPTCHA v3 (standard) site key. In reCAPTCHA admin, add domain:
/// app.openmic.ai (where recaptcha.html is hosted).
/// Create/use a v3 key at https://www.google.com/recaptcha/admin.
const String kRecaptchaSiteKey = '6Lee2gcsAAAAALDZOyYmjuEZs5I4bwTB5UIc5xBa';

/// Hosted HTML URL for reCAPTCHA v3. Must be served from a whitelisted domain;
/// add that domain (e.g. app.openmic.ai) in the reCAPTCHA admin console.
const String kRecaptchaHostedHtmlUrl = 'https://app.openmic.ai/recaptcha.html';

/// reCAPTCHA v3 actions for API auth
class RecaptchaAction {
  static const String sendOtp = 'send_otp';
  static const String accountCreate = 'account_create';
  static const String passwordReset = 'password_reset';
}
