/// Response from POST /api/v3/auth/sendOtp/:accountId
class SendOtpResponse {
  final String phoneNumber;

  const SendOtpResponse({required this.phoneNumber});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}

/// Response from POST /api/v3/auth/verifyOtp/:accountId
class VerifyOtpResponse {
  final bool success;
  final String message;

  const VerifyOtpResponse({required this.success, required this.message});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
    );
  }
}

/// Response from POST /api/v3/auth/lookupByPhone (placeholder)
/// Returns accountId when account exists.
class LookupByPhoneResponse {
  final int accountId;

  const LookupByPhoneResponse({required this.accountId});

  factory LookupByPhoneResponse.fromJson(Map<String, dynamic> json) {
    return LookupByPhoneResponse(
      accountId: json['accountId'] as int,
    );
  }
}
