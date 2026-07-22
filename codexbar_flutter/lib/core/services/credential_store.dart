import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialStore {
  static final CredentialStore _instance = CredentialStore._();
  factory CredentialStore() => _instance;
  CredentialStore._();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // API Keys
  String? getApiKey(String provider) => _prefs.getString('api_key_$provider');
  Future<void> setApiKey(String provider, String key) =>
      _prefs.setString('api_key_$provider', key);
  Future<void> clearApiKey(String provider) =>
      _prefs.remove('api_key_$provider');

  // OAuth Tokens
  String? getOAuthToken(String provider) => _prefs.getString('oauth_token_$provider');
  Future<void> setOAuthToken(String provider, String token) =>
      _prefs.setString('oauth_token_$provider', token);
  Future<void> clearOAuthToken(String provider) =>
      _prefs.remove('oauth_token_$provider');

  // Cookie Headers
  String? getCookieHeader(String provider) => _prefs.getString('cookies_$provider');
  Future<void> setCookieHeader(String provider, String cookies) =>
      _prefs.setString('cookies_$provider', cookies);
  Future<void> clearCookieHeader(String provider) =>
      _prefs.remove('cookies_$provider');

  // Claude OAuth credentials from file
  Future<String?> readClaudeOAuthToken() async {
    try {
      final home = Platform.environment['HOME'] ?? '';
      final credFile = File('$home/.claude/.credentials.json');
      if (await credFile.exists()) {
        final content = await credFile.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        return data['access_token'] as String?;
      }
    } catch (e) {
      // File not found
    }
    return null;
  }

  // Codex OAuth credentials from file
  Future<String?> readCodexOAuthToken() async {
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
      // File not found
    }
    return null;
  }

  // Gemini OAuth credentials from file
  Future<Map<String, dynamic>?> readGeminiCredentials() async {
    try {
      final home = Platform.environment['HOME'] ?? '';
      final credFile = File('$home/.gemini/oauth_creds.json');
      if (await credFile.exists()) {
        final content = await credFile.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // File not found
    }
    return null;
  }

  // Environment variable fallbacks
  String? getEnvApiKey(String provider) {
    switch (provider) {
      case 'claude':
        return Platform.environment['ANTHROPIC_API_KEY'] ??
            Platform.environment['ANTHROPIC_ADMIN_KEY'];
      case 'openai':
        return Platform.environment['OPENAI_API_KEY'] ??
            Platform.environment['OPENAI_ADMIN_KEY'];
      case 'gemini':
        return Platform.environment['GEMINI_API_KEY'];
      default:
        return null;
    }
  }
}
