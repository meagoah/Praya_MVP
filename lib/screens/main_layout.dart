import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
// Import ostatních screenů
import 'home_feed_screen.dart';
import 'journey_screen.dart';
import 'create_screen.dart';
import 'insights_screen.dart';
import 'charity_screen.dart';
import 'aura_modal.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  void _openAura(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) => const AuraModal());
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    final List<Widget> pages = [
      const HomeFeedScreen(),
      const JourneyScreen(),
      const CreateScreen(),
      const InsightsScreen(),
      const CharityScreen()
    ];

    return Scaffold(
      body: Stack(
        children: [
          const LivingBackground(),
          SafeArea(child: IndexedStack(index: state.navIndex, children: pages)),
          Align(alignment: Alignment.bottomCenter, child: _buildAdvancedDock(context, state)),
          
          // --- AURA AI TLAČÍTKO (UPDATED) ---
          Positioned(
            bottom: 120, right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () => _openAura(context),
              // ZMĚNA ZDE: Místo .shimmer() používáme .scale() a .fade() pro efekt dýchání
              child: const Icon(Icons.auto_awesome, color: Colors.white)
                  .animate(onPlay: (c) => c.repeat(reverse: true)) // Opakuj tam a zpět (nádech/výdech)
                  .scale(duration: 3000.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2)) // Velmi pomalé zvětšení
                  .fade(duration: 3000.ms, begin: 0.7, end: 1.0), // Jemné zjasnění
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut), // Úvodní animace při startu
          )
        ],
      ),
    );
  }

  Widget _buildAdvancedDock(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30, left: 15, right: 15),
      height: 75,
      decoration: BoxDecoration(color: const Color(0xFF0A0A12).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _dockItem(Icons.waves, 0, state),
          _dockItem(Icons.park_outlined, 1, state),
          GestureDetector(
            onTap: () { HapticFeedback.mediumImpact(); state.setIndex(2); },
            child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [state.moodColor, Colors.purple]), boxShadow: [BoxShadow(color: state.moodColor.withValues(alpha: 0.4), blurRadius: 15)]), child: const Icon(Icons.add, color: Colors.white, size: 28)),
          ).animate(target: state.navIndex == 2 ? 1 : 0).scale(end: const Offset(1.1, 1.1)),
          _dockItem(Icons.pie_chart_outline, 3, state),
          _dockItem(Icons.volunteer_activism, 4, state),
        ],
      ),
    );
  }

  Widget _dockItem(IconData icon, int index, AppState state) {
    bool active = state.navIndex == index;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); state.setIndex(index); },
      child: AnimatedContainer(duration: 300.ms, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: active ? Colors.white10 : Colors.transparent, shape: BoxShape.circle), child: Icon(icon, color: active ? state.moodColor : Colors.white38, size: 24)),
    );
  }
}