import 'dart:ui';
import 'package:flutter/material.dart';

/// A soft, ambient "blurred blob" gradient background — the warm,
/// editorial look of overlapping soft-focus color washes, built from
/// the app's own brand palette (brass gold, clay terracotta, sage,
/// deep navy) instead of a flat card color.
///
/// Wrap a screen's `Scaffold.body` with this widget:
///
/// ```dart
/// Scaffold(
///   body: AppBackground(
///     child: SafeArea(child: ...),
///   ),
/// )
/// ```
class AppBackground extends StatelessWidget {
  final Widget child;

  /// Set true on screens that sit on the app's deep navy/brown surface
  /// (currently unused, reserved for future dark sections).
  final bool dark;

  const AppBackground({
    super.key,
    required this.child,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: dark ? const Color(0xFF1B2733) : const Color(0xFFFFFDF8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!dark) ...[
            // A handful of large, heavily-blurred color washes — this is
            // the whole trick: soft overlapping blobs read as one gentle
            // ambient gradient rather than distinct shapes.
            Positioned(
              top: -140,
              left: -100,
              child: _blob(const Color(0xFFF7D990), 340), // brass gold
            ),
            Positioned(
              top: -60,
              right: -120,
              child: _blob(const Color(0xFFE7A97D), 320), // warm clay
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: _blob(const Color(0xFF8FA178), 300), // sage green
            ),
            Positioned(
              bottom: -160,
              left: -100,
              child: _blob(const Color(0xFF9BB6C4), 280), // dusty sky blue
            ),
          ],
          child,
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.4),
        ),
      ),
    );
  }
}

