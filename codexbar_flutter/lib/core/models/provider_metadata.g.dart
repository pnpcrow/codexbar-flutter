// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProviderMetadataImpl _$$ProviderMetadataImplFromJson(
  Map<String, dynamic> json,
) => _$ProviderMetadataImpl(
  id: json['id'] as String,
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

Map<String, dynamic> _$$ProviderMetadataImplToJson(
  _$ProviderMetadataImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'sessionLabel': instance.sessionLabel,
  'weeklyLabel': instance.weeklyLabel,
  'opusLabel': instance.opusLabel,
  'supportsOpus': instance.supportsOpus,
  'supportsCredits': instance.supportsCredits,
  'creditsHint': instance.creditsHint,
  'toggleTitle': instance.toggleTitle,
  'cliName': instance.cliName,
  'defaultEnabled': instance.defaultEnabled,
  'isPrimaryProvider': instance.isPrimaryProvider,
  'usesAccountFallback': instance.usesAccountFallback,
  'dashboardURL': instance.dashboardURL,
  'subscriptionDashboardURL': instance.subscriptionDashboardURL,
  'changelogURL': instance.changelogURL,
  'statusPageURL': instance.statusPageURL,
  'statusLinkURL': instance.statusLinkURL,
};
