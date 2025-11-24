import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
import '../widgets/charity_button.dart'; // <--- Nový import

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20), 
        Text("Dopad", style: GoogleFonts.cinzel(fontSize: 28)), 
        const SizedBox(height: 30),
        
        // IMPACT WALLET
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.4), blurRadius: 20)]
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Tvůj generovaný dopad", style: TextStyle(color: Colors.white70)),
                // Animované číslo pro efekt růstu
                Text("${state.totalImpactMoney.toInt()} Kč", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)).animate(key: ValueKey(state.totalImpactMoney)).scale(duration: 200.ms, curve: Curves.elasticOut)
              ]), 
              const Icon(Icons.volunteer_activism, size: 40, color: Colors.white)
            ]),
            const SizedBox(height: 15),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.water_drop, size: 16, color: Colors.white), const SizedBox(width: 10), Text("= ${(state.totalImpactMoney / 30).toStringAsFixed(1)} dní pitné vody", style: const TextStyle(fontWeight: FontWeight.bold))]))
          ])
        ),
        
        const SizedBox(height: 30), 
        
        // PROJECTS LIST
        ...state.charityProjects.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
              
              // --- ZDE JE NOVÉ TLAČÍTKO ---
              CharityButton(
                color: p.color,
                onTap: () => state.allocateCharity(p.title),
              )
              // ----------------------------
            ]),
            const SizedBox(height: 5), 
            Text(p.description, style: const TextStyle(color: Colors.white54, fontSize: 12)), 
            const SizedBox(height: 15), 
            LinearProgressIndicator(value: p.progress, backgroundColor: Colors.white10, color: p.color, minHeight: 8, borderRadius: BorderRadius.circular(5)), 
            const SizedBox(height: 8), 
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${(p.progress * 100).toInt()}%", style: TextStyle(color: p.color, fontWeight: FontWeight.bold)), Text(p.raised, style: const TextStyle(color: Colors.white38, fontSize: 12))])
          ]))
        )),
        
        const SizedBox(height: 100)
      ]).animate().slideX(),
    );
  }
}