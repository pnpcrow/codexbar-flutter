// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_window.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RateWindowImpl _$$RateWindowImplFromJson(Map<String, dynamic> json) =>
    _$RateWindowImpl(
      usedPercent: (json['usedPercent'] as num).toDouble(),
      windowMinutes: (json['windowMinutes'] as num?)?.toInt(),
      resetsAt: json['resetsAt'] == null
          ? null
          : DateTime.parse(json['resetsAt'] as String),
      resetDescription: json['resetDescription'] as String?,
      nextRegenPercent: (json['nextRegenPercent'] as num?)?.toDouble(),
      isSyntheticPlaceholder: json['isSyntheticPlaceholder'] as bool? ?? false,
    );

Map<String, dynamic> _$$RateWindowImplToJson(_$RateWindowImpl instance) =>
    <String, dynamic>{
      'usedPercent': instance.usedPercent,
      'windowMinutes': instance.windowMinutes,
      'resetsAt': instance.resetsAt?.toIso8601String(),
      'resetDescription': instance.resetDescription,
      'nextRegenPercent': instance.nextRegenPercent,
      'isSyntheticPlaceholder': instance.isSyntheticPlaceholder,
    };

_$NamedRateWindowImpl _$$NamedRateWindowImplFromJson(
  Map<String, dynamic> json,
) => _$NamedRateWindowImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  window: RateWindow.fromJson(json['window'] as Map<String, dynamic>),
  usageKnown: json['usageKnown'] as bool? ?? true,
);

Map<String, dynamic> _$$NamedRateWindowImplToJson(
  _$NamedRateWindowImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'window': instance.window,
  'usageKnown': instance.usageKnown,
};
