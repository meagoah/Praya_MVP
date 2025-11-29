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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  void _triggerEffect() {
    HapticFeedback.mediumImpact();
    _particles.clear();
    // Vytvoříme explozi
    for (int i = 0; i < 20; i++) {
      _particles.add(HeartParticle(
        x: 0, y: 0,
        angle: _rnd.nextDouble() * 2 * pi, // Do všech stran
        speed: 2.0 + _rnd.nextDouble() * 4.0, // Rychlost výbuchu
        rotation: _rnd.nextDouble() * 2 * pi, // Počáteční natočení
        rotSpeed: (_rnd.nextDouble() - 0.5) * 0.2, // Rychlost rotace
        size: 10.0 + _rnd.nextDouble() * 8.0, // Velikost
        color: widget.color,
        life: 1.0
      ));
    }
    _controller.forward(from: 0.0);
    widget.onTap();
    
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
      // Pohyb
      p.x += cos(p.angle) * p.speed;
      p.y += sin(p.angle) * p.speed;
      
      // Gravitace (aby padaly dolů jako konfety)
      p.y += 2.0; 
      
      // Rotace
      p.rotation += p.rotSpeed;
      
      // Zpomalení a mizení
      p.life -= 0.02;
      p.speed *= 0.9; 
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
            scale: Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.color),
                boxShadow: _controller.isAnimating ? [BoxShadow(color: widget.color.withValues(alpha: 0.6), blurRadius: 20)] : []
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, size: 14, color: widget.color),
                  const SizedBox(width: 6),
                  Text("PODPOŘIT", style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          // Částice
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
  double x, y, angle, speed, size, life, rotation, rotSpeed;
  Color color;
  HeartParticle({
    required this.x, required this.y, required this.angle, required this.speed, 
    required this.size, required this.color, required this.rotation, required this.rotSpeed,
    this.life = 1.0
  });
}

class HeartsPainter extends CustomPainter {
  final List<HeartParticle> particles;
  HeartsPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var p in particles) {
      if (p.life <= 0) continue;
      
      canvas.save();
      canvas.translate(center.dx + p.x, center.dy + p.y);
      canvas.rotate(p.rotation); // Rotace srdíčka
      
      final paint = Paint()..color = p.color.withValues(alpha: p.life);
      _drawPerfectHeart(canvas, p.size, paint);
      
      canvas.restore();
    }
  }

  // Kreslí hezké boubelaté srdce
  void _drawPerfectHeart(Canvas canvas, double scale, Paint paint) {
    Path path = Path();
    // Šířka a výška relativně k měřítku
    double width = scale;
    double height = scale;

    path.moveTo(0, height / 4);
    path.cubicTo(0, -height / 2, width / 1.4, -height / 2, width / 1.4, height / 4); // Pravý oblouk
    path.cubicTo(width / 1.4, height / 1.8, 0, height * 1.2, 0, height * 1.2); // Pravá špička dolů
    path.cubicTo(0, height * 1.2, -width / 1.4, height / 1.8, -width / 1.4, height / 4); // Levá špička nahoru
    path.cubicTo(-width / 1.4, -height / 2, 0, -height / 2, 0, height / 4); // Levý oblouk

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}