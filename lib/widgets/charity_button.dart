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
        rotation: _rnd.nextDouble() * 0.5 - 0.25, // Náhodná rotace srdíčka
        speed: 2.0 + _rnd.nextDouble() * 3.0,
        size: 10.0 + _rnd.nextDouble() * 8.0, // Větší, kulatější srdce
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
      p.x += cos(p.angle) * p.speed;
      p.y += sin(p.angle) * p.speed; 
      p.y -= 1.0; // Gravitace nahoru (vznášení)
      p.life -= 0.02; 
      p.speed *= 0.95; 
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
  double x, y, angle, rotation, speed, size, life;
  Color color;
  HeartParticle({required this.x, required this.y, required this.angle, required this.rotation, required this.speed, required this.size, required this.color, this.life = 1.0});
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
      // Posuneme se na pozici částice
      canvas.translate(center.dx + p.x, center.dy + p.y);
      // Otočíme ji (aby to vypadalo živě)
      canvas.rotate(p.rotation * (1.0 - p.life) * 5); 
      
      final paint = Paint()..color = p.color.withValues(alpha: p.life);
      _drawRoundHeart(canvas, p.size, paint);
      
      canvas.restore();
    }
  }

  // Vykreslí HEZKÉ KULATÉ SRDCE
  void _drawRoundHeart(Canvas canvas, double w, Paint paint) {
    Path path = Path();
    // Použijeme bezierovy křivky pro kulatý "emoji" tvar
    double width = w;
    double height = w;
    
    path.moveTo(0, height * 0.25);
    path.cubicTo(0, -height * 0.2, width * 0.5, -height * 0.2, width * 0.5, height * 0.25);
    path.cubicTo(width * 0.5, -height * 0.2, width, -height * 0.2, width, height * 0.25);
    path.cubicTo(width, height * 0.6, width * 0.5, height * 0.9, 0, height * 1.2); // Špička dole
    path.cubicTo(-width * 0.5, height * 0.9, -width, height * 0.6, -width, height * 0.25);
    
    // Posuneme, aby bylo vycentrované
    canvas.translate(0, -height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}