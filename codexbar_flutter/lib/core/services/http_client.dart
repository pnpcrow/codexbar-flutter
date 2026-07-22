import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._();
  factory HttpClient() => _instance;
  HttpClient._();

  late final Dio _dio;
  final CookieJar _cookieJar = CookieJar();

  void initialize() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'CodexBar/0.1.0 (Linux)',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  Future<Response<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _dio.get<T>(
      url,
      options: Options(headers: headers),
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    String? contentType,
  }) {
    return _dio.post<T>(
      url,
      data: data,
      options: Options(
        headers: headers,
        contentType: contentType,
      ),
    );
  }
}

class ClaudeHttpClient {
  static Future<Map<String, dynamic>?> fetchUsage({
    String? oauthToken,
    String? sessionCookie,
    String? adminApiKey,
  }) async {
    final client = HttpClient();

    // Try OAuth first
    if (oauthToken != null) {
      try {
        final response = await client.get(
          'https://api.anthropic.com/api/oauth/usage',
          headers: {
            'Authorization': 'Bearer $oauthToken',
            'anthropic-beta': 'oauth-2025-04-20',
            'User-Agent': 'claude-code/2.1.0',
          },
        );
        if (response.statusCode == 200) {
          return response.data as Map<String, dynamic>;
        }
      } catch (e) {
        // Fall through to next method
      }
    }

    // Try web session
    if (sessionCookie != null) {
      try {
        // First get organization ID
        final orgResponse = await client.get(
          'https://claude.ai/api/organizations',
          headers: {'Cookie': 'sessionKey=$sessionCookie'},
        );
        if (orgResponse.statusCode == 200) {
          final orgs = orgResponse.data as List;
          if (orgs.isNotEmpty) {
            final orgId = orgs[0]['uuid'];
            final usageResponse = await client.get(
              'https://claude.ai/api/organizations/$orgId/usage',
              headers: {'Cookie': 'sessionKey=$sessionCookie'},
            );
            if (usageResponse.statusCode == 200) {
              return usageResponse.data as Map<String, dynamic>;
            }
          }
        }
      } catch (e) {
        // Fall through
      }
    }

    // Try Admin API
    if (adminApiKey != null) {
      try {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final response = await client.get(
          'https://api.anthropic.com/v1/organization/cost_report',
          headers: {
            'x-api-key': adminApiKey,
            'anthropic-version': '2023-06-01',
          },
          queryParameters: {
            'starting_at': startOfMonth.toUtc().toIso8601String(),
            'ending_at': now.toUtc().toIso8601String(),
            'bucket_width': '1d',
            'limit': '31',
          },
        );
        if (response.statusCode == 200) {
          return response.data as Map<String, dynamic>;
        }
      } catch (e) {
        // Fall through
      }
    }

    return null;
  }

  static Future<Map<String, dynamic>?> fetchFromCLI() async {
    try {
      final result = await Process.run('claude', ['usage', '--json']);
      if (result.exitCode == 0) {
        return json.decode(result.stdout as String) as Map<String, dynamic>;
      }
    } catch (e) {
      // CLI not available
    }
    return null;
  }
}

class CodexHttpClient {
  static Future<Map<String, dynamic>?> fetchUsage({
    String? accessToken,
    String? apiKey,
  }) async {
    final client = HttpClient();

    // Try OAuth token
    if (accessToken != null) {
      try {
        final response = await client.get(
          'https://chatgpt.com/backend-api/wham/usage',
          headers: {
            'Authorization': 'Bearer $accessToken',
            'OpenAI-Beta': 'codex-1',
          },
        );
        if (response.statusCode == 200) {
          return response.data as Map<String, dynamic>;
        }
      } catch (e) {
        // Fall through
      }
    }

    // Try API key
    if (apiKey != null) {
      try {
        final response = await client.get(
          'https://api.openai.com/v1/dashboard/billing/credit_grants',
          headers: {'Authorization': 'Bearer $apiKey'},
        );
        if (response.statusCode == 200) {
          return response.data as Map<String, dynamic>;
        }
      } catch (e) {
        // Fall through
      }
    }

    return null;
  }

  static Future<String?> readOAuthToken() async {
    try {
      final home = Platform.environment['HOME'] ?? '';
      final authFile = File('$home/.codex/auth.json');
      if (await authFile.exists()) {
        final content = await authFile.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>?;
        return tokens?['access_token'] as String?;
      }
    } catch (e) {
      // File not found or parse error
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchFromCLI() async {
    try {
      final result = await Process.run('codex', ['usage', '--json']);
      if (result.exitCode == 0) {
        return json.decode(result.stdout as String) as Map<String, dynamic>;
      }
    } catch (e) {
      // CLI not available
    }
    return null;
  }
}

class CursorHttpClient {
  static Future<Map<String, dynamic>?> fetchUsage({
    required Map<String, String> cookies,
  }) async {
    if (cookies.isEmpty) return null;

    final client = HttpClient();
    try {
      final cookieStr = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      final response = await client.get(
        'https://cursor.com/api/usage-summary',
        headers: {'Cookie': cookieStr},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      // API failed
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchUserInfo({
    required Map<String, String> cookies,
  }) async {
    if (cookies.isEmpty) return null;

    final client = HttpClient();
    try {
      final cookieStr = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      final response = await client.get(
        'https://cursor.com/api/auth/me',
        headers: {'Cookie': cookieStr},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      // API failed
    }
    return null;
  }
}

class GeminiHttpClient {
  static Future<Map<String, dynamic>?> fetchUsage() async {
    try {
      final home = Platform.environment['HOME'] ?? '';
      final credsFile = File('$home/.gemini/oauth_creds.json');
      if (!await credsFile.exists()) return null;

      final content = await credsFile.readAsString();
      final creds = json.decode(content) as Map<String, dynamic>;
      var accessToken = creds['access_token'] as String?;

      // Check if token is expired and refresh if needed
      final expiryDate = creds['expiry_date'] as int?;
      if (expiryDate != null && expiryDate < DateTime.now().millisecondsSinceEpoch) {
        accessToken = await _refreshToken(creds['refresh_token'] as String?);
        if (accessToken == null) return null;
      }

      if (accessToken == null) return null;

      final client = HttpClient();

      // Load code assist status
      final statusResponse = await client.post(
        'https://cloudcode-pa.googleapis.com/v1internal:loadCodeAssist',
        data: json.encode({
          'metadata': {'ideType': 'GEMINI_CLI', 'pluginType': 'GEMINI'}
        }),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      String? projectId;
      if (statusResponse.statusCode == 200) {
        final statusData = statusResponse.data as Map<String, dynamic>;
        projectId = statusData['cloudaicompanionProject'] as String?;
      }

      // Retrieve user quota
      final quotaResponse = await client.post(
        'https://cloudcode-pa.googleapis.com/v1internal:retrieveUserQuota',
        data: json.encode({'project': projectId ?? ''}),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (quotaResponse.statusCode == 200) {
        return quotaResponse.data as Map<String, dynamic>;
      }
    } catch (e) {
      // Failed
    }
    return null;
  }

  static Future<String?> _refreshToken(String? refreshToken) async {
    if (refreshToken == null) return null;

    try {
      final client = HttpClient();
      final response = await client.post(
        'https://oauth2.googleapis.com/token',
        data: 'grant_type=refresh_token&refresh_token=$refreshToken',
        contentType: 'application/x-www-form-urlencoded',
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['access_token'] as String?;
      }
    } catch (e) {
      // Refresh failed
    }
    return null;
  }
}

class OpenAIHttpClient {
  static Future<Map<String, dynamic>?> fetchUsage({
    required String apiKey,
  }) async {
    final client = HttpClient();

    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30));

      final response = await client.get(
        'https://api.openai.com/v1/organization/costs',
        headers: {'Authorization': 'Bearer $apiKey'},
        queryParameters: {
          'start_time': '${startTime.millisecondsSinceEpoch ~/ 1000}',
          'end_time': '${now.millisecondsSinceEpoch ~/ 1000}',
          'bucket_width': '1d',
          'limit': '31',
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      // API failed
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchCredits({
    required String apiKey,
  }) async {
    final client = HttpClient();

    try {
      final response = await client.get(
        'https://api.openai.com/v1/dashboard/billing/credit_grants',
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      // API failed
    }
    return null;
  }
}
