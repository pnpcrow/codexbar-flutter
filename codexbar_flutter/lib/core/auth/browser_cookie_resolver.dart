import 'dart:io';

import 'package:path/path.dart' as p;

import '../debug/debug_logger.dart';
import '../models/usage_provider.dart';

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
      case UsageProvider.mimo: return ['api-platform_serviceToken', 'serviceToken', 'userId'];
      case UsageProvider.minimax: return ['_token', 'HERTZ-SESSION'];
      case UsageProvider.zai: return ['token'];
      case UsageProvider.claude: return ['sessionKey', '__cf_bm'];
      case UsageProvider.openai: return ['oai-sc', '__cf_bm', 'cf_clearance'];
      case UsageProvider.cursor: return ['__cf_bm'];
      case UsageProvider.copilot: return ['user_session', '__cf_bm'];
      case UsageProvider.manus: return ['__cf_bm'];
      case UsageProvider.mistral: return ['__cf_bm'];
      case UsageProvider.perplexity: return ['__cf_bm'];
      case UsageProvider.poe: return ['__cf_bm'];
      case UsageProvider.grok: return ['sso', 'sso-rw', 'cf_clearance', '__cf_bm', 'x-userid'];
      case UsageProvider.devin: return ['__cf_bm'];
      default: return ['__cf_bm', 'token', 'session'];
    }
  }

  /// Check if any installed browser likely has cookies for this provider.
  Future<bool> hasPlausibleSession(UsageProvider provider) async {
    final order = importOrderFor(provider);
    DebugLogger.log('CookieResolver', 'Checking plausible session for ${provider.displayName}, browsers: ${order.map((b) => b.displayName).join(', ')}');

    for (final browser in order) {
      if (!_isBrowserInstalled(browser)) {
        DebugLogger.log('CookieResolver', '  ${browser.displayName}: not installed');
        continue;
      }
      DebugLogger.log('CookieResolver', '  ${browser.displayName}: installed');

      if (browser == Browser.chrome) {
        final result = await _runPythonDecryptor(domainFor(provider), ['__cf_bm']);
        if (result.isNotEmpty) {
          DebugLogger.log('CookieResolver', '  ${browser.displayName}: has cookies');
          return true;
        }
      }
    }
    DebugLogger.log('CookieResolver', 'No plausible session found');
    return false;
  }

  /// Extract cookies for a provider from installed browsers (sequential check).
  Future<CookieResolution?> resolve(UsageProvider provider) async {
    final domain = domainFor(provider);
    final keyNames = keyCookieNames(provider);
    final order = importOrderFor(provider);

    DebugLogger.log('CookieResolver', 'Resolving cookies for ${provider.displayName} (domain: $domain)');
    DebugLogger.log('CookieResolver', 'Key cookie names: ${keyNames.join(', ')}');

    for (final browser in order) {
      if (!_isBrowserInstalled(browser)) {
        DebugLogger.log('CookieResolver', '  ${browser.displayName}: not installed, skipping');
        continue;
      }

      DebugLogger.log('CookieResolver', '  Trying ${browser.displayName}...');
      try {
        String? cookies;

        if (browser == Browser.chrome || browser == Browser.edge || browser == Browser.brave) {
          DebugLogger.log('CookieResolver', '    Using Python decryptor for Chrome-based browser');
          cookies = await _decryptChromeCookies(domain, keyNames);
        } else if (browser == Browser.firefox) {
          DebugLogger.log('CookieResolver', '    Reading Firefox cookies (plaintext)');
          cookies = await _readFirefoxCookies(domain);
        }

        if (cookies != null && cookies.isNotEmpty) {
          DebugLogger.cookie('CookieResolver', domain, cookies, browser.displayName);
          return CookieResolution(cookieHeader: cookies, browser: browser);
        } else {
          DebugLogger.log('CookieResolver', '    No cookies found from ${browser.displayName}');
        }
      } catch (e) {
        DebugLogger.error('CookieResolver', 'Failed to read cookies from ${browser.displayName}', e);
      }
    }

    DebugLogger.error('CookieResolver', 'No cookies found for ${provider.displayName} from any browser');
    return null;
  }

  /// Decrypt Chrome cookies using the Python helper script.
  Future<String?> _decryptChromeCookies(String domain, List<String> keyNames) async {
    final result = await _runPythonDecryptor(domain, keyNames);
    if (result.isEmpty) {
      DebugLogger.log('CookieResolver', '    Python decryptor returned empty result');
      return null;
    }
    DebugLogger.log('CookieResolver', '    Python decryptor returned ${result.length} cookies');
    return result.join('; ');
  }

  /// Run the Python cookie decryptor script.
  Future<List<String>> _runPythonDecryptor(String domain, List<String> cookieNames) async {
    try {
      final scriptPath = _findHelperScript();
      if (scriptPath == null) {
        DebugLogger.error('CookieResolver', 'Chrome cookie decryptor script not found');
        return [];
      }

      DebugLogger.log('CookieResolver', '    Script path: $scriptPath');
      DebugLogger.log('CookieResolver', '    Args: $domain ${cookieNames.join(',')}');

      final result = await Process.run('python3', [
        scriptPath,
        domain,
        cookieNames.join(','),
      ]).timeout(const Duration(seconds: 10));

      DebugLogger.log('CookieResolver', '    Exit code: ${result.exitCode}');

      if (result.exitCode != 0) {
        DebugLogger.error('CookieResolver', 'Python decryptor failed', result.stderr);
        return [];
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) {
        DebugLogger.log('CookieResolver', '    Python decryptor output is empty');
        return [];
      }

      final lines = output.split('\n').where((line) => line.contains('=')).toList();
      DebugLogger.log('CookieResolver', '    Parsed ${lines.length} cookie lines');
      for (final line in lines) {
        final name = line.split('=').first;
        DebugLogger.log('CookieResolver', '      Cookie: $name');
      }
      return lines;
    } catch (e) {
      DebugLogger.error('CookieResolver', 'Failed to run Python decryptor', e);
      return [];
    }
  }

  /// Find the Python helper script relative to the app.
  String? _findHelperScript() {
    final candidates = [
      p.join(p.dirname(Platform.resolvedExecutable), 'scripts', 'chrome_cookie_decryptor.py'),
      p.join(p.dirname(Platform.resolvedExecutable), '..', '..', 'scripts', 'chrome_cookie_decryptor.py'),
      p.join(Directory.current.path, 'scripts', 'chrome_cookie_decryptor.py'),
      p.join(Directory.current.path, 'codexbar_flutter', 'scripts', 'chrome_cookie_decryptor.py'),
      '/home/elektro/Workspaces/Repositories/codexbar-flutter-mimo/codexbar_flutter/scripts/chrome_cookie_decryptor.py',
    ];

    for (final path in candidates) {
      if (File(path).existsSync()) {
        DebugLogger.log('CookieResolver', '    Found script at: $path');
        return path;
      }
    }
    DebugLogger.error('CookieResolver', 'Script not found in any candidate path');
    return null;
  }

  /// Read Firefox cookies (plaintext in SQLite).
  Future<String?> _readFirefoxCookies(String domain) async {
    final home = Platform.environment['HOME'] ?? '';
    final profileDir = Directory('$home/.mozilla/firefox');
    if (!profileDir.existsSync()) {
      DebugLogger.log('CookieResolver', '    Firefox profile directory not found');
      return null;
    }

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
    if (cookiesDb == null) {
      DebugLogger.log('CookieResolver', '    Firefox cookies.sqlite not found');
      return null;
    }

    DebugLogger.log('CookieResolver', '    Found Firefox cookies at: $cookiesDb');

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
      DebugLogger.log('CookieResolver', '    Found ${pairs.length} Firefox cookies');
      return pairs.isNotEmpty ? pairs.join('; ') : null;
    } finally {
      try { File(tmpDb).deleteSync(); } catch (_) {}
    }
  }

  bool _isBrowserInstalled(Browser browser) {
    final home = Platform.environment['HOME'] ?? '';
    bool installed;
    if (Platform.isLinux) {
      switch (browser) {
        case Browser.chrome:
          installed = Directory('$home/.config/google-chrome').existsSync();
        case Browser.firefox:
          installed = Directory('$home/.mozilla/firefox').existsSync();
        case Browser.edge:
          installed = Directory('$home/.config/microsoft-edge').existsSync();
        case Browser.brave:
          installed = Directory('$home/.config/BraveSoftware').existsSync();
        default:
          installed = false;
      }
    } else if (Platform.isMacOS) {
      switch (browser) {
        case Browser.safari:
          installed = Directory('/Applications/Safari.app').existsSync();
        case Browser.chrome:
          installed = Directory('/Applications/Google Chrome.app').existsSync();
        case Browser.firefox:
          installed = Directory('/Applications/Firefox.app').existsSync();
        case Browser.edge:
          installed = Directory('/Applications/Microsoft Edge.app').existsSync();
        case Browser.brave:
          installed = Directory('/Applications/Brave Browser.app').existsSync();
        default:
          installed = false;
      }
    } else {
      installed = false;
    }
    return installed;
  }
}
