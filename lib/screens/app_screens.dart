import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pro HapticFeedback
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // Pro ImageFilter
import 'dart:math';

// Importy našich modulů
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
import '../models/data_models.dart';
import '../widgets/energy_button.dart';
import '../widgets/charity_button.dart';

// --- 1. ROOT & ONBOARDING ---

class RootSwitcher extends StatelessWidget {
  const RootSwitcher({super.key});
  @override
  Widget build(BuildContext context) {
    var isLoggedIn = context.select<AppState, bool>((s) => s.isLoggedIn);
    return isLoggedIn ? const MainLayout() : const OnboardingScreen();
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  FaithType _selectedFaith = FaithType.universal;

  @override
  Widget build(BuildContext context) {
    // Zde necháme resize true, aby klávesnice posunula tlačítko nahoru
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          const LivingBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PrayaLogo(size: 90).animate().scale(duration: 1000.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 20),
                    Text("Drop of Hope. Shared by Humanity.", style: GoogleFonts.outfit(color: Colors.white54), textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    GlassPanel(
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(hintText: "Tvé jméno (Poutník)", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none),
                          ),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 10),
                          const Text("Kde hledáš sílu?", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                            children: FaithType.values.map((f) {
                              bool selected = _selectedFaith == f;
                              return ChoiceChip(
                                label: Text(f.toString().split('.').last.toUpperCase()),
                                selected: selected,
                                onSelected: (v) => setState(() => _selectedFaith = f),
                                selectedColor: Colors.white,
                                backgroundColor: Colors.black26,
                                labelStyle: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 10),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AppState>().login(_nameCtrl.text.isEmpty ? "Poutník" : _nameCtrl.text, _selectedFaith);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: const Text("VSTOUPIT DO ŘEKY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- 2. MAIN LAYOUT (FIXED KEYBOARD) ---

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
      // DŮLEŽITÉ: False zabrání tomu, aby klávesnice "zmačkala" pozadí a vyrobila bílý pruh.
      // Jednotlivé obrazovky si musí padding řešit samy (jako to dělá CreateScreen).
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          const LivingBackground(),
          SafeArea(child: IndexedStack(index: state.navIndex, children: pages)),
          
          // Dock je vidět jen když není klávesnice (nebo ho necháme dole)
          Align(alignment: Alignment.bottomCenter, child: _buildAdvancedDock(context, state)),
          
          // Aura AI Orb
          Positioned(
            bottom: 120, right: 20,
            child: GestureDetector(
              onTap: () { HapticFeedback.mediumImpact(); _openAura(context); },
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .boxShadow(duration: 4000.ms, curve: Curves.easeInOutSine, begin: BoxShadow(color: state.moodColor.withValues(alpha: 0.0), blurRadius: 0, spreadRadius: 0), end: BoxShadow(color: state.moodColor.withValues(alpha: 0.6), blurRadius: 30, spreadRadius: 5)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAdvancedDock(BuildContext context, AppState state) {
    // Skryjeme dock, pokud je klávesnice otevřená, aby nezacláněl
    if (MediaQuery.of(context).viewInsets.bottom > 0) return const SizedBox.shrink();

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

// --- 3. SCREENS ---

// A. FEED SCREEN
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
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: GlassPanel(glow: item.isLiked, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [CircleAvatar(radius: 14, backgroundColor: Colors.white10, child: Text(item.author[0], style: const TextStyle(color: Colors.white, fontSize: 12))), const SizedBox(width: 10), Text(item.author, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 5), Text("• ${item.country}", style: const TextStyle(color: Colors.white38, fontSize: 12)), const Spacer(), if (item.isLiked) const Icon(Icons.check, color: Colors.white, size: 16), const SizedBox(width: 10), GestureDetector(onTap: () => _showReportSheet(context, state, item.id), child: const Icon(Icons.more_horiz, size: 20, color: Colors.white38))]), const SizedBox(height: 15), 
        Center(child: Opacity(opacity: 0.7, child: SoulSignatureWidget(text: item.originalText, seedColor: item.artSeedColor))), const SizedBox(height: 15),
        AnimatedSwitcher(duration: 300.ms, child: Text(item.showTranslation ? item.translatedText : item.originalText, key: ValueKey<bool>(item.showTranslation), style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white70))), const SizedBox(height: 10), GestureDetector(onTap: () => state.toggleTranslation(item.id), child: Row(children: [Icon(Icons.translate, size: 14, color: state.moodColor), const SizedBox(width: 5), Text(item.showTranslation ? "Zobrazit originál" : "Zobrazit překlad", style: TextStyle(fontSize: 12, color: state.moodColor, fontWeight: FontWeight.bold))])), const SizedBox(height: 20), const Divider(color: Colors.white10), const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: Icon(item.isSaved ? Icons.bookmark : Icons.bookmark_border, color: item.isSaved ? state.moodColor.withValues(alpha: 1.0) : Colors.white54), onPressed: () { state.toggleSave(item.id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item.isSaved ? "Uloženo do Deníku" : "Odstraněno"))); }),
          IconButton(icon: const Icon(Icons.share, color: Colors.white54), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sdílení...")))),
          EnergyButton(color: state.moodColor, isCompleted: item.isLiked, onComplete: () => state.dischargePrayer(item.id))
        ])
      ])),
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

// B. JOURNEY SCREEN
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    LevelInfo currentLvl = state.getLevelData(state.level);
    return SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(children: [
      const SizedBox(height: 20), 
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Cesta Duše", style: GoogleFonts.cinzel(fontSize: 28)), IconButton(icon: const Icon(Icons.settings, color: Colors.white54), onPressed: () => _showEditProfileDialog(context, state))]),
      const SizedBox(height: 30),
      Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: Row(children: [
        Expanded(child: GestureDetector(onTap: () => state.toggleJournalView(false), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: !state.showJournal ? Colors.white10 : Colors.transparent, borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("Mapa", style: TextStyle(color: Colors.white)))))), 
        Expanded(child: GestureDetector(onTap: () => state.toggleJournalView(true), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: state.showJournal ? Colors.white10 : Colors.transparent, borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("Můj Deník", style: TextStyle(color: Colors.white))))))
      ])),
      const SizedBox(height: 30),
      
      if (!state.showJournal) ...[
        SizedBox(height: 300, child: Stack(alignment: Alignment.center, children: [Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1))), Icon(Icons.park, size: 180, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05)).shimmer(duration: 3000.ms, color: Colors.white)])),
        GlassPanel(glow: true, child: Column(children: [
          Text("${state.nickname} • Level ${state.level}", style: GoogleFonts.outfit(color: Colors.white54)),
          Text(currentLvl.title, style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: state.moodColor)),
          const SizedBox(height: 10), Text(currentLvl.description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 15), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.auto_awesome, size: 12, color: Colors.amber), const SizedBox(width: 5), Text("Bonus: ${currentLvl.perk}", style: const TextStyle(fontSize: 10, color: Colors.amber))]))
        ])),
        const SizedBox(height: 30), Align(alignment: Alignment.centerLeft, child: Text("Hvězdná Mapa", style: GoogleFonts.cinzel(fontSize: 18))), const SizedBox(height: 20),
        ...state.milestones.map((milestone) { var data = state.getLevelData(milestone); bool unlocked = state.level >= milestone; bool isCurrent = state.level == milestone; return Column(children: [_buildNode(context, milestone, data.title, unlocked, isCurrent, state, data.perk), if (milestone != 1) _buildLine(active: unlocked)]); }), const SizedBox(height: 100)
      ] else ...[
        if (state.savedPosts.isEmpty) const Padding(padding: EdgeInsets.only(top: 50), child: Text("Prázdný deník.", style: TextStyle(color: Colors.white38))),
        ...state.savedPosts.map((item) => Container(margin: const EdgeInsets.only(bottom: 15), child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Od: ${item.author}", style: const TextStyle(fontSize: 10, color: Colors.white54)), const SizedBox(height: 10), Text(item.originalText, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)), const Divider(color: Colors.white10, height: 30), const Text("Reflexe:", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 5),
          item.privateNotes.isEmpty ? GestureDetector(onTap: () => _addNoteDialog(context, state, item.id), child: const Text("+ Přidat poznámku", style: TextStyle(color: Colors.white38))) : Column(children: item.privateNotes.map((n) => Text(n, style: const TextStyle(color: Colors.white))).toList())
        ]))))
      ],
      const SizedBox(height: 100),
    ]).animate().scale());
  }

  Widget _buildNode(BuildContext context, int lvl, String title, bool unlocked, bool isCurrent, AppState state, String perk) { return GlassPanel(opacity: unlocked ? 0.08 : 0.02, child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: unlocked ? state.moodColor : Colors.white10, shape: BoxShape.circle, boxShadow: unlocked ? [BoxShadow(color: state.moodColor, blurRadius: 15)] : []), child: Icon(unlocked ? Icons.star : Icons.lock, color: unlocked ? Colors.white : Colors.white24, size: 20)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: unlocked ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 16)), Text("Lvl $lvl: $perk", style: const TextStyle(color: Colors.white38, fontSize: 10)), if (isCurrent) Text("SOUČASNÁ", style: TextStyle(color: state.moodColor, fontSize: 10, fontWeight: FontWeight.bold))]))])); }
  Widget _buildLine({bool active = false}) { return Container(margin: const EdgeInsets.symmetric(vertical: 5), width: 2, height: 20, color: active ? Colors.white54 : Colors.white10); }
  void _addNoteDialog(BuildContext context, AppState state, String id) { TextEditingController ctrl = TextEditingController(); showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF101015), title: const Text("Reflexe", style: TextStyle(color: Colors.white)), content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Poznámka...", hintStyle: TextStyle(color: Colors.white38))), actions: [TextButton(onPressed: () { if(ctrl.text.isNotEmpty) { state.addPrivateNote(id, ctrl.text); Navigator.pop(ctx); }}, child: const Text("Uložit"))])); }
  void _showEditProfileDialog(BuildContext context, AppState state) { TextEditingController nameCtrl = TextEditingController(text: state.nickname); FaithType tempFaith = state.faith; showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setState) { return AlertDialog(backgroundColor: const Color(0xFF101015), title: const Text("Upravit", style: TextStyle(color: Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Jméno", labelStyle: TextStyle(color: Colors.white54))), const SizedBox(height: 20), Wrap(spacing: 8, children: FaithType.values.map((f) { bool selected = tempFaith == f; return ChoiceChip(label: Text(f.toString().split('.').last.toUpperCase()), selected: selected, selectedColor: Colors.white, backgroundColor: Colors.black26, onSelected: (v) => setState(() => tempFaith = f)); }).toList())]), actions: [TextButton(onPressed: () { context.read<AppState>().login(nameCtrl.text, tempFaith); Navigator.pop(ctx); }, child: const Text("Uložit"))]); })); }
}

// C. CREATE SCREEN (FIXED KEYBOARD PADDING)
class CreateScreen extends StatefulWidget { const CreateScreen({super.key}); @override State<CreateScreen> createState() => _CreateScreenState(); }
class _CreateScreenState extends State<CreateScreen> { double _stressVal = 5; final _ctrl = TextEditingController(); @override Widget build(BuildContext context) { 
  return Center(
    child: SingleChildScrollView(
      // TENTO PADDING ZAJISTÍ, ŽE SE FORMULÁŘ POSUNE NAD KLÁVESNICI
      padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 25),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.edit_note, size: 50, color: Colors.white54), const SizedBox(height: 20), 
          Text("Vyslat Signál", style: GoogleFonts.cinzel(fontSize: 30, color: Colors.white)), const SizedBox(height: 40), 
          GlassPanel(opacity: 0.1, child: TextField(controller: _ctrl, maxLines: 5, style: const TextStyle(color: Colors.white, fontSize: 18), decoration: const InputDecoration(hintText: "Co tě trápí? ...", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none))), 
          const SizedBox(height: 30), const Text("Jakou tíhu cítíš?", style: TextStyle(color: Colors.white54)), 
          Slider(value: _stressVal, min: 0, max: 10, divisions: 10, activeColor: const Color(0xFF6C63FF), onChanged: (v) => setState(() => _stressVal = v)), 
          const SizedBox(height: 40), 
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { if (_ctrl.text.isNotEmpty) { context.read<AppState>().createPost(_ctrl.text, _stressVal); context.read<AppState>().setIndex(0); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signál odeslán."), backgroundColor: Color(0xFF6C63FF))); }}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("ODESLAT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))))
      ])
    )
  ).animate().scale(); 
}}

// D. INSIGHTS SCREEN
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20), Text("Vhledy", style: GoogleFonts.cinzel(fontSize: 28)), 
        const Text("Analýza dopadu modlitby (Real-time data)", style: TextStyle(color: Colors.white54)), const SizedBox(height: 30),
        Center(child: GlassPanel(child: Column(children: [const Text("Globální Puls", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), const GlobalPulseRadar(), const SizedBox(height: 20), Text("Aktivních poutníků: 12,450", style: TextStyle(color: state.moodColor))]))),
        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Efekt Modlitby (Před vs. Po)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 20), SizedBox(height: 150, width: double.infinity, child: CustomPaint(painter: TrendChartPainter(state.weeklyTrends, state.moodColor))), const SizedBox(height: 15), Row(children: [Icon(Icons.circle, size: 8, color: state.moodColor), const SizedBox(width: 5), const Text("Aktivita", style: TextStyle(fontSize: 10, color: Colors.white54)), const SizedBox(width: 15), Container(width: 8, height: 8, color: Colors.blue.withValues(alpha: 0.5)), const SizedBox(width: 5), const Text("Pokles Stresu", style: TextStyle(fontSize: 10, color: Colors.white54))])])),
        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Mood Grid (30 dní)", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 15), Wrap(spacing: 5, runSpacing: 5, children: state.monthlyMoodMap.map((val) => Container(width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: Color.lerp(Colors.greenAccent, Colors.redAccent, val)!.withValues(alpha: 0.7)))).toList())])),
        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Psychologický Profil", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 15), ...state.emotionDistribution.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 12)), Text("${(e.value * 100).toInt()}%", style: TextStyle(color: state.moodColor))]), const SizedBox(height: 5), LinearProgressIndicator(value: e.value, backgroundColor: Colors.white10, color: state.moodColor, minHeight: 6, borderRadius: BorderRadius.circular(5))])))])),
        const SizedBox(height: 100),
      ]));
  }
}

class TrendChartPainter extends CustomPainter {
  final List<List<double>> data; final Color color;
  TrendChartPainter(this.data, this.color);
  @override void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke; final paintFill = Paint()..color = Colors.blue.withValues(alpha: 0.2)..style = PaintingStyle.fill; final pathLine = Path(); final pathFill = Path(); double step = size.width / (data.length - 1);
    pathFill.moveTo(0, size.height); for (int i = 0; i < data.length; i++) { double x = i * step; double yLine = size.height - (data[i][1] * size.height); double yFill = size.height - (data[i][0] * size.height * 0.8); if (i == 0) { pathLine.moveTo(x, yLine); pathFill.lineTo(x, yFill); } else { pathLine.lineTo(x, yLine); pathFill.lineTo(x, yFill); } } pathFill.lineTo(size.width, size.height); pathFill.close(); canvas.drawPath(pathFill, paintFill); canvas.drawPath(pathLine, paintLine);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// E. CHARITY SCREEN (S CHARITY BUTTONEM)
class CharityScreen extends StatelessWidget { const CharityScreen({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [const SizedBox(height: 20), Text("Dopad", style: GoogleFonts.cinzel(fontSize: 28)), const SizedBox(height: 30), 
        Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.4), blurRadius: 20)]), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Tvůj generovaný dopad", style: TextStyle(color: Colors.white70)), Text("${state.totalImpactMoney.toInt()} Kč", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))]), const Icon(Icons.volunteer_activism, size: 40, color: Colors.white)]),
            const SizedBox(height: 15), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.water_drop, size: 16, color: Colors.white), const SizedBox(width: 10), Text("= ${(state.totalImpactMoney / 30).toStringAsFixed(1)} dní pitné vody", style: const TextStyle(fontWeight: FontWeight.bold))]))
        ])),
        const SizedBox(height: 30), ...state.charityProjects.map((p) => Padding(padding: const EdgeInsets.only(bottom: 15), child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
            
            // --- POUŽITÍ CHARITY BUTTON ---
            CharityButton(color: p.color, onTap: () => state.allocateCharity(p.title))
            
            ]),
            const SizedBox(height: 5), Text(p.description, style: const TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(height: 15), LinearProgressIndicator(value: p.progress, backgroundColor: Colors.white10, color: p.color, minHeight: 8, borderRadius: BorderRadius.circular(5)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${(p.progress * 100).toInt()}%", style: TextStyle(color: p.color, fontWeight: FontWeight.bold)), Text(p.raised, style: const TextStyle(color: Colors.white38, fontSize: 12))])])))), const SizedBox(height: 100)]).animate().slideX()); } }

// F. AURA MODAL (FIXED ANIMATION)
class AuraModal extends StatelessWidget { const AuraModal({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(height: MediaQuery.of(context).size.height * 0.85, decoration: BoxDecoration(color: const Color(0xFF0A0A15).withValues(alpha: 0.95), borderRadius: const BorderRadius.vertical(top: Radius.circular(40)), border: Border.all(color: Colors.white.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: state.moodColor.withValues(alpha: 0.1), blurRadius: 50, spreadRadius: 5)]), child: Stack(children: [
      Positioned.fill(child: Opacity(opacity: 0.05, child: SoulSignatureWidget(text: "Aura AI Context", seedColor: state.moodColor))),
      Column(children: [const SizedBox(height: 30), Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black, border: Border.all(color: state.moodColor.withValues(alpha: 0.5), width: 1), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5))]), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30)).animate(onPlay: (c) => c.repeat(reverse: true)).boxShadow(duration: 4000.ms, curve: Curves.easeInOutSine, begin: BoxShadow(color: state.moodColor.withValues(alpha: 0.0), blurRadius: 0, spreadRadius: 0), end: BoxShadow(color: state.moodColor.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10)), const SizedBox(height: 20), Text("AURA AI", style: GoogleFonts.cinzel(fontSize: 24, letterSpacing: 5, color: Colors.white)), Text("Průvodce tvou duší", style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)), const SizedBox(height: 20), const Divider(color: Colors.white10), Expanded(child: ListView.builder(padding: const EdgeInsets.all(30), itemCount: state.chatHistory.length, itemBuilder: (ctx, i) { final msg = state.chatHistory[i]; final isMe = msg.startsWith("Ty:"); return Padding(padding: const EdgeInsets.only(bottom: 20), child: Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: isMe ? state.moodColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))), child: Text(msg.replaceAll("Ty: ", "").replaceAll("Aura: ", ""), style: TextStyle(color: isMe ? Colors.white : Colors.white70, fontSize: 16, height: 1.4))))); })), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 25, right: 25, top: 10), child: TextField(onSubmitted: (val) => context.read<AppState>().sendMessage(val), style: const TextStyle(color: Colors.white), cursorColor: state.moodColor, decoration: InputDecoration(hintText: "Napiš zprávu...", hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)), filled: true, fillColor: Colors.white.withValues(alpha: 0.05), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: state.moodColor.withValues(alpha: 0.3))), suffixIcon: Icon(Icons.send, color: state.moodColor.withValues(alpha: 0.5)))))])
    ])));
  }
}