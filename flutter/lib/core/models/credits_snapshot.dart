import 'package:flutter/foundation.dart';

/// A single credit ledger event.
///
/// Ported from `CreditEvent` in `CreditsModels.swift`.
@immutable
class CreditEvent {
  const CreditEvent({
    required this.id,
    required this.date,
    required this.service,
    required this.creditsUsed,
  });

  final String id;
  final DateTime date;
  final String service;
  final double creditsUsed;

  factory CreditEvent.fromJson(Map<String, dynamic> json) => CreditEvent(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        service: json['service'] as String,
        creditsUsed: (json['creditsUsed'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'service': service,
        'creditsUsed': creditsUsed,
      };
}

/// Credits balance snapshot.
///
/// Ported from `CreditsSnapshot` in `CreditsModels.swift`.
@immutable
class CreditsSnapshot {
  const CreditsSnapshot({
    required this.remaining,
    required this.updatedAt,
    this.events = const [],
    this.codexCreditLimit,
  });

  final double remaining;
  final List<CreditEvent> events;
  final DateTime updatedAt;
  final CodexCreditLimitSnapshot? codexCreditLimit;

  factory CreditsSnapshot.fromJson(Map<String, dynamic> json) => CreditsSnapshot(
        remaining: (json['remaining'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        events: (json['events'] as List<dynamic>? ?? [])
            .map((e) => CreditEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        codexCreditLimit: json['codexCreditLimit'] == null
            ? null
            : CodexCreditLimitSnapshot.fromJson(
                json['codexCreditLimit'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'remaining': remaining,
        'updatedAt': updatedAt.toIso8601String(),
        'events': events.map((e) => e.toJson()).toList(),
        if (codexCreditLimit != null) 'codexCreditLimit': codexCreditLimit!.toJson(),
      };
}

/// A monthly credit-limit sub-snapshot (e.g. Codex individual limit).
///
/// Ported from `CodexCreditLimitSnapshot` in `CreditsModels.swift`.
@immutable
class CodexCreditLimitSnapshot {
  const CodexCreditLimitSnapshot({
    this.title = 'Monthly credit limit',
    required this.used,
    required this.limit,
    required this.remaining,
    required this.remainingPercent,
    this.resetsAt,
    required this.updatedAt,
  });

  final String title;
  final double used;
  final double limit;
  final double remaining;
  final double remainingPercent;
  final DateTime? resetsAt;
  final DateTime updatedAt;

  double get usedPercent {
    final v = 100 - remainingPercent;
    if (v < 0) return 0;
    if (v > 100) return 100;
    return v;
  }

  factory CodexCreditLimitSnapshot.fromJson(Map<String, dynamic> json) =>
      CodexCreditLimitSnapshot(
        title: (json['title'] as String?) ?? 'Monthly credit limit',
        used: (json['used'] as num).toDouble(),
        limit: (json['limit'] as num).toDouble(),
        remaining: (json['remaining'] as num).toDouble(),
        remainingPercent: (json['remainingPercent'] as num).toDouble(),
        resetsAt: json['resetsAt'] == null
            ? null
            : DateTime.parse(json['resetsAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'used': used,
        'limit': limit,
        'remaining': remaining,
        'remainingPercent': remainingPercent,
        if (resetsAt != null) 'resetsAt': resetsAt!.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
