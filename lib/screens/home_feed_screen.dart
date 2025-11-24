import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // SMAŽ TENTO ŘÁDEK (je zbytečný)
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // Pro ImageFilter (pokud používáš GlassPanel přímo)
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
import '../models/data_models.dart';
import '../widgets/energy_button.dart'; // PŘIDEJ TENTO IMPORT!

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const PrayaLogo(size: 24), 
          GestureDetector(
            onTap: () => _showNotifications(context, state),
            child: Stack(alignment: Alignment.topRight, children: [
               const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.notifications_none, color: Colors.white38, size: 28)),
               if (state.notifications.isNotEmpty)
                 Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)))
            ]),
          )
        ]), 
        const SizedBox(height: 20), 
        
        // SOUL DASHBOARD
        GlassPanel(glow: true, onTap: () => state.setIndex(1), child: Column(children: [
              Row(children: [Icon(Icons.park, color: state.moodColor), const SizedBox(width: 10), Text(state.getLevelData(state.level).title.toUpperCase(), style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)), const Spacer(), Text("Level ${state.level}", style: TextStyle(color: state.moodColor))]),
              const SizedBox(height: 15), LinearProgressIndicator(value: state.levelProgress, backgroundColor: Colors.white10, color: state.moodColor, minHeight: 8, borderRadius: BorderRadius.circular(5)),
              const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${state.auraPoints} XP", style: const TextStyle(fontSize: 10, color: Colors.white54)), Text("Do dalšího: ${state.xpMissing} XP", style: TextStyle(fontSize: 10, color: state.moodColor))])
        ])),
        
        const SizedBox(height: 25),
        GlassPanel(child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Biofeedback", style: TextStyle(fontSize: 12, color: Colors.white54)), Icon(Icons.circle, size: 8, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale()]), const SizedBox(height: 10), SliderTheme(data: SliderThemeData(trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10), activeTrackColor: state.moodColor, thumbColor: Colors.white), child: Slider(value: state.currentStress, onChanged: (v) => state.updateStress(v)))]),), const SizedBox(height: 20), 
        if (state.visibleFeed.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text("Řeka je klidná...", style: TextStyle(color: Colors.white38))), 
        ...state.visibleFeed.map((item) => _buildEnhancedCard(context, item, state)), 
        const SizedBox(height: 100)
      ]).animate().fadeIn(),
    );
  }

Widget _buildEnhancedCard(BuildContext context, FeedItem item, AppState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GlassPanel(
        glow: item.isLiked,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HLAVIČKA (Autor, Země, Menu)
            Row(children: [
              CircleAvatar(radius: 14, backgroundColor: Colors.white10, child: Text(item.author[0], style: const TextStyle(color: Colors.white, fontSize: 12))),
              const SizedBox(width: 10),
              Text(item.author, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              Text("• ${item.country}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const Spacer(),
              if (item.isLiked) const Icon(Icons.check, color: Colors.white, size: 16),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showReportSheet(context, state, item.id),
                child: const Icon(Icons.more_horiz, size: 20, color: Colors.white38)
              )
            ]),

            const SizedBox(height: 15),

            // 2. GENERATIVNÍ UMĚNÍ (Soul Signature)
            Center(child: Opacity(opacity: 0.7, child: SoulSignatureWidget(text: item.originalText, seedColor: item.artSeedColor))),
            
            const SizedBox(height: 15),

            // 3. TEXT A PŘEKLAD
            AnimatedSwitcher(
              duration: 300.ms,
              child: Text(
                item.showTranslation ? item.translatedText : item.originalText,
                key: ValueKey<bool>(item.showTranslation),
                style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white70)
              )
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => state.toggleTranslation(item.id),
              child: Row(children: [
                Icon(Icons.translate, size: 14, color: state.moodColor),
                const SizedBox(width: 5),
                Text(item.showTranslation ? "Zobrazit originál" : "Zobrazit překlad", style: TextStyle(fontSize: 12, color: state.moodColor, fontWeight: FontWeight.bold))
              ])
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),

            // 4. AKČNÍ TLAČÍTKA (Zde je změna!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Záložka (Deník)
                IconButton(
                  icon: Icon(item.isSaved ? Icons.bookmark : Icons.bookmark_border, color: item.isSaved ? state.moodColor : Colors.white54),
                  onPressed: () { 
                    state.toggleSave(item.id); 
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item.isSaved ? "Uloženo do Deníku" : "Odstraněno"))); 
                  }
                ),
                // Sdílení
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white54),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sdílení...")))
                ),
                
                // --- NOVÉ ENERGY TLAČÍTKO (JUICY UX) ---
                EnergyButton(
                  color: state.moodColor,
                  isCompleted: item.isLiked,
                  onComplete: () => state.dischargePrayer(item.id),
                )
              ]
            )
          ]
        ),
      ),
    );
  }

  void _showReportSheet(BuildContext context, AppState state, String id) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF101015), builder: (ctx) => Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("Nahlásit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
      ListTile(leading: const Icon(Icons.warning, color: Colors.red), title: const Text("Nenávist", style: TextStyle(color: Colors.white)), onTap: () { state.reportPost(id); Navigator.pop(context); }),
      ListTile(leading: const Icon(Icons.block, color: Colors.orange), title: const Text("Spam", style: TextStyle(color: Colors.white)), onTap: () { state.reportPost(id); Navigator.pop(context); }),
    ])));
  }

  void _showNotifications(BuildContext context, AppState state) {
    state.markNotificationsAsRead();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: const Color(0xFF0A0A15).withValues(alpha: 0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Ozvěny", style: GoogleFonts.cinzel(fontSize: 24, color: Colors.white)), const Icon(Icons.notifications_active, color: Colors.white24)]), const SizedBox(height: 20), if (state.notifications.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text("Zatím žádné ozvěny...", style: TextStyle(color: Colors.white38))), Expanded(child: ListView.separated(itemCount: state.notifications.length, separatorBuilder: (ctx, i) => const Divider(color: Colors.white10), itemBuilder: (ctx, i) { final notif = state.notifications[i]; return ListTile(contentPadding: EdgeInsets.zero, leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: notif.color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(notif.icon, color: notif.color, size: 20)), title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), subtitle: Text(notif.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)), trailing: Text(notif.timeAgo, style: const TextStyle(color: Colors.white24, fontSize: 10))); }))]))));
  }
}