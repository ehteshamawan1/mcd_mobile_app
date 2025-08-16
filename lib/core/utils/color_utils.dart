import 'package:flutter/material.dart';

/// Utility class for color operations
class ColorUtils {
  /// Returns a color with the specified opacity
  /// Use this instead of the deprecated withOpacity method
  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }
}