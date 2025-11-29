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
    // Animace trvá 4 sekundy, aby se srdíčka mohla dlouho vznášet
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  void _triggerEffect() {
    HapticFeedback.mediumImpact();
    _particles.clear();
    
    // VÍC SRDÍČEK (30 ks) pro bohatší efekt
    for (int i = 0; i < 30; i++) {
      double angle = _rnd.nextDouble() * 2 * pi; // Do všech stran (360 stupňů)
      double speed = 2.0 + _rnd.nextDouble() * 6.0; // Vyšší počáteční rychlost (výbuch)
      
      _particles.add(HeartParticle(
        x: 0, y: 0,
        angle: angle,
        speed: speed,
        rotation: _rnd.nextDouble() * 2 * pi, 
        rotSpeed: (_rnd.nextDouble() - 0.5) * 0.1, // Pomalé otáčení
        size: 10.0 + _rnd.nextDouble() * 12.0, // Různé velikosti
        color: widget.color,
        life: 1.0,
        wobbleOffset: _rnd.nextDouble() * 100 // Náhodný posun pro kmitání
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
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      )
    );
  }

  void _updateParticles() {
    for (var p in _particles) {
      // 1. POHYB (Vybuchují do stran)
      p.x += cos(p.angle) * p.speed;
      p.y += sin(p.angle) * p.speed;
      
      // 2. ODPOR VZDUCHU (Rychlé zpomalení -> efekt vznášení)
      p.speed *= 0.92; 
      
      // 3. MIKRO-GRAVITACE (Padají jen velmi pomalu)
      p.y += 0.3; 

      // 4. HRAVOST (Jemné kmitání do stran jako listí)
      p.x += sin(p.life * 10 + p.wobbleOffset) * 0.2;
      
      // 5. ROTACE
      p.rotation += p.rotSpeed;
      
      // 6. MIZENÍ (Velmi pomalé)
      p.life -= 0.006; 
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
            scale: Tween<double>(begin: 1.0, end: 0.85).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn)), // Pružné stlačení
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
  double x, y, angle, speed, size, life, rotation, rotSpeed, wobbleOffset;
  Color color;
  HeartParticle({
    required this.x, required this.y, required this.angle, required this.speed, 
    required this.size, required this.color, required this.rotation, required this.rotSpeed,
    required this.wobbleOffset,
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
      canvas.rotate(p.rotation); 
      
      // Srdíčka zůstávají dlouho viditelná, mizí až na konci
      double opacity = p.life < 0.3 ? p.life * 3.3 : 1.0;
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      
      _drawPerfectHeart(canvas, p.size, paint);
      
      canvas.restore();
    }
  }

  void _drawPerfectHeart(Canvas canvas, double scale, Paint paint) {
    Path path = Path();
    double width = scale;
    double height = scale;

    path.moveTo(0, height / 4);
    path.cubicTo(0, -height / 2, width / 1.4, -height / 2, width / 1.4, height / 4);
    path.cubicTo(width / 1.4, height / 1.8, 0, height * 1.2, 0, height * 1.2);
    path.cubicTo(0, height * 1.2, -width / 1.4, height / 1.8, -width / 1.4, height / 4);
    path.cubicTo(-width / 1.4, -height / 2, 0, -height / 2, 0, height / 4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}