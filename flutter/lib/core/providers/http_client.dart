import 'package:dio/dio.dart';

import 'provider_fetch_strategy.dart';

/// Thin HTTP helper used by provider fetch strategies.
///
/// Wraps [Dio] with the common retry/timeout behavior and maps response errors
/// to [ProviderFetchError] subtypes. This stands in for the Swift
/// `ProviderHTTPClient` / `ProviderHTTPRetryPolicy.transientIdempotent`.
class ProviderHttpClient {
  ProviderHttpClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: {'Accept': 'application/json'},
                responseType: ResponseType.json,
              ),
            );

  final Dio _dio;

  /// GET [path] under [baseURL] with [headers], returning the decoded JSON
  /// body. Query parameters accept the same shapes Dio expects.
  Future<Map<String, dynamic>> getJson(
    String baseURL,
    String path, {
    Map<String, String?> query = const {},
    Map<String, String> headers = const {},
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        baseURL + path,
        queryParameters: Map.of(query)..removeWhere((_, v) => v == null),
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError('Empty response body');
      }
      return data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ProviderFetchError _mapDioError(DioException e) {
    final code = e.response?.statusCode;
    final rawBody = e.response?.data;
    // Dio decodes JSON error bodies; extract the structured message if present.
    final body = _extractErrorMessage(rawBody) ?? rawBody?.toString() ?? '';
    if (code == 401) return UnauthorizedError(body.isEmpty ? 'HTTP 401 Unauthorized' : body);
    if (code == 403) return ForbiddenError(body.isEmpty ? 'HTTP 403 Forbidden' : body);
    if (code != null) {
      return ApiError('HTTP $code${body.isEmpty ? '' : ': $body'}');
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError('Timeout: ${e.message}');
      case DioExceptionType.connectionError:
        return NetworkError('Connection error: ${e.message}');
      default:
        return NetworkError(e.message ?? 'Network error');
    }
  }

  /// Pull a human-readable message out of a provider's JSON error body.
  ///
  /// Most providers nest the message under `error.message`; OpenAI also lists
  /// missing scopes there. Returns `null` if no usable message is found.
  String? _extractErrorMessage(Object? body) {
    if (body is! Map) return null;
    final error = body['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) {
        // Surface missing scopes when present (OpenAI includes them).
        final scopes = error['missing_scopes'];
        if (scopes is List && scopes.isNotEmpty) {
          return '$message (Missing scopes: ${scopes.join(', ')})';
        }
        return message;
      }
    }
    final message = body['message'];
    if (message is String && message.isNotEmpty) return message;
    return null;
  }
}
