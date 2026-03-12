import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Handles API response status codes and error bodies in a consistent way
/// for all API calls. Use with [ApiClient] and repositories.
class ResponseHandler {
  ResponseHandler._();

  /// Parses error response body and status code into an [AppException].
  /// Uses standard fields: "error" (message), "code" (e.g. PHONE_NOT_VERIFIED).
  static AppException handleError({
    required int? statusCode,
    dynamic responseData,
  }) {
    final body = responseData is Map<String, dynamic>
        ? responseData
        : (responseData != null ? <String, dynamic>{} : null);
    final message = body?['error'] ?? body?['message'] ?? _defaultMessage(statusCode);
    final code = body?['code'] as String?;

    switch (statusCode) {
      case 400:
        return ValidationException(message, code: code);
      case 401:
        return AuthException(message, code: code);
      case 403:
        if (code == 'PHONE_NOT_VERIFIED') {
          final accountId = extractAccountId(responseData);
          if (accountId != null) {
            return PhoneNotVerifiedException(message, accountId: accountId);
          }
        }
        return AuthException(message, code: code);
      case 404:
        return ServerException(message, code: code ?? 'NOT_FOUND');
      case 409:
        return ServerException(message, code: code ?? 'CONFLICT');
      case 500:
      default:
        return ServerException(message, code: code ?? statusCode?.toString());
    }
  }

  static String _defaultMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict';
      case 500:
        return 'Internal server error';
      default:
        return 'Request failed';
    }
  }

  /// Extracts optional accountId from error body (e.g. PHONE_NOT_VERIFIED response).
  static int? extractAccountId(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return null;
    final id = responseData['accountId'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return null;
  }

  /// Handles DioException and returns appropriate AppException.
  static AppException handleDioError(DioException error) {
    if (error.type == DioExceptionType.badResponse && error.response != null) {
      return handleError(
        statusCode: error.response!.statusCode,
        responseData: error.response!.data,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Connection timeout');
    }
    if (error.type == DioExceptionType.cancel) {
      return const NetworkException('Request cancelled');
    }
    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection');
    }
    return NetworkException(error.message ?? 'Network error');
  }
}
