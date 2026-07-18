import 'dart:ui';

/// Provider branding - icon style and color.
/// Direct port of Swift ProviderBranding.
class ProviderBranding {
  final String iconStyle;
  final String iconResourceName;
  final int colorValue;

  const ProviderBranding({
    required this.iconStyle,
    required this.iconResourceName,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'iconStyle': iconStyle,
        'iconResourceName': iconResourceName,
        'colorValue': colorValue,
      };

  factory ProviderBranding.fromJson(Map<String, dynamic> json) =>
      ProviderBranding(
        iconStyle: json['iconStyle'] as String,
        iconResourceName: json['iconResourceName'] as String,
        colorValue: json['colorValue'] as int,
      );
}
