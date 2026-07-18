import 'usage_provider.dart';

/// Provider identity snapshot - account info for a provider.
/// Direct port of Swift ProviderIdentitySnapshot.
class ProviderIdentitySnapshot {
  final UsageProvider? providerID;
  final String? accountEmail;
  final String? accountOrganization;
  final String? loginMethod;
  final String? accountID;

  const ProviderIdentitySnapshot({
    this.providerID,
    this.accountEmail,
    this.accountOrganization,
    this.loginMethod,
    this.accountID,
  });

  ProviderIdentitySnapshot scopedTo(UsageProvider provider) {
    if (providerID == provider) return this;
    return ProviderIdentitySnapshot(
      providerID: provider,
      accountEmail: accountEmail,
      accountOrganization: accountOrganization,
      loginMethod: loginMethod,
      accountID: accountID,
    );
  }

  factory ProviderIdentitySnapshot.fromJson(Map<String, dynamic> json) =>
      ProviderIdentitySnapshot(
        providerID: json['providerID'] != null
            ? UsageProvider.values.byName(json['providerID'] as String)
            : null,
        accountEmail: json['accountEmail'] as String?,
        accountOrganization: json['accountOrganization'] as String?,
        loginMethod: json['loginMethod'] as String?,
        accountID: json['accountID'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (providerID != null) 'providerID': providerID!.name,
        if (accountEmail != null) 'accountEmail': accountEmail,
        if (accountOrganization != null)
          'accountOrganization': accountOrganization,
        if (loginMethod != null) 'loginMethod': loginMethod,
        if (accountID != null) 'accountID': accountID,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderIdentitySnapshot &&
          providerID == other.providerID &&
          accountEmail == other.accountEmail &&
          accountOrganization == other.accountOrganization &&
          loginMethod == other.loginMethod &&
          accountID == other.accountID;

  @override
  int get hashCode =>
      Object.hash(providerID, accountEmail, accountOrganization, loginMethod, accountID);
}

/// Confidence level of usage data.
enum UsageDataConfidence {
  exact,
  estimated,
  percentOnly,
  unknown;
}
