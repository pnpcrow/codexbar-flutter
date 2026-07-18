/// The kind of fetch strategy.
/// Direct port of Swift ProviderFetchKind.
enum ProviderFetchKind {
  cli,
  web,
  oauth,
  apiToken,
  localProbe,
  webDashboard;

  String get label {
    switch (this) {
      case ProviderFetchKind.cli:
        return 'CLI';
      case ProviderFetchKind.web:
        return 'Web';
      case ProviderFetchKind.oauth:
        return 'OAuth';
      case ProviderFetchKind.apiToken:
        return 'API Token';
      case ProviderFetchKind.localProbe:
        return 'Local Probe';
      case ProviderFetchKind.webDashboard:
        return 'Web Dashboard';
    }
  }
}

/// Source mode for provider data fetching.
/// Direct port of Swift ProviderSourceMode.
enum ProviderSourceMode {
  auto,
  web,
  cli,
  oauth,
  api;

  bool get usesWeb => this == auto || this == web;
}
