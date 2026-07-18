import 'provider_identity.dart';
import 'rate_window.dart';
import 'usage_provider.dart';

/// Complete usage snapshot for a provider.
/// Direct port of Swift UsageSnapshot.
class UsageSnapshot {
  final RateWindow? primary;
  final RateWindow? secondary;
  final RateWindow? tertiary;
  final List<NamedRateWindow>? extraRateWindows;
  final DateTime? subscriptionExpiresAt;
  final DateTime? subscriptionRenewsAt;
  final DateTime updatedAt;
  final ProviderIdentitySnapshot? identity;
  final UsageDataConfidence dataConfidence;

  const UsageSnapshot({
    this.primary,
    this.secondary,
    this.tertiary,
    this.extraRateWindows,
    this.subscriptionExpiresAt,
    this.subscriptionRenewsAt,
    required this.updatedAt,
    this.identity,
    this.dataConfidence = UsageDataConfidence.unknown,
  });

  bool get hasRateLimitWindows =>
      primary != null ||
      secondary != null ||
      tertiary != null ||
      (extraRateWindows != null && extraRateWindows!.isNotEmpty);

  ProviderIdentitySnapshot? identityFor(UsageProvider provider) {
    if (identity == null || identity!.providerID != provider) return null;
    return identity;
  }

  String? accountEmail(UsageProvider provider) =>
      identityFor(provider)?.accountEmail;

  String? accountOrganization(UsageProvider provider) =>
      identityFor(provider)?.accountOrganization;

  String? loginMethod(UsageProvider provider) =>
      identityFor(provider)?.loginMethod;

  RateWindow? switcherWeeklyWindow(UsageProvider provider,
      {required bool showUsed}) {
    switch (provider) {
      case UsageProvider.cursor:
        if (!showUsed &&
            primary != null &&
            primary!.remainingPercent <= 0) {
          return primary;
        }
        return primary ?? secondary;
      default:
        return primary ?? secondary;
    }
  }

  UsageSnapshot withIdentity(ProviderIdentitySnapshot? newIdentity) {
    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      extraRateWindows: extraRateWindows,
      subscriptionExpiresAt: subscriptionExpiresAt,
      subscriptionRenewsAt: subscriptionRenewsAt,
      updatedAt: updatedAt,
      identity: newIdentity,
      dataConfidence: dataConfidence,
    );
  }

  UsageSnapshot scopedTo(UsageProvider provider) {
    if (identity == null) return this;
    final scoped = identity!.scopedTo(provider);
    if (scoped.providerID == identity!.providerID) return this;
    return withIdentity(scoped);
  }

  UsageSnapshot backfillingResetTimes({UsageSnapshot? cached, DateTime? now}) {
    if (cached == null) return this;
    final newPrimary =
        primary?.backfillingResetTime(cached: cached.primary, now: now);
    final newSecondary =
        secondary?.backfillingResetTime(cached: cached.secondary, now: now);
    final newTertiary =
        tertiary?.backfillingResetTime(cached: cached.tertiary, now: now);
    if (identical(newPrimary, primary) &&
        identical(newSecondary, secondary) &&
        identical(newTertiary, tertiary)) {
      return this;
    }
    return UsageSnapshot(
      primary: newPrimary,
      secondary: newSecondary,
      tertiary: newTertiary,
      extraRateWindows: extraRateWindows,
      subscriptionExpiresAt: subscriptionExpiresAt,
      subscriptionRenewsAt: subscriptionRenewsAt,
      updatedAt: updatedAt,
      identity: identity,
      dataConfidence: dataConfidence,
    );
  }

  factory UsageSnapshot.fromJson(Map<String, dynamic> json) =>
      UsageSnapshot(
        primary: json['primary'] != null
            ? RateWindow.fromJson(json['primary'] as Map<String, dynamic>)
            : null,
        secondary: json['secondary'] != null
            ? RateWindow.fromJson(json['secondary'] as Map<String, dynamic>)
            : null,
        tertiary: json['tertiary'] != null
            ? RateWindow.fromJson(json['tertiary'] as Map<String, dynamic>)
            : null,
        extraRateWindows: (json['extraRateWindows'] as List<dynamic>?)
            ?.map((e) => NamedRateWindow.fromJson(e as Map<String, dynamic>))
            .toList(),
        subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
            ? DateTime.parse(json['subscriptionExpiresAt'] as String)
            : null,
        subscriptionRenewsAt: json['subscriptionRenewsAt'] != null
            ? DateTime.parse(json['subscriptionRenewsAt'] as String)
            : null,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        identity: json['identity'] != null
            ? ProviderIdentitySnapshot.fromJson(
                json['identity'] as Map<String, dynamic>)
            : null,
        dataConfidence: json['dataConfidence'] != null
            ? UsageDataConfidence.values.byName(json['dataConfidence'] as String)
            : UsageDataConfidence.unknown,
      );

  Map<String, dynamic> toJson() => {
        if (primary != null) 'primary': primary!.toJson(),
        if (secondary != null) 'secondary': secondary!.toJson(),
        if (tertiary != null) 'tertiary': tertiary!.toJson(),
        if (extraRateWindows != null)
          'extraRateWindows': extraRateWindows!.map((e) => e.toJson()).toList(),
        if (subscriptionExpiresAt != null)
          'subscriptionExpiresAt': subscriptionExpiresAt!.toIso8601String(),
        if (subscriptionRenewsAt != null)
          'subscriptionRenewsAt': subscriptionRenewsAt!.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (identity != null) 'identity': identity!.toJson(),
        if (dataConfidence != UsageDataConfidence.unknown)
          'dataConfidence': dataConfidence.name,
      };
}
