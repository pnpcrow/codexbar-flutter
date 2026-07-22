// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProviderIdentitySnapshotImpl _$$ProviderIdentitySnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$ProviderIdentitySnapshotImpl(
  providerID: json['providerID'] as String?,
  accountEmail: json['accountEmail'] as String?,
  accountOrganization: json['accountOrganization'] as String?,
  loginMethod: json['loginMethod'] as String?,
  accountID: json['accountID'] as String?,
);

Map<String, dynamic> _$$ProviderIdentitySnapshotImplToJson(
  _$ProviderIdentitySnapshotImpl instance,
) => <String, dynamic>{
  'providerID': instance.providerID,
  'accountEmail': instance.accountEmail,
  'accountOrganization': instance.accountOrganization,
  'loginMethod': instance.loginMethod,
  'accountID': instance.accountID,
};

_$ProviderCostSnapshotImpl _$$ProviderCostSnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$ProviderCostSnapshotImpl(
  totalCost: (json['totalCost'] as num?)?.toDouble(),
  monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
);

Map<String, dynamic> _$$ProviderCostSnapshotImplToJson(
  _$ProviderCostSnapshotImpl instance,
) => <String, dynamic>{
  'totalCost': instance.totalCost,
  'monthlyBudget': instance.monthlyBudget,
  'currency': instance.currency,
};

_$UsageSnapshotImpl _$$UsageSnapshotImplFromJson(Map<String, dynamic> json) =>
    _$UsageSnapshotImpl(
      primary: json['primary'] == null
          ? null
          : RateWindow.fromJson(json['primary'] as Map<String, dynamic>),
      secondary: json['secondary'] == null
          ? null
          : RateWindow.fromJson(json['secondary'] as Map<String, dynamic>),
      tertiary: json['tertiary'] == null
          ? null
          : RateWindow.fromJson(json['tertiary'] as Map<String, dynamic>),
      extraRateWindows: (json['extraRateWindows'] as List<dynamic>?)
          ?.map((e) => NamedRateWindow.fromJson(e as Map<String, dynamic>))
          .toList(),
      providerCost: json['providerCost'] == null
          ? null
          : ProviderCostSnapshot.fromJson(
              json['providerCost'] as Map<String, dynamic>,
            ),
      subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
          ? null
          : DateTime.parse(json['subscriptionExpiresAt'] as String),
      subscriptionRenewsAt: json['subscriptionRenewsAt'] == null
          ? null
          : DateTime.parse(json['subscriptionRenewsAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      identity: json['identity'] == null
          ? null
          : ProviderIdentitySnapshot.fromJson(
              json['identity'] as Map<String, dynamic>,
            ),
      dataConfidence:
          $enumDecodeNullable(
            _$UsageDataConfidenceEnumMap,
            json['dataConfidence'],
          ) ??
          UsageDataConfidence.unknown,
    );

Map<String, dynamic> _$$UsageSnapshotImplToJson(
  _$UsageSnapshotImpl instance,
) => <String, dynamic>{
  'primary': instance.primary,
  'secondary': instance.secondary,
  'tertiary': instance.tertiary,
  'extraRateWindows': instance.extraRateWindows,
  'providerCost': instance.providerCost,
  'subscriptionExpiresAt': instance.subscriptionExpiresAt?.toIso8601String(),
  'subscriptionRenewsAt': instance.subscriptionRenewsAt?.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'identity': instance.identity,
  'dataConfidence': _$UsageDataConfidenceEnumMap[instance.dataConfidence]!,
};

const _$UsageDataConfidenceEnumMap = {
  UsageDataConfidence.exact: 'exact',
  UsageDataConfidence.estimated: 'estimated',
  UsageDataConfidence.percentOnly: 'percentOnly',
  UsageDataConfidence.unknown: 'unknown',
};
