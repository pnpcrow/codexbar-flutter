import 'dart:io';

import 'package:logging/logging.dart';
import 'package:sqlite3/sqlite3.dart';

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
/// 1. Check for manually configured cookies (env var or SharedPreferences)
/// 2. Try reading cookies from browser SQLite databases (Firefox=plaintext, Chrome=encrypted)
/// 3. Try Chrome CDP if Chrome is running with remote debugging
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
      case UsageProvider.claude: return '.claude.ai';
      case UsageProvider.openai: return '.chatgpt.com';
      case UsageProvider.cursor: return '.cursor.com';
      case UsageProvider.mimo: return '.xiaomimimo.com';
      case UsageProvider.minimax: return '.minimax.io';
      case UsageProvider.zai: return '.z.ai';
      case UsageProvider.grok: return '.grok.com';
      case UsageProvider.devin: return '.devin.ai';
      case UsageProvider.copilot: return '.github.com';
      case UsageProvider.manus: return '.manus.im';
      case UsageProvider.mistral: return '.mistral.ai';
      case UsageProvider.perplexity: return '.perplexity.ai';
      case UsageProvider.windsurf: return '.windsurf.com';
      case UsageProvider.factory: return '.factory.ai';
      case UsageProvider.qoder: return '.qoder.ai';
      case UsageProvider.kiro: return '.kiro.dev';
      case UsageProvider.gemini: return '.google.com';
      case UsageProvider.doubao: return '.doubao.com';
      case UsageProvider.poe: return '.poe.com';
      default: return '.${provider.name}.com';
    }
  }

  /// Check if any installed browser likely has cookies for this provider.
  Future<bool> hasPlausibleSession(UsageProvider provider) async {
    final order = importOrderFor(provider);
    for (final browser in order) {
      if (!_isBrowserInstalled(browser)) continue;
      final dbPath = _cookieDbPath(browser);
      if (dbPath == null || !File(dbPath).existsSync()) continue;
      try {
        final db = _openDbCopy(dbPath);
        final domain = domainFor(provider);
        final domainCore = domain.replaceAll('.', '');
        final result = db.select(
          'SELECT COUNT(*) as cnt FROM cookies WHERE host_key LIKE ?',
          ['%$domainCore%'],
        );
        final count = result.isNotEmpty ? (result.first['cnt'] as int) : 0;
        db.dispose();
        if (count > 0) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Extract cookies for a provider from installed browsers (sequential check).
  Future<CookieResolution?> resolve(UsageProvider provider) async {
    final order = importOrderFor(provider);
    for (final browser in order) {
      if (!_isBrowserInstalled(browser)) continue;
      final dbPath = _cookieDbPath(browser);
      if (dbPath == null || !File(dbPath).existsSync()) continue;

      try {
        final cookies = _readCookies(dbPath, provider, browser);
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

  /// Read cookies from a browser's SQLite database.
  String? _readCookies(String dbPath, UsageProvider provider, Browser browser) {
    final db = _openDbCopy(dbPath);
    try {
      final domain = domainFor(provider);
      final domainCore = domain.replaceAll('.', '');

      final rows = db.select(
        'SELECT name, value, host_key FROM cookies WHERE host_key LIKE ?',
        ['%$domainCore%'],
      );

      if (rows.isEmpty) return null;

      final cookiePairs = <String>[];
      for (final row in rows) {
        final name = row['name'] as String;
        final value = row['value'] as String;
        final hostKey = row['host_key'] as String;

        // Only include cookies with plaintext values
        // (encrypted cookies show up as empty value)
        if (value.isNotEmpty) {
          cookiePairs.add('$name=$value');
        }
      }

      if (cookiePairs.isEmpty) {
        // All cookies are encrypted - try CDP if Chrome
        if (browser == Browser.chrome) {
          return _readCookiesViaCDP(domain);
        }
        return null;
      }

      return cookiePairs.join('; ');
    } finally {
      db.dispose();
    }
  }

  /// Try to read cookies from Chrome via CDP (Chrome DevTools Protocol).
  /// Requires Chrome to be running with --remote-debugging-port=9222.
  String? _readCookiesViaCDP(String domain) {
    try {
      // Check if Chrome CDP is available
      final result = Process.runSync('curl', [
        '-s', '--max-time', '2',
        'http://localhost:9222/json/version',
      ]);
      if (result.exitCode != 0) return null;

      // Get cookies via CDP
      final cookieResult = Process.runSync('curl', [
        '-s', '--max-time', '5',
        '-X', 'POST',
        '-H', 'Content-Type: application/json',
        '-d', '{"id":1,"method":"Network.getCookies","params":{"urls":["https://${domain}"]}}',
        'http://localhost:9222/json/protocol',
      ]);

      if (cookieResult.exitCode == 0) {
        final body = cookieResult.stdout.toString();
        // Parse cookies from CDP response
        // This is a simplified parser - real implementation would use jsonDecode
        if (body.contains('"cookies"')) {
          _log.info('CDP cookies available for $domain');
          // TODO: Parse CDP response properly
        }
      }
    } catch (_) {}
    return null;
  }

  /// Open a copy of the SQLite database (Chrome locks the original).
  Database _openDbCopy(String dbPath) {
    final tmpDir = Directory.systemTemp;
    final tmpDb = '${tmpDir.path}/codexbar_cookies_${DateTime.now().microsecondsSinceEpoch}.db';
    File(dbPath).copySync(tmpDb);
    try {
      return sqlite3.open(tmpDb);
    } catch (e) {
      try { File(tmpDb).deleteSync(); } catch (_) {}
      rethrow;
    }
  }

  bool _isBrowserInstalled(Browser browser) {
    if (Platform.isMacOS) {
      switch (browser) {
        case Browser.safari: return Directory('/Applications/Safari.app').existsSync();
        case Browser.chrome: return Directory('/Applications/Google Chrome.app').existsSync();
        case Browser.firefox: return Directory('/Applications/Firefox.app').existsSync();
        case Browser.edge: return Directory('/Applications/Microsoft Edge.app').existsSync();
        case Browser.brave: return Directory('/Applications/Brave Browser.app').existsSync();
        case Browser.arc: return Directory('/Applications/Arc.app').existsSync();
        default: return false;
      }
    } else if (Platform.isLinux) {
      switch (browser) {
        case Browser.chrome:
          return _chromeDataDir().existsSync();
        case Browser.firefox:
          return _firefoxDataDir().existsSync();
        case Browser.edge:
          return Directory('${Platform.environment['HOME']}/.config/microsoft-edge').existsSync();
        case Browser.brave:
          return Directory('${Platform.environment['HOME']}/.config/BraveSoftware').existsSync();
        default: return false;
      }
    }
    return false;
  }

  Directory _chromeDataDir() => Directory('${Platform.environment['HOME']}/.config/google-chrome');
  Directory _firefoxDataDir() => Directory('${Platform.environment['HOME']}/.mozilla/firefox');

  String? _cookieDbPath(Browser browser) {
    final home = Platform.environment['HOME'] ?? '';
    if (Platform.isLinux) {
      switch (browser) {
        case Browser.chrome: return '$home/.config/google-chrome/Default/Cookies';
        case Browser.firefox:
          final profileDir = Directory('$home/.mozilla/firefox');
          if (profileDir.existsSync()) {
            for (final entity in profileDir.listSync()) {
              if (entity is Directory && (entity.path.endsWith('.default') || entity.path.endsWith('.default-release'))) {
                final cookiesPath = '${entity.path}/cookies.sqlite';
                if (File(cookiesPath).existsSync()) return cookiesPath;
              }
            }
          }
          return null;
        case Browser.edge: return '$home/.config/microsoft-edge/Default/Cookies';
        case Browser.brave: return '$home/.config/BraveSoftware/Brave-Browser/Default/Cookies';
        default: return null;
      }
    } else if (Platform.isMacOS) {
      switch (browser) {
        case Browser.chrome: return '$home/Library/Application Support/Google/Chrome/Default/Cookies';
        case Browser.firefox:
          final profileDir = Directory('$home/Library/Application Support/Firefox/Profiles');
          if (profileDir.existsSync()) {
            for (final entity in profileDir.listSync()) {
              if (entity is Directory && entity.path.endsWith('.default-release')) {
                return '${entity.path}/cookies.sqlite';
              }
            }
          }
          return null;
        default: return null;
      }
    }
    return null;
  }
}
