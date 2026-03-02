import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.4,
              colors: [
                Color(0xFFB86AD9),
                Color(0xFF1E2A78),
                Color(0xFF0B1020),
              ],
            ),
          ),
        ),

        // Glow blobs
        const Positioned(
          left: -120,
          top: -120,
          child: _GlowBlob(color: Color(0xFF00D1FF), size: 260),
        ),
        const Positioned(
          right: -160,
          top: 60,
          child: _GlowBlob(color: Color(0xFFB86AD9), size: 320),
        ),
        const Positioned(
          left: 80,
          bottom: -180,
          child: _GlowBlob(color: Color(0xFF3EE6C5), size: 360),
        ),

        // ✅ DO NOT force Center here
        SafeArea(child: child),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.55),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}