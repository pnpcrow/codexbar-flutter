import 'dart:io';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

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

/// Reads browser cookies from SQLite databases.
/// On Linux, reads Chrome's Cookies.db directly using the sqlite3 Dart package.
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

  static String _domainFor(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude: return '.claude.com';
      case UsageProvider.openai: return '.openai.com';
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

  Future<bool> hasPlausibleSession(UsageProvider provider) async {
    final order = importOrderFor(provider);
    for (final browser in order) {
      final dbPath = _cookieDbPath(browser);
      if (dbPath == null || !File(dbPath).existsSync()) continue;
      try {
        final db = _openDbCopy(dbPath);
        final domain = _domainFor(provider);
        final domainPattern = '%${domain.replaceAll('.', '')}%';
        final result = db.select('SELECT COUNT(*) as cnt FROM cookies WHERE host_key LIKE ?', [domainPattern]);
        final count = result.isNotEmpty ? (result.first['cnt'] as int) : 0;
        db.dispose();
        if (count > 0) return true;
      } catch (_) {}
    }
    return false;
  }

  Future<CookieResolution?> resolve(UsageProvider provider) async {
    final order = importOrderFor(provider);
    for (final browser in order) {
      final dbPath = _cookieDbPath(browser);
      if (dbPath == null || !File(dbPath).existsSync()) continue;
      try {
        final cookies = _readCookies(dbPath, provider);
        if (cookies.isNotEmpty) {
          return CookieResolution(cookieHeader: cookies, browser: browser);
        }
      } catch (_) {}
    }
    return null;
  }

  /// Read cookies from SQLite DB. Returns cookie header string.
  String _readCookies(String dbPath, UsageProvider provider) {
    final db = _openDbCopy(dbPath);
    try {
      final domain = _domainFor(provider);
      final domainPattern = '%${domain.replaceAll('.', '')}%';

      final rows = db.select(
        'SELECT name, value, encrypted_value FROM cookies WHERE host_key LIKE ?',
        [domainPattern],
      );

      final cookiePairs = <String>[];
      for (final row in rows) {
        final name = row['name'] as String;
        final value = row['value'] as String;
        final encValue = row['encrypted_value'] as Uint8List;

        if (value.isNotEmpty) {
          cookiePairs.add('$name=$value');
        } else if (encValue.isNotEmpty) {
          // Try to decrypt v10 cookies (hardcoded "peanuts" password on Linux)
          final decrypted = _tryDecryptV10(encValue);
          if (decrypted != null) {
            cookiePairs.add('$name=$decrypted');
          }
          // v11 cookies need keyring key - skip if we can't decrypt
        }
      }

      return cookiePairs.join('; ');
    } finally {
      db.dispose();
    }
  }

  /// Try to decrypt Chrome v10 encrypted cookie (Linux: PBKDF2 with "peanuts" password).
  String? _tryDecryptV10(Uint8List encryptedValue) {
    if (encryptedValue.length < 3) return null;
    final prefix = String.fromCharCodes(encryptedValue.sublist(0, 3));

    if (prefix == 'v10') {
      // v10: PBKDF2(password="peanuts", salt="saltysalt", iterations=1, keylen=16)
      // Then AES-128-CBC with IV=16 spaces
      // This is a simplified version - real implementation needs crypto library
      return null;
    } else if (prefix == 'v11') {
      // v11: Uses keyring key - cannot decrypt without keyring access
      return null;
    }
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
                return '${entity.path}/cookies.sqlite';
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
