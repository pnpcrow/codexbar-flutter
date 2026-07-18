import 'dart:io';

import '../models/usage_provider.dart';

/// Supported browsers for cookie extraction.
enum Browser {
  safari,
  chrome,
  chromeBeta,
  chromeCanary,
  firefox,
  edge,
  dia,
  arc,
  brave,
  vivaldi;

  String get displayName {
    switch (this) {
      case Browser.safari:
        return 'Safari';
      case Browser.chrome:
        return 'Chrome';
      case Browser.chromeBeta:
        return 'Chrome Beta';
      case Browser.chromeCanary:
        return 'Chrome Canary';
      case Browser.firefox:
        return 'Firefox';
      case Browser.edge:
        return 'Edge';
      case Browser.dia:
        return 'Dia';
      case Browser.arc:
        return 'Arc';
      case Browser.brave:
        return 'Brave';
      case Browser.vivaldi:
        return 'Vivaldi';
    }
  }
}

/// Cookie import order for a provider.
typedef BrowserCookieImportOrder = List<Browser>;

/// Result of a cookie extraction.
class CookieResolution {
  final String cookieHeader;
  final Browser browser;

  const CookieResolution({required this.cookieHeader, required this.browser});
}

/// Resolves browser cookies for providers.
/// Direct port of Swift BrowserCookieAccessGate + ProviderCookieSource.
///
/// NOTE: Actual cookie extraction requires platform-specific implementations
/// (macOS Keychain, Windows DPAPI, Linux secret service).
/// This is a placeholder for the interface.
class BrowserCookieResolver {
  static final BrowserCookieResolver _instance = BrowserCookieResolver._();
  factory BrowserCookieResolver() => _instance;
  BrowserCookieResolver._();

  /// Default browser import order.
  static const defaultImportOrder = [
    Browser.safari,
    Browser.chrome,
    Browser.firefox,
    Browser.edge,
    Browser.brave,
    Browser.vivaldi,
    Browser.arc,
  ];

  /// Provider-specific browser import order.
  static BrowserCookieImportOrder importOrderFor(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.cursor:
        // Safari first for Cursor
        return [Browser.safari, ...defaultImportOrder.where((b) => b != Browser.safari)];
      case UsageProvider.codex:
        return [Browser.safari, Browser.chrome, Browser.firefox, ...defaultImportOrder.where(
          (b) => ![Browser.safari, Browser.chrome, Browser.firefox].contains(b),
        )];
      case UsageProvider.mimo:
        return [Browser.safari, Browser.chrome, Browser.chromeBeta, Browser.chromeCanary, Browser.firefox, Browser.edge];
      case UsageProvider.grok:
        return [Browser.chrome];
      case UsageProvider.devin:
        return [Browser.chrome];
      case UsageProvider.copilot:
        return [Browser.chrome];
      case UsageProvider.qoder:
        return [Browser.chrome];
      case UsageProvider.opencode:
        return [Browser.chrome, Browser.dia];
      default:
        return defaultImportOrder;
    }
  }

  /// Check if a provider has a plausible browser session.
  /// This checks if the required browser is installed and has cookies for the provider's domain.
  Future<bool> hasPlausibleSession(UsageProvider provider) async {
    final order = importOrderFor(provider);
    for (final browser in order) {
      if (await _isBrowserInstalled(browser)) {
        // In a real implementation, check if the browser has cookies for the provider's domain
        return true;
      }
    }
    return false;
  }

  /// Extract cookies for a provider from browsers.
  Future<CookieResolution?> resolve(UsageProvider provider) async {
    final order = importOrderFor(provider);
    for (final browser in order) {
      try {
        final cookies = await _extractCookies(browser, provider);
        if (cookies != null && cookies.isNotEmpty) {
          return CookieResolution(cookieHeader: cookies, browser: browser);
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  /// Check if a browser is installed on the current platform.
  Future<bool> _isBrowserInstalled(Browser browser) async {
    if (Platform.isMacOS) {
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
        case Browser.arc:
          return Directory('/Applications/Arc.app').existsSync();
        default:
          return false;
      }
    } else if (Platform.isLinux) {
      // Linux browser detection
      switch (browser) {
        case Browser.chrome:
          return _whichExists('google-chrome') || _whichExists('chromium');
        case Browser.firefox:
          return _whichExists('firefox');
        default:
          return false;
      }
    } else if (Platform.isWindows) {
      // Windows browser detection via Program Files
      return false; // TODO: Implement
    }
    return false;
  }

  bool _whichExists(String binary) {
    try {
      final result = Process.runSync('which', [binary]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Extract cookies from a browser for a provider.
  /// This is a platform-specific implementation.
  Future<String?> _extractCookies(Browser browser, UsageProvider provider) async {
    // TODO: Implement platform-specific cookie extraction
    // macOS: Use Keychain + browser cookie stores
    // Linux: Use browser cookie databases
    // Windows: Use browser cookie stores
    return null;
  }
}
