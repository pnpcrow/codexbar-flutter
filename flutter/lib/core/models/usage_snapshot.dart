import 'package:flutter/foundation.dart';

import 'provider_cost.dart';
import 'provider_identity.dart';
import 'rate_window.dart';

/// Confidence in the underlying usage data.
///
/// Ported from `UsageDataConfidence` in `UsageFetcher.swift`.
enum UsageDataConfidence {
  exact,
  estimated,
  percentOnly,
  unknown;

  static UsageDataConfidence fromString(String? value) {
    return switch (value) {
      'exact' => UsageDataConfidence.exact,
      'estimated' => UsageDataConfidence.estimated,
      'percentOnly' => UsageDataConfidence.percentOnly,
      _ => UsageDataConfidence.unknown,
    };
  }
}

/// The normalized usage snapshot for a single provider fetch.
///
/// Ported from `UsageSnapshot` in `UsageFetcher.swift`, keeping the common
/// core fields. Provider-specific detail structs (kiroUsage, ampUsage,
/// openRouterUsage, deepseekUsage, ...) from the Swift original are omitted
/// initially and added per provider as they are implemented.
///
/// See `docs/upstream/PORT_MAP.md` and `DECISIONS.md` for the deferral rationale.
@immutable
class UsageSnapshot {
  const UsageSnapshot({
    this.primary,
    this.secondary,
    this.tertiary,
    this.extraRateWindows,
    this.providerCost,
    this.openRouterUsage,
    this.deepseekUsage,
    this.subscriptionExpiresAt,
    this.subscriptionRenewsAt,
    required this.updatedAt,
    this.identity,
    this.dataConfidence = UsageDataConfidence.unknown,
  });

  final RateWindow? primary;
  final RateWindow? secondary;
  final RateWindow? tertiary;
  final List<NamedRateWindow>? extraRateWindows;
  final ProviderCostSnapshot? providerCost;

  /// Provider-specific detail carried alongside the core snapshot. Only the
  /// implemented providers populate these; they are left `null` otherwise.
  final Map<String, dynamic>? openRouterUsage;
  final Map<String, dynamic>? deepseekUsage;

  final DateTime? subscriptionExpiresAt;
  final DateTime? subscriptionRenewsAt;
  final DateTime updatedAt;
  final ProviderIdentitySnapshot? identity;
  final UsageDataConfidence dataConfidence;

  /// Whether the provider reports any usable usage data.
  bool get hasData =>
      primary != null || secondary != null || providerCost != null;

  factory UsageSnapshot.fromJson(Map<String, dynamic> json) {
    RateWindow? window(Object? v) =>
        v == null ? null : RateWindow.fromJson(v as Map<String, dynamic>);
    return UsageSnapshot(
      primary: window(json['primary']),
      secondary: window(json['secondary']),
      tertiary: window(json['tertiary']),
      extraRateWindows: (json['extraRateWindows'] as List<dynamic>?)
          ?.map((e) => NamedRateWindow.fromJson(e as Map<String, dynamic>))
          .toList(),
      providerCost: json['providerCost'] == null
          ? null
          : ProviderCostSnapshot.fromJson(
              json['providerCost'] as Map<String, dynamic>),
      openRouterUsage: json['openRouterUsage'] as Map<String, dynamic>?,
      deepseekUsage: json['deepseekUsage'] as Map<String, dynamic>?,
      subscriptionExpiresAt: _parseDate(json['subscriptionExpiresAt']),
      subscriptionRenewsAt: _parseDate(json['subscriptionRenewsAt']),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      identity: json['identity'] == null
          ? null
          : ProviderIdentitySnapshot.fromJson(
              json['identity'] as Map<String, dynamic>),
      dataConfidence:
          UsageDataConfidence.fromString(json['dataConfidence'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'updatedAt': updatedAt.toIso8601String(),
      'dataConfidence': dataConfidence.name,
    };
    if (primary != null) json['primary'] = primary!.toJson();
    if (secondary != null) json['secondary'] = secondary!.toJson();
    if (tertiary != null) json['tertiary'] = tertiary!.toJson();
    if (extraRateWindows != null) {
      json['extraRateWindows'] = extraRateWindows!.map((e) => e.toJson()).toList();
    }
    if (providerCost != null) json['providerCost'] = providerCost!.toJson();
    if (openRouterUsage != null) json['openRouterUsage'] = openRouterUsage;
    if (deepseekUsage != null) json['deepseekUsage'] = deepseekUsage;
    if (subscriptionExpiresAt != null) {
      json['subscriptionExpiresAt'] = subscriptionExpiresAt!.toIso8601String();
    }
    if (subscriptionRenewsAt != null) {
      json['subscriptionRenewsAt'] = subscriptionRenewsAt!.toIso8601String();
    }
    if (identity != null) json['identity'] = identity!.toJson();
    return json;
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000, isUtc: true);
  }
  return DateTime.tryParse(value.toString());
}
