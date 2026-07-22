import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_metadata.freezed.dart';
part 'provider_metadata.g.dart';

@freezed
class ProviderMetadata with _$ProviderMetadata {
  const factory ProviderMetadata({
    required String id,
    required String displayName,
    required String sessionLabel,
    required String weeklyLabel,
    String? opusLabel,
    @Default(false) bool supportsOpus,
    @Default(false) bool supportsCredits,
    @Default('') String creditsHint,
    required String toggleTitle,
    required String cliName,
    @Default(false) bool defaultEnabled,
    @Default(false) bool isPrimaryProvider,
    @Default(false) bool usesAccountFallback,
    String? dashboardURL,
    String? subscriptionDashboardURL,
    String? changelogURL,
    String? statusPageURL,
    String? statusLinkURL,
  }) = _ProviderMetadata;

  factory ProviderMetadata.fromJson(Map<String, dynamic> json) =>
      _$ProviderMetadataFromJson(json);
}
