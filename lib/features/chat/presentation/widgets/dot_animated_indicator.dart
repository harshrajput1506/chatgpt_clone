import 'package:flutter/material.dart';

class DotAnimatedIndicator extends StatefulWidget {
  const DotAnimatedIndicator({super.key});

  @override
  State<DotAnimatedIndicator> createState() => _DotAnimatedIndicatorState();
}

class _DotAnimatedIndicatorState extends State<DotAnimatedIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Loop animation

    _radiusAnimation = Tween<double>(
      begin: 6,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      child: AnimatedBuilder(
        animation: _radiusAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: DotPainter(
              _radiusAnimation.value,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            size: const Size(60, 60),
          );
        },
      ),
    );
  }
}

class DotPainter extends CustomPainter {
  final double radius;
  final Color color;
  DotPainter(this.radius, {this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(covariant DotPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
