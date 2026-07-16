import 'package:flutter/foundation.dart';

import '../models/usage_provider.dart';

/// A provider brand color, normalized to 0–1 components.
///
/// Ported from `ProviderColor` in `ProviderBranding.swift`. Upstream colors
/// are sometimes expressed in 0–255 space (e.g. OpenRouter) and are normalized
/// here.
@immutable
class ProviderColor {
  const ProviderColor({
    required this.red,
    required this.green,
    required this.blue,
  });

  /// Construct a color from 0–255 components (normalized to 0–1).
  const ProviderColor.from255(int r, int g, int b)
      : red = r / 255,
        green = g / 255,
        blue = b / 255;

  final double red;
  final double green;
  final double blue;

  static const black = ProviderColor(red: 0, green: 0, blue: 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderColor &&
          other.red == red &&
          other.green == green &&
          other.blue == blue;

  @override
  int get hashCode => Object.hash(red, green, blue);
}

/// Branding metadata for a provider icon.
///
/// Ported from `ProviderBranding` in `ProviderBranding.swift`.
@immutable
class ProviderBranding {
  const ProviderBranding({
    required this.iconStyle,
    required this.iconResourceName,
    this.color = ProviderColor.black,
  });

  final IconStyle iconStyle;

  /// Resource name of the brand SVG, e.g. `ProviderIcon-openai`.
  final String iconResourceName;

  final ProviderColor color;
}

/// Static metadata describing a provider's labels and external links.
///
/// Ported from `ProviderMetadata` in `Providers.swift`. Only fields relevant
/// to the Flutter port's menu/settings UI are kept; optional fields default to
/// `null`/`false`.
@immutable
class ProviderMetadata {
  const ProviderMetadata({
    required this.id,
    required this.displayName,
    required this.sessionLabel,
    required this.weeklyLabel,
    this.opusLabel,
    this.supportsOpus = false,
    this.supportsCredits = false,
    this.creditsHint = '',
    this.toggleTitle = '',
    this.cliName = '',
    this.defaultEnabled = false,
    this.isPrimaryProvider = false,
    this.usesAccountFallback = false,
    this.dashboardURL,
    this.subscriptionDashboardURL,
    this.changelogURL,
    this.statusPageURL,
    this.statusLinkURL,
    this.statusWorkspaceProductID,
  });

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
  final String? statusWorkspaceProductID;
}

/// Configures whether a provider supports token-cost scanning.
///
/// Ported from `ProviderTokenCostConfig` in `ProviderDescriptor.swift`.
@immutable
class ProviderTokenCostConfig {
  const ProviderTokenCostConfig({
    required this.supportsTokenCost,
    this.noDataMessage = '',
  });

  final bool supportsTokenCost;
  final String noDataMessage;
}

/// CLI configuration for a provider (used by strategies that spawn a CLI).
///
/// Ported from `ProviderCLIConfig` in `ProviderDescriptor.swift`.
@immutable
class ProviderCLIConfig {
  const ProviderCLIConfig({this.name = '', this.versionArgument = '--version'});

  final String name;
  final String versionArgument;
}

/// The complete descriptor for a provider: metadata, branding, and the fetch
/// pipeline that produces a [UsageSnapshot].
///
/// Ported from `ProviderDescriptor` in `ProviderDescriptor.swift`. The fetch
/// pipeline (strategies) is supplied by `ProviderDescriptorRegistry` rather
/// than embedded here, mirroring the Swift separation.
@immutable
class ProviderDescriptor {
  const ProviderDescriptor({
    required this.metadata,
    required this.branding,
    this.tokenCost = const ProviderTokenCostConfig(supportsTokenCost: false),
    this.cli = const ProviderCLIConfig(),
  });

  final ProviderMetadata metadata;
  final ProviderBranding branding;
  final ProviderTokenCostConfig tokenCost;
  final ProviderCLIConfig cli;

  UsageProvider get id => metadata.id;
}
