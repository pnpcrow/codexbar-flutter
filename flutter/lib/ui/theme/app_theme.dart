import 'package:flutter/material.dart';

/// App-wide theme for CodexBar Flutter. Dark-first, compact, matching the
/// macOS menu-bar card aesthetic.
ThemeData buildAppTheme() {
  const seed = Color(0xFF1F6FEB);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
    visualDensity: VisualDensity.compact,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      thickness: 1,
      space: 1,
    ),
  );
}
