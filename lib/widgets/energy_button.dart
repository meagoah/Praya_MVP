import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

class EnergyButton extends StatefulWidget {
  final VoidCallback onComplete;
  final Color color;
  final bool isCompleted;

  const EnergyButton({
    super.key, 
    required this.onComplete, 
    required this.color,
    this.isCompleted = false
  });

  @override
  State<EnergyButton> createState() => _EnergyButtonState();
}

class _EnergyButtonState extends State<EnergyButton> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  final List<Particle> _particles = [];
  final Random _rnd = Random();
  Timer? _particleTimer;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // ZRYCHLENO: 800ms (bylo 1500ms). Rychlejší interakce.
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _explode();
        widget.onComplete();
        _reset();
      }
    });
  }

  void _spawnParticles() {
    // Častější spawn částic (30ms místo 50ms), aby to vypadalo hustě i při krátkém čase
    _particleTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_isPressed) return;
      setState(() {
        double angle = _rnd.nextDouble() * 2 * pi;
        double distance = 40.0 + _rnd.nextDouble() * 20;
        _particles.add(Particle(
          x: cos(angle) * distance,
          y: sin(angle) * distance,
          angle: angle,
          // Rychlejší pohyb částic, aby stihly doletět do středu
          speed: 3.0 + _rnd.nextDouble() * 3, 
          size: 2.0 + _rnd.nextDouble() * 3,
          color: widget.color.withValues(alpha: 0.6 + _rnd.nextDouble() * 0.4)
        ));
      });
    });
  }

  void _updateParticles() {
    if (_particles.isEmpty) return;
    for (var p in _particles) {
      p.x -= cos(p.angle) * p.speed;
      p.y -= sin(p.angle) * p.speed;
      p.life -= 0.05;
    }
    _particles.removeWhere((p) => p.life <= 0 || (p.x.abs() < 2 && p.y.abs() < 2));
  }

  void _explode() {
    HapticFeedback.heavyImpact();
  }

  void _reset() {
    _isPressed = false;
    _particleTimer?.cancel();
    _controller.reset();
    _particles.clear();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPressed) _updateParticles(); 

    return GestureDetector(
      onLongPressStart: (_) {
        if (widget.isCompleted) return;
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
        _controller.forward();
        _spawnParticles();
      },
      onLongPressEnd: (_) {
        if (_controller.status != AnimationStatus.completed) {
          _reset();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _pulseController]),
        builder: (context, child) {
          double progress = _controller.value;
          
          return CustomPaint(
            painter: ParticlePainter(_particles),
            child: Container(
              width: 140,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: widget.isCompleted 
                  ? LinearGradient(colors: [widget.color, Colors.purple]) 
                  : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1), 
                        Colors.white.withValues(alpha: 0.05 + (progress * 0.2)) 
                      ],
                    ),
                border: Border.all(
                  color: widget.isCompleted ? Colors.transparent : widget.color.withValues(alpha: 0.3 + (progress * 0.7)), 
                  width: 1 + (progress * 2)
                ),
                boxShadow: [
                  if (_isPressed || widget.isCompleted)
                    BoxShadow(
                      color: widget.color.withValues(alpha: widget.isCompleted ? 0.6 : progress * 0.5), 
                      blurRadius: widget.isCompleted ? 20 : 10 + (progress * 20),
                      spreadRadius: widget.isCompleted ? 2 : progress * 5
                    )
                ]
              ),
              child: Center(
                child: Text(
                  widget.isCompleted ? "ODESLÁNO" : (_isPressed ? "NABÍJENÍ..." : "PODRŽET"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1 + (progress * 2),
                    color: widget.isCompleted ? Colors.white : Colors.white70
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Particle {
  double x, y, angle, speed, size, life;
  Color color;
  Particle({required this.x, required this.y, required this.angle, required this.speed, required this.size, required this.color, this.life = 1.0});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0)); 
      canvas.drawCircle(center + Offset(p.x, p.y), p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}