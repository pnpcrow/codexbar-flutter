import 'package:flutter/foundation.dart';

/// Spend/cost snapshot for a provider that reports monetary usage.
///
/// Ported from `ProviderCostSnapshot` in `ProviderCostSnapshot.swift`.
@immutable
class ProviderCostSnapshot {
  const ProviderCostSnapshot({
    required this.used,
    required this.limit,
    required this.currencyCode,
    required this.updatedAt,
    this.period,
    this.resetsAt,
    this.nextRegenAmount,
    this.personalUsed,
  });

  final double used;
  final double limit;
  final String currencyCode;

  /// Optional human label, e.g. "Monthly".
  final String? period;

  /// Optional period renewal/reset time.
  final DateTime? resetsAt;

  /// Rolling-credit regen amount, where supported.
  final double? nextRegenAmount;

  /// Share of a pooled/team budget attributable to this account.
  final double? personalUsed;

  final DateTime updatedAt;

  double get remaining => limit - used;
  double get usedPercent => limit <= 0
      ? (used > 0 ? 100 : 0)
      : (used / limit * 100).clamp(0, 100).toDouble();

  factory ProviderCostSnapshot.fromJson(Map<String, dynamic> json) {
    return ProviderCostSnapshot(
      used: (json['used'] as num).toDouble(),
      limit: (json['limit'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      period: json['period'] as String?,
      resetsAt: _parseDate(json['resetsAt']),
      nextRegenAmount: (json['nextRegenAmount'] as num?)?.toDouble(),
      personalUsed: (json['personalUsed'] as num?)?.toDouble(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'used': used,
      'limit': limit,
      'currencyCode': currencyCode,
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (period != null) json['period'] = period;
    if (resetsAt != null) json['resetsAt'] = resetsAt!.toIso8601String();
    if (nextRegenAmount != null) json['nextRegenAmount'] = nextRegenAmount;
    if (personalUsed != null) json['personalUsed'] = personalUsed;
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
