import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/app_state.dart';
import '../utils/painters.dart';

class LivingBackground extends StatelessWidget {
  const LivingBackground({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Stack(children: [
        Container(color: const Color(0xFF080810)), 
        AnimatedPositioned(duration: 3000.ms, top: state.currentStress * -30, left: -50, child: AnimatedContainer(duration: 2000.ms, width: 600, height: 600, decoration: BoxDecoration(shape: BoxShape.circle, color: state.moodColor.withValues(alpha: 0.08), boxShadow: [BoxShadow(color: state.moodColor.withValues(alpha: 0.15), blurRadius: 150)])).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 6000.ms)),
        Positioned(bottom: -150, right: -100, child: AnimatedContainer(duration: 2000.ms, width: 500, height: 500, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.withValues(alpha: 0.05), boxShadow: [BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.1), blurRadius: 180)])).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 7000.ms)),
        Opacity(opacity: 0.02, child: Container(decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://www.transparenttextures.com/patterns/stardust.png"), repeat: ImageRepeat.repeat)))),
    ]);
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool glow;
  final double opacity;
  const GlassPanel({super.key, required this.child, this.onTap, this.glow = false, this.opacity = 0.03});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return GestureDetector(onTap: onTap, child: ClipRRect(borderRadius: BorderRadius.circular(24), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: AnimatedContainer(duration: 500.ms, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: opacity), borderRadius: BorderRadius.circular(24), border: Border.all(color: glow ? state.moodColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)), boxShadow: glow ? [BoxShadow(color: state.moodColor.withValues(alpha: 0.1), blurRadius: 20)] : []), child: child))));
  }
}

class PrayaLogo extends StatelessWidget {
  final double size;
  const PrayaLogo({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(alignment: Alignment.center, children: [Icon(Icons.water_drop, size: size, color: state.moodColor.withValues(alpha: 0.8)).animate(onPlay: (c)=>c.repeat(reverse: true)).shimmer(duration: 3000.ms, color: Colors.white54), Icon(Icons.water_drop_outlined, size: size, color: Colors.white.withValues(alpha: 0.3))]),
        const SizedBox(height: 5), Text("PRAYA", style: GoogleFonts.cinzel(fontSize: size * 0.5, letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.white)),
    ]);
  }
}

class SoulSignatureWidget extends StatelessWidget {
  final String text;
  final Color seedColor;
  const SoulSignatureWidget({super.key, required this.text, required this.seedColor});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 120, width: double.infinity, child: CustomPaint(painter: SoulSignaturePainter(text.hashCode, seedColor)));
  }
}

class GlobalPulseRadar extends StatefulWidget {
  const GlobalPulseRadar({super.key});
  @override State<GlobalPulseRadar> createState() => _GlobalPulseRadarState();
}
class _GlobalPulseRadarState extends State<GlobalPulseRadar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { return SizedBox(height: 200, width: 200, child: AnimatedBuilder(animation: _controller, builder: (context, child) { return CustomPaint(painter: RadarPainter(_controller.value)); })); }
}