import 'package:flutter/foundation.dart';

import 'usage_provider.dart';

/// Identity information for the authenticated account on a provider.
///
/// Ported from `ProviderIdentitySnapshot` in `UsageFetcher.swift`.
@immutable
class ProviderIdentitySnapshot {
  const ProviderIdentitySnapshot({
    this.providerID,
    this.accountEmail,
    this.accountOrganization,
    this.loginMethod,
    this.accountID,
  });

  final UsageProvider? providerID;
  final String? accountEmail;
  final String? accountOrganization;
  final String? loginMethod;
  final String? accountID;

  /// Re-scope an identity snapshot to a specific provider, preserving fields.
  /// Ported from `ProviderIdentitySnapshot.scoped(to:)`.
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

  factory ProviderIdentitySnapshot.fromJson(Map<String, dynamic> json) {
    return ProviderIdentitySnapshot(
      providerID: UsageProvider.fromString(json['providerID'] as String?),
      accountEmail: json['accountEmail'] as String?,
      accountOrganization: json['accountOrganization'] as String?,
      loginMethod: json['loginMethod'] as String?,
      accountID: json['accountID'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (providerID != null) json['providerID'] = providerID!.name;
    if (accountEmail != null) json['accountEmail'] = accountEmail;
    if (accountOrganization != null) {
      json['accountOrganization'] = accountOrganization;
    }
    if (loginMethod != null) json['loginMethod'] = loginMethod;
    if (accountID != null) json['accountID'] = accountID;
    return json;
  }
}
