import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CharityButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;

  const CharityButton({super.key, required this.onTap, required this.color});

  @override
  State<CharityButton> createState() => _CharityButtonState();
}

class _CharityButtonState extends State<CharityButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<HeartParticle> _particles = [];
  final Random _rnd = Random();
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  void _triggerEffect() {
    HapticFeedback.mediumImpact();
    _particles.clear();
    // Vytvoříme explozi srdíček
    for (int i = 0; i < 15; i++) {
      _particles.add(HeartParticle(
        x: 0, y: 0,
        angle: _rnd.nextDouble() * 2 * pi, // Do všech stran
        speed: 2.0 + _rnd.nextDouble() * 3.0,
        size: 8.0 + _rnd.nextDouble() * 6.0,
        color: widget.color,
        life: 1.0
      ));
    }
    _controller.forward(from: 0.0);
    
    // Zavoláme původní akci (přičtení peněz)
    widget.onTap();
    
    // Zobrazíme poděkování
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: const [
          Icon(Icons.favorite, color: Colors.white), 
          SizedBox(width: 10), 
          Text("Děkujeme! Tvá podpora mění svět.")
        ]),
        backgroundColor: widget.color,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      )
    );
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += cos(p.angle) * p.speed;
      p.y += sin(p.angle) * p.speed; // Letí do stran
      p.y -= 1.0; // A trochu nahoru (vznáší se)
      p.life -= 0.02; // Mizí
      p.speed *= 0.95; // Zpomalují
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerEffect,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Tlačítko
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.color),
                boxShadow: _controller.isAnimating ? [BoxShadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 15)] : []
              ),
              child: Text("PODPOŘIT", style: TextStyle(color: widget.color, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          
          // Částice (Srdíčka)
          if (_controller.isAnimating)
            Positioned.fill(
              child: CustomPaint(
                painter: HeartsPainter(_particles),
              ),
            ),
        ],
      ),
    );
  }
}

class HeartParticle {
  double x, y, angle, speed, size, life;
  Color color;
  HeartParticle({required this.x, required this.y, required this.angle, required this.speed, required this.size, required this.color, this.life = 1.0});
}

class HeartsPainter extends CustomPainter {
  final List<HeartParticle> particles;
  HeartsPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var p in particles) {
      if (p.life <= 0) continue;
      final paint = Paint()..color = p.color.withValues(alpha: p.life);
      _drawHeart(canvas, center + Offset(p.x, p.y), p.size, paint);
    }
  }

  // Vykreslí tvar srdce
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    Path path = Path();
    // Matematický tvar srdce
    path.moveTo(center.dx, center.dy + size / 4);
    path.cubicTo(center.dx - size, center.dy - size, center.dx - size * 1.5, center.dy, center.dx, center.dy + size);
    path.cubicTo(center.dx + size * 1.5, center.dy, center.dx + size, center.dy - size, center.dx, center.dy + size / 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}