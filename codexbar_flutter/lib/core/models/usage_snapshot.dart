import 'package:freezed_annotation/freezed_annotation.dart';
import 'rate_window.dart';

part 'usage_snapshot.freezed.dart';
part 'usage_snapshot.g.dart';

@freezed
class ProviderIdentitySnapshot with _$ProviderIdentitySnapshot {
  const factory ProviderIdentitySnapshot({
    String? providerID,
    String? accountEmail,
    String? accountOrganization,
    String? loginMethod,
    String? accountID,
  }) = _ProviderIdentitySnapshot;

  factory ProviderIdentitySnapshot.fromJson(Map<String, dynamic> json) =>
      _$ProviderIdentitySnapshotFromJson(json);
}

enum UsageDataConfidence { exact, estimated, percentOnly, unknown }

@freezed
class ProviderCostSnapshot with _$ProviderCostSnapshot {
  const factory ProviderCostSnapshot({
    double? totalCost,
    double? monthlyBudget,
    String? currency,
  }) = _ProviderCostSnapshot;

  factory ProviderCostSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ProviderCostSnapshotFromJson(json);
}

@freezed
class UsageSnapshot with _$UsageSnapshot {
  const factory UsageSnapshot({
    RateWindow? primary,
    RateWindow? secondary,
    RateWindow? tertiary,
    List<NamedRateWindow>? extraRateWindows,
    ProviderCostSnapshot? providerCost,
    DateTime? subscriptionExpiresAt,
    DateTime? subscriptionRenewsAt,
    required DateTime updatedAt,
    ProviderIdentitySnapshot? identity,
    @Default(UsageDataConfidence.unknown) UsageDataConfidence dataConfidence,
  }) = _UsageSnapshot;

  factory UsageSnapshot.fromJson(Map<String, dynamic> json) =>
      _$UsageSnapshotFromJson(json);
}

extension UsageSnapshotX on UsageSnapshot {
  String? get accountEmail => identity?.accountEmail;

  String? loginMethod(String provider) => identity?.loginMethod;

  bool get hasPrimary => primary != null;
  bool get hasSecondary => secondary != null;
  bool get hasTertiary => tertiary != null;
}
