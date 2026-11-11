import 'package:flutter/material.dart';

/// 主题板选择：[ThemePalette.coral] 珊瑚橙（默认，匹配启动图标）；
/// 切回原靛蓝主题只需把 [activePalette] 改为 [ThemePalette.indigo]，
/// 组件层全部引用语义常量，无需改动。
enum ThemePalette { coral, indigo }

const ThemePalette activePalette = ThemePalette.coral;

abstract final class AppColors {
  // ---- 启用主题色（由 [activePalette] 选择）----
  static const Color primary =
      activePalette == ThemePalette.coral ? _Coral.primary : _Indigo.primary;
  static const Color primaryLight =
      activePalette == ThemePalette.coral ? _Coral.primaryLight : _Indigo.primaryLight;
  static const Color primaryDark =
      activePalette == ThemePalette.coral ? _Coral.primaryDark : _Indigo.primaryDark;
  static const Color onPrimary =
      activePalette == ThemePalette.coral ? _Coral.onPrimary : _Indigo.onPrimary;

  // ---- 中性色（两套主题共用）----
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnUserBubble = Color(0xFFFFFFFF);

  static const Color userBubble = primary;
  static const Color assistantBubble = surface;

  static const Color error = Color(0xFFDC2626);
  static const Color outline = border;
}

/// 珊瑚橙板（默认启用，匹配应用图标）。
abstract final class _Coral {
  static const Color primary = Color(0xFFEA580C); // orange-600
  static const Color primaryLight = Color(0xFFFB923C); // orange-400
  static const Color primaryDark = Color(0xFFC2410C); // orange-700
  static const Color onPrimary = Color(0xFFFFFFFF);
}

/// 靛蓝板（原主题，保留可切回）。
abstract final class _Indigo {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color onPrimary = Color(0xFFFFFFFF);
}
