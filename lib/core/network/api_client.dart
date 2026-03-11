import 'package:dio/dio.dart';

import '../error/exceptions.dart';

import 'network_info.dart';
import '../utils/logger.dart';

/// API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      statusCode: json['statusCode'],
    );
  }
}

/// API client for making HTTP requests
class ApiClient {
  final Dio dio;
  final NetworkInfo networkInfo;

  ApiClient({
    required this.dio,
    required this.networkInfo,
  });

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      LogLevel.error('GET request error', e);
      throw ServerException(e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      LogLevel.error('POST request error', e);
      throw ServerException(e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      LogLevel.error('PUT request error', e);
      throw ServerException(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      LogLevel.error('DELETE request error', e);
      throw ServerException(e.toString());
    }
  }

  /// Handle response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          fromJson,
        );
      } else {
        return ApiResponse<T>(
          success: true,
          data: fromJson != null ? fromJson(response.data) : response.data as T?,
          statusCode: response.statusCode,
        );
      }
    } else {
      throw ServerException(
        'Unexpected status code: ${response.statusCode}',
      );
    }
  }

  /// Handle Dio errors
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ??
            error.response?.data?['error'] ??
            'Server error';
        return ServerException(message, code: statusCode.toString());
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      default:
        return NetworkException(error.message ?? 'Network error');
    }
  }
}
