import 'usage_provider.dart';

/// Provider metadata - display info, CLI config, dashboard URLs.
/// Direct port of Swift ProviderMetadata.
class ProviderMetadata {
  final UsageProvider id;
  final String displayName;
  final String sessionLabel;
  final String weeklyLabel;
  final String? opusLabel;
  final bool supportsOpus;
  final bool supportsCredits;
  final String creditsHint;
  final String toggleTitle;
  final String cliName;
  final bool defaultEnabled;
  final bool isPrimaryProvider;
  final bool usesAccountFallback;
  final String? dashboardURL;
  final String? subscriptionDashboardURL;
  final String? changelogURL;
  final String? statusPageURL;
  final String? statusLinkURL;

  const ProviderMetadata({
    required this.id,
    required this.displayName,
    required this.sessionLabel,
    required this.weeklyLabel,
    this.opusLabel,
    this.supportsOpus = false,
    this.supportsCredits = false,
    this.creditsHint = '',
    required this.toggleTitle,
    required this.cliName,
    this.defaultEnabled = false,
    this.isPrimaryProvider = false,
    this.usesAccountFallback = false,
    this.dashboardURL,
    this.subscriptionDashboardURL,
    this.changelogURL,
    this.statusPageURL,
    this.statusLinkURL,
  });

  factory ProviderMetadata.fromJson(Map<String, dynamic> json) =>
      ProviderMetadata(
        id: UsageProvider.values.byName(json['id'] as String),
        displayName: json['displayName'] as String,
        sessionLabel: json['sessionLabel'] as String,
        weeklyLabel: json['weeklyLabel'] as String,
        opusLabel: json['opusLabel'] as String?,
        supportsOpus: json['supportsOpus'] as bool? ?? false,
        supportsCredits: json['supportsCredits'] as bool? ?? false,
        creditsHint: json['creditsHint'] as String? ?? '',
        toggleTitle: json['toggleTitle'] as String,
        cliName: json['cliName'] as String,
        defaultEnabled: json['defaultEnabled'] as bool? ?? false,
        isPrimaryProvider: json['isPrimaryProvider'] as bool? ?? false,
        usesAccountFallback: json['usesAccountFallback'] as bool? ?? false,
        dashboardURL: json['dashboardURL'] as String?,
        subscriptionDashboardURL: json['subscriptionDashboardURL'] as String?,
        changelogURL: json['changelogURL'] as String?,
        statusPageURL: json['statusPageURL'] as String?,
        statusLinkURL: json['statusLinkURL'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id.name,
        'displayName': displayName,
        'sessionLabel': sessionLabel,
        'weeklyLabel': weeklyLabel,
        if (opusLabel != null) 'opusLabel': opusLabel,
        if (supportsOpus) 'supportsOpus': true,
        if (supportsCredits) 'supportsCredits': true,
        if (creditsHint.isNotEmpty) 'creditsHint': creditsHint,
        'toggleTitle': toggleTitle,
        'cliName': cliName,
        if (defaultEnabled) 'defaultEnabled': true,
        if (isPrimaryProvider) 'isPrimaryProvider': true,
        if (usesAccountFallback) 'usesAccountFallback': true,
        if (dashboardURL != null) 'dashboardURL': dashboardURL,
        if (subscriptionDashboardURL != null)
          'subscriptionDashboardURL': subscriptionDashboardURL,
        if (changelogURL != null) 'changelogURL': changelogURL,
        if (statusPageURL != null) 'statusPageURL': statusPageURL,
        if (statusLinkURL != null) 'statusLinkURL': statusLinkURL,
      };
}
