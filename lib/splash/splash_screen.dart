import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mergeController;
  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

    _mergeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..forward();

    _logoController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _textController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    Future.delayed(const Duration(seconds: 3), () {
      _logoController.forward();
    });

    Future.delayed(const Duration(seconds: 4), () {
      _textController.forward();
    });

    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacementNamed(context, '/signin');
    });
  }

  @override
  void dispose() {
    _mergeController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🌿 MERGING COLOR LEAVES → LOGO
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _mergeController,
                  builder: (_, __) {
                    return CustomPaint(
                      size: const Size(120, 120),
                      painter: LeafMergePainter(_mergeController.value),
                    );
                  },
                ),

                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _logoController,
                    curve: Curves.elasticOut,
                  ),
                  child: FadeTransition(
                    opacity: _logoController,
                    child: Image.asset(
                      'assets/logo_icon.png',
                      width: 110,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 22),

            /// 📝 TEXT + TAGLINE
            FadeTransition(
              opacity: _textController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF2EC4B6),
                        Color(0xFF4CAF50),
                        Color(0xFFFF9800),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      "Thrive 360",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const RippleText(
                    text: "Turn Pressure into Power",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// 🌿 MERGING LEAF COLORS
////////////////////////////////////////////////////////

class LeafMergePainter extends CustomPainter {
  final double progress;

  LeafMergePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final paints = [
      Paint()..color = const Color(0xFF2EC4B6),
      Paint()..color = const Color(0xFF4CAF50),
      Paint()..color = const Color(0xFFFF9800),
    ];

    for (int i = 0; i < paints.length; i++) {
      final angle = (2 * pi / paints.length) * i + (2 * pi * progress);
      final distance = radius * (1 - progress);

      canvas.drawCircle(
        Offset(
          center.dx + cos(angle) * distance,
          center.dy + sin(angle) * distance,
        ),
        radius * 0.35,
        paints[i],
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

////////////////////////////////////////////////////////
/// 💧 RIPPLE TAGLINE
////////////////////////////////////////////////////////

class RippleText extends StatefulWidget {
  final String text;
  const RippleText({super.key, required this.text});

  @override
  State<RippleText> createState() => _RippleTextState();
}

class _RippleTextState extends State<RippleText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.6, end: 1.0).animate(_controller),
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }
}
