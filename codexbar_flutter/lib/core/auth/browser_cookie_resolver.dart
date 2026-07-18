import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../models/usage_provider.dart';

final _log = Logger('BrowserCookieResolver');

enum Browser {
  safari, chrome, chromeBeta, chromeCanary, firefox, edge, dia, arc, brave, vivaldi;
  String get displayName => name;
}

typedef BrowserCookieImportOrder = List<Browser>;

class CookieResolution {
  final String cookieHeader;
  final Browser browser;
  const CookieResolution({required this.cookieHeader, required this.browser});
}

/// Resolves browser cookies by checking installed browsers sequentially.
///
/// Strategy:
/// 1. Check for manually configured cookies (env var)
/// 2. Try Chrome cookie decryption via Python helper script
/// 3. Try reading cookies from Firefox SQLite database (plaintext)
class BrowserCookieResolver {
  static final BrowserCookieResolver _instance = BrowserCookieResolver._();
  factory BrowserCookieResolver() => _instance;
  BrowserCookieResolver._();

  static const defaultImportOrder = [Browser.chrome, Browser.firefox, Browser.edge, Browser.brave];

  static BrowserCookieImportOrder importOrderFor(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.cursor: return [Browser.safari, Browser.chrome, Browser.firefox];
      case UsageProvider.codex: return [Browser.safari, Browser.chrome, Browser.firefox];
      case UsageProvider.mimo: return [Browser.chrome, Browser.firefox, Browser.edge];
      case UsageProvider.grok: return [Browser.chrome];
      case UsageProvider.devin: return [Browser.chrome];
      case UsageProvider.copilot: return [Browser.chrome];
      case UsageProvider.qoder: return [Browser.chrome];
      default: return defaultImportOrder;
    }
  }

  /// Provider → domain mapping for cookie lookup.
  static String domainFor(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude: return 'claude.ai';
      case UsageProvider.openai: return 'openai.com';
      case UsageProvider.cursor: return 'cursor.com';
      case UsageProvider.mimo: return 'xiaomimimo.com';
      case UsageProvider.minimax: return 'minimax.io';
      case UsageProvider.zai: return 'z.ai';
      case UsageProvider.grok: return 'grok.com';
      case UsageProvider.devin: return 'devin.ai';
      case UsageProvider.copilot: return 'github.com';
      case UsageProvider.manus: return 'manus.im';
      case UsageProvider.mistral: return 'mistral.ai';
      case UsageProvider.perplexity: return 'perplexity.ai';
      case UsageProvider.windsurf: return 'windsurf.com';
      case UsageProvider.factory: return 'factory.ai';
      case UsageProvider.qoder: return 'qoder.ai';
      case UsageProvider.kiro: return 'kiro.dev';
      case UsageProvider.gemini: return 'google.com';
      case UsageProvider.doubao: return 'doubao.com';
      case UsageProvider.poe: return 'poe.com';
      default: return '${provider.name}.com';
    }
  }

  /// Key cookie names per provider (essential session/auth cookies).
  static List<String> keyCookieNames(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.mimo: return ['serviceToken', 'userId'];
      case UsageProvider.minimax: return ['_token'];
      case UsageProvider.zai: return ['token'];
      case UsageProvider.claude: return ['sessionKey', '__cf_bm'];
      case UsageProvider.openai: return ['oai-sc', '__cf_bm', 'cf_clearance'];
      case UsageProvider.cursor: return ['__cf_bm'];
      case UsageProvider.copilot: return ['user_session', '__cf_bm'];
      case UsageProvider.manus: return ['__cf_bm'];
      case UsageProvider.mistral: return ['__cf_bm'];
      case UsageProvider.perplexity: return ['__cf_bm'];
      case UsageProvider.poe: return ['__cf_bm'];
      case UsageProvider.grok: return ['__cf_bm'];
      case UsageProvider.devin: return ['__cf_bm'];
      default: return ['__cf_bm', 'token', 'session'];
    }
  }

  /// Check if any installed browser likely has cookies for this provider.
  Future<bool> hasPlausibleSession(UsageProvider provider) async {
    final order = importOrderFor(provider);
    for (final browser in order) {
      if (!_isBrowserInstalled(browser)) continue;
      if (browser == Browser.chrome) {
        // Check via Python script
        final result = await _runPythonDecryptor(domainFor(provider), ['__cf_bm']);
        if (result.isNotEmpty) return true;
      }
    }
    return false;
  }

  /// Extract cookies for a provider from installed browsers (sequential check).
  Future<CookieResolution?> resolve(UsageProvider provider) async {
    final domain = domainFor(provider);
    final keyNames = keyCookieNames(provider);
    final order = importOrderFor(provider);

    for (final browser in order) {
      if (!_isBrowserInstalled(browser)) continue;

      try {
        String? cookies;

        if (browser == Browser.chrome || browser == Browser.edge || browser == Browser.brave) {
          // Use Python helper for Chrome-based browsers (AES-128-CBC with v24 support)
          cookies = await _decryptChromeCookies(domain, keyNames);
        } else if (browser == Browser.firefox) {
          // Firefox stores cookies in plaintext
          cookies = await _readFirefoxCookies(domain);
        }

        if (cookies != null && cookies.isNotEmpty) {
          _log.info('Got cookies for ${provider.displayName} from ${browser.displayName}');
          return CookieResolution(cookieHeader: cookies, browser: browser);
        }
      } catch (e) {
        _log.fine('Failed to read cookies from ${browser.displayName}: $e');
      }
    }
    return null;
  }

  /// Decrypt Chrome cookies using the Python helper script.
  Future<String?> _decryptChromeCookies(String domain, List<String> keyNames) async {
    final result = await _runPythonDecryptor(domain, keyNames);
    if (result.isEmpty) return null;
    return result.join('; ');
  }

  /// Run the Python cookie decryptor script.
  Future<List<String>> _runPythonDecryptor(String domain, List<String> cookieNames) async {
    try {
      // Find the helper script
      final scriptPath = _findHelperScript();
      if (scriptPath == null) {
        _log.warning('Chrome cookie decryptor script not found');
        return [];
      }

      final result = await Process.run('python3', [
        scriptPath,
        domain,
        cookieNames.join(','),
      ]).timeout(const Duration(seconds: 10));

      if (result.exitCode != 0) {
        _log.fine('Python decryptor failed: ${result.stderr}');
        return [];
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) return [];

      return output.split('\n').where((line) => line.contains('=')).toList();
    } catch (e) {
      _log.fine('Failed to run Python decryptor: $e');
      return [];
    }
  }

  /// Find the Python helper script relative to the app.
  String? _findHelperScript() {
    // Try multiple locations
    final candidates = [
      // Relative to executable
      p.join(p.dirname(Platform.resolvedExecutable), '..', '..', 'scripts', 'chrome_cookie_decryptor.py'),
      p.join(p.dirname(Platform.resolvedExecutable), 'scripts', 'chrome_cookie_decryptor.py'),
      // Project source location
      p.join(Directory.current.path, 'scripts', 'chrome_cookie_decryptor.py'),
      p.join(Directory.current.path, 'codexbar_flutter', 'scripts', 'chrome_cookie_decryptor.py'),
      // Absolute path (development)
      '/home/elektro/Workspaces/Repositories/codexbar-flutter-mimo/codexbar_flutter/scripts/chrome_cookie_decryptor.py',
    ];

    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }
    return null;
  }

  /// Read Firefox cookies (plaintext in SQLite).
  Future<String?> _readFirefoxCookies(String domain) async {
    final home = Platform.environment['HOME'] ?? '';
    final profileDir = Directory('$home/.mozilla/firefox');
    if (!profileDir.existsSync()) return null;

    // Find default profile
    String? cookiesDb;
    for (final entity in profileDir.listSync()) {
      if (entity is Directory &&
          (entity.path.endsWith('.default') || entity.path.endsWith('.default-release'))) {
        final path = '${entity.path}/cookies.sqlite';
        if (File(path).existsSync()) {
          cookiesDb = path;
          break;
        }
      }
    }
    if (cookiesDb == null) return null;

    // Copy and read
    final tmpDir = Directory.systemTemp;
    final tmpDb = '${tmpDir.path}/codexbar_ff_cookies_${DateTime.now().microsecondsSinceEpoch}.db';
    File(cookiesDb).copySync(tmpDb);

    try {
      final result = await Process.run('sqlite3', [
        tmpDb,
        "SELECT name, value FROM moz_cookies WHERE host LIKE '%$domain%'",
      ]);

      if (result.exitCode != 0) return null;

      final lines = result.stdout.toString().trim().split('\n').where((l) => l.isNotEmpty);
      final pairs = <String>[];
      for (final line in lines) {
        final parts = line.split('|');
        if (parts.length >= 2) {
          pairs.add('${parts[0]}=${parts[1]}');
        }
      }
      return pairs.isNotEmpty ? pairs.join('; ') : null;
    } finally {
      try { File(tmpDb).deleteSync(); } catch (_) {}
    }
  }

  bool _isBrowserInstalled(Browser browser) {
    final home = Platform.environment['HOME'] ?? '';
    if (Platform.isLinux) {
      switch (browser) {
        case Browser.chrome:
          return Directory('$home/.config/google-chrome').existsSync();
        case Browser.firefox:
          return Directory('$home/.mozilla/firefox').existsSync();
        case Browser.edge:
          return Directory('$home/.config/microsoft-edge').existsSync();
        case Browser.brave:
          return Directory('$home/.config/BraveSoftware').existsSync();
        default:
          return false;
      }
    } else if (Platform.isMacOS) {
      switch (browser) {
        case Browser.safari:
          return Directory('/Applications/Safari.app').existsSync();
        case Browser.chrome:
          return Directory('/Applications/Google Chrome.app').existsSync();
        case Browser.firefox:
          return Directory('/Applications/Firefox.app').existsSync();
        case Browser.edge:
          return Directory('/Applications/Microsoft Edge.app').existsSync();
        case Browser.brave:
          return Directory('/Applications/Brave Browser.app').existsSync();
        default:
          return false;
      }
    }
    return false;
  }
}
