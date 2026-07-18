import 'package:flutter/foundation.dart';

/// Debug-only logger for CodexBar.
/// All output is suppressed in release mode for security.
class DebugLogger {
  static bool _enabled = kDebugMode;

  /// Enable or disable debug logging.
  static void setEnabled(bool enabled) {
    _enabled = enabled && kDebugMode;
  }

  /// Log a message (debug mode only).
  static void log(String tag, String message) {
    if (!_enabled) return;
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    debugPrint('[$timestamp] [$tag] $message');
  }

  /// Log an error (debug mode only).
  static void error(String tag, String message, [Object? error]) {
    if (!_enabled) return;
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    debugPrint('[$timestamp] [$tag] ERROR: $message${error != null ? ' ($error)' : ''}');
  }

  /// Log cookie resolution (debug mode only, masks sensitive values).
  static void cookie(String tag, String domain, String? cookieHeader, String source) {
    if (!_enabled) return;
    if (cookieHeader == null || cookieHeader.isEmpty) {
      log(tag, 'No cookies for $domain');
      return;
    }
    final pairs = cookieHeader.split(';').map((p) => p.trim()).where((p) => p.isNotEmpty);
    final names = pairs.map((p) => p.split('=').first).toList();
    log(tag, 'Cookies for $domain from $source: ${names.join(', ')}');
  }

  /// Log API request (debug mode only, masks auth headers).
  static void request(String tag, String method, String url, {Map<String, String>? headers}) {
    if (!_enabled) return;
    log(tag, '$method $url');
    if (headers != null) {
      for (final entry in headers.entries) {
        if (entry.key.toLowerCase() == 'cookie') {
          final names = entry.value.split(';').map((p) => p.trim().split('=').first).toList();
          log(tag, '  Cookie: [${names.join(', ')}]');
        } else if (entry.key.toLowerCase().contains('auth')) {
          log(tag, '  ${entry.key}: [REDACTED]');
        } else {
          log(tag, '  ${entry.key}: ${entry.value}');
        }
      }
    }
  }

  /// Log API response (debug mode only).
  static void response(String tag, String url, int statusCode, String body, {int maxLength = 200}) {
    if (!_enabled) return;
    log(tag, 'Response $statusCode from $url');
    if (body.length > maxLength) {
      log(tag, '  Body (${body.length} chars): ${body.substring(0, maxLength)}...');
    } else {
      log(tag, '  Body: $body');
    }
  }

  /// Log fetch strategy resolution (debug mode only).
  static void strategy(String tag, String provider, List<String> availableStrategies) {
    if (!_enabled) return;
    log(tag, '$provider strategies: ${availableStrategies.join(' > ')}');
  }
}
