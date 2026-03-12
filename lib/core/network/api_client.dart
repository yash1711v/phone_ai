import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../error/exceptions.dart';
import 'network_info.dart';
import 'response_handler.dart';
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
      debugPrint("response==> $response");
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

  /// Handle response. Supports both wrapped format { success, data, message }
  /// and raw API body (e.g. v3 auth returns object directly).
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final hasWrapper = data.containsKey('data') || data.containsKey('success');
        if (hasWrapper && data['data'] != null && fromJson != null) {
          return ApiResponse<T>(
            success: data['success'] as bool? ?? true,
            message: data['message'] as String?,
            data: fromJson(data['data']),
            statusCode: response.statusCode,
          );
        }
        if (hasWrapper) {
          return ApiResponse.fromJson(data, fromJson);
        }
        return ApiResponse<T>(
          success: true,
          data: fromJson != null ? fromJson(data) : data as T?,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse<T>(
        success: true,
        data: fromJson != null ? fromJson(data) : data as T?,
        statusCode: response.statusCode,
      );
    }
    throw ResponseHandler.handleError(
      statusCode: response.statusCode,
      responseData: response.data,
    );
  }

  /// Handle Dio errors via [ResponseHandler].
  AppException _handleDioError(DioException error) {
    return ResponseHandler.handleDioError(error);
  }
}
