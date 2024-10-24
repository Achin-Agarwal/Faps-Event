import 'package:flutter/material.dart';

class FireCursor extends StatefulWidget {
  final Widget child;

  const FireCursor({super.key, required this.child});

  @override
  State<FireCursor> createState() => _FireCursorState();
}

class _FireCursorState extends State<FireCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  List<Offset?> points = [];
  static const int maxPoints = 15;
  bool isTouching = false;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
          ..repeat();
    controller.addListener(() {
      setState(() {
        if (points.length > maxPoints) {
          points.removeRange(0, points.length - maxPoints);
        }
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addPoint(Offset offset) {
    setState(() {
      points.add(offset);
      if (points.length > maxPoints) {
        points.removeAt(0);
      }
    });
    isTouching = true;
  }

  void clearPoints() {
    setState(() {
      points.clear();
      isTouching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => addPoint(details.globalPosition),
      onPanEnd: (_) => clearPoints(),
      onPanCancel: () => clearPoints(),
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          CustomPaint(
            painter: FireCursorPainter(points),
          ),
        ],
      ),
    );
  }
}

class FireCursorPainter extends CustomPainter {
  final List<Offset?> points;

  FireCursorPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final offset = points[i];
      if (offset != null) {
        paint.color = const Color.fromARGB(255, 206, 27, 182)
            .withOpacity(1.0 - (i / points.length));
        canvas.drawCircle(offset, 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
