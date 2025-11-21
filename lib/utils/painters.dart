import 'package:flutter/material.dart';
import 'dart:math';

class SoulSignaturePainter extends CustomPainter {
  final int seed;
  final Color color;
  SoulSignaturePainter(this.seed, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = color.withValues(alpha: 0.6);
    final rnd = Random(seed); 

    int points = rnd.nextInt(8) + 4; 
    double layers = rnd.nextInt(4) + 3.0; 
    bool isSharp = rnd.nextBool(); 
    
    for (int i = 0; i < layers; i++) {
      double radius = (i + 1) * (size.height / 2 / layers) * 0.8;
      paint.color = color.withValues(alpha: 1.0 - (i / layers));
      paint.strokeWidth = (layers - i) * 0.5;

      if (isSharp && i % 2 == 0) {
        Path path = Path();
        for (int j = 0; j < points * 2; j++) {
          double angle = (j * pi) / points;
          double r = (j % 2 == 0) ? radius : radius * 0.5;
          double x = center.dx + cos(angle) * r;
          double y = center.dy + sin(angle) * r;
          if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        if (rnd.nextBool()) {
           canvas.drawCircle(center, radius, paint);
        } else {
           for (int j = 0; j < points; j++) {
             double angle = (j * 2 * pi) / points;
             canvas.drawOval(Rect.fromCenter(center: center + Offset(cos(angle)*radius*0.5, sin(angle)*radius*0.5), width: radius/2, height: radius/2), paint);
           }
        }
      }
    }
    canvas.drawCircle(center, 3, Paint()..color = Colors.white..style = PaintingStyle.fill);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarPainter extends CustomPainter {
  final double progress; RadarPainter(this.progress);
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2); final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawCircle(center, 40, paint); canvas.drawCircle(center, 70, paint); canvas.drawCircle(center, 90, paint);
    final wavePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = Colors.cyanAccent.withValues(alpha: 1.0 - progress); canvas.drawCircle(center, progress * 90, wavePaint);
    final dotPaint = Paint()..style = PaintingStyle.fill..color = Colors.amber; final random = Random(42);
    for (int i = 0; i < 5; i++) { double angle = random.nextDouble() * 2 * pi + (progress * pi); double dist = 30 + random.nextDouble() * 50; canvas.drawCircle(center + Offset(cos(angle) * dist, sin(angle) * dist), 3, dotPaint); }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}