/// Single place for environment-specific base URLs.
/// Change these once; dev/prod flavors pick the correct one at runtime.
class EnvConstants {
  EnvConstants._();

  /// Backend base URL for dev. Used when running with dev flavor.
  static const String baseUrlDev =
      'https://openmic-staging-backend-744913677085.us-central1.run.app';

  /// Backend base URL for prod. Used when running with prod flavor.
  static const String baseUrlProd =
      'https://openmic-staging-backend-744913677085.us-central1.run.app';
}
