import 'package:divide_time/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PositionVisualStyle {
  const PositionVisualStyle({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}

PositionVisualStyle positionVisualStyle(String position) {
  final normalized = position.toLowerCase();

  if (normalized.contains('fixo') || normalized.contains('zagueiro')) {
    return const PositionVisualStyle(
      foreground: Color(0xFF63B3FF),
      background: Color(0x1A63B3FF),
      border: Color(0x5063B3FF),
    );
  }

  if (normalized.contains('ala') ||
      normalized.contains('lateral') ||
      normalized.contains('meia') ||
      normalized.contains('volante')) {
    return const PositionVisualStyle(
      foreground: Color(0xFF39D98A),
      background: Color(0x1839D98A),
      border: Color(0x5039D98A),
    );
  }

  if (normalized.contains('pivo') ||
      normalized.contains('atacante') ||
      normalized.contains('ponta') ||
      normalized.contains('centroavante')) {
    return const PositionVisualStyle(
      foreground: Color(0xFFFF8A4C),
      background: Color(0x1AFF8A4C),
      border: Color(0x50FF8A4C),
    );
  }

  return const PositionVisualStyle(
    foreground: AppColors.primary,
    background: Color(0x1A22C55E),
    border: Color(0x5022C55E),
  );
}
