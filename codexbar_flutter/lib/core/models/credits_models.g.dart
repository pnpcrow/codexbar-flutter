// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreditsSnapshotImpl _$$CreditsSnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$CreditsSnapshotImpl(
  remaining: (json['remaining'] as num?)?.toDouble(),
  total: (json['total'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  codexCreditLimitRemaining: (json['codexCreditLimitRemaining'] as num?)
      ?.toDouble(),
  codexCreditLimitTotal: (json['codexCreditLimitTotal'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$CreditsSnapshotImplToJson(
  _$CreditsSnapshotImpl instance,
) => <String, dynamic>{
  'remaining': instance.remaining,
  'total': instance.total,
  'currency': instance.currency,
  'codexCreditLimitRemaining': instance.codexCreditLimitRemaining,
  'codexCreditLimitTotal': instance.codexCreditLimitTotal,
};

_$AccountInfoImpl _$$AccountInfoImplFromJson(Map<String, dynamic> json) =>
    _$AccountInfoImpl(
      email: json['email'] as String?,
      plan: json['plan'] as String?,
      organization: json['organization'] as String?,
    );

Map<String, dynamic> _$$AccountInfoImplToJson(_$AccountInfoImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'plan': instance.plan,
      'organization': instance.organization,
    };
