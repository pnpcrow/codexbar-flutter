import 'package:freezed_annotation/freezed_annotation.dart';

part 'credits_models.freezed.dart';
part 'credits_models.g.dart';

@freezed
class CreditsSnapshot with _$CreditsSnapshot {
  const factory CreditsSnapshot({
    double? remaining,
    double? total,
    String? currency,
    double? codexCreditLimitRemaining,
    double? codexCreditLimitTotal,
  }) = _CreditsSnapshot;

  factory CreditsSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CreditsSnapshotFromJson(json);
}

@freezed
class AccountInfo with _$AccountInfo {
  const factory AccountInfo({
    String? email,
    String? plan,
    String? organization,
  }) = _AccountInfo;

  factory AccountInfo.fromJson(Map<String, dynamic> json) =>
      _$AccountInfoFromJson(json);
}
