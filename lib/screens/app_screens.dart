import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pro HapticFeedback
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // Pro ImageFilter

// Importy našich modulů
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
import '../models/data_models.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const LivingBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Spacer(),
                  const PrayaLogo(size: 90).animate().scale(duration: 1000.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  Text("Drop of Hope. Shared by Humanity.", style: GoogleFonts.outfit(color: Colors.white54)),
                  const Spacer(),
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
                  const Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- 2. MAIN LAYOUT ---

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

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
          SafeArea(
            child: IndexedStack(index: state.navIndex, children: pages),
          ),
          Align(alignment: Alignment.bottomCenter, child: _buildAdvancedDock(context, state)),
          Positioned(
            bottom: 120, right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () => _showAuraChat(context),
              child: const Icon(Icons.auto_awesome, color: Colors.white).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: state.moodColor),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
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
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const PrayaLogo(size: 24), const Icon(Icons.notifications_none, color: Colors.white38)]), 
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
      child: GlassPanel(glow: item.isLiked, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 14, backgroundColor: Colors.white10, child: Text(item.author[0], style: const TextStyle(color: Colors.white, fontSize: 12))),
          const SizedBox(width: 10), Text(item.author, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 5), Text("• ${item.country}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const Spacer(), if (item.isLiked) const Icon(Icons.check, color: Colors.white, size: 16),
          const SizedBox(width: 10), GestureDetector(onTap: () => _showReportSheet(context, state, item.id), child: const Icon(Icons.more_horiz, size: 20, color: Colors.white38))
        ]),
        const SizedBox(height: 15),
        // Generative Art
        Center(child: Opacity(opacity: 0.7, child: SoulSignatureWidget(text: item.originalText, seedColor: item.artSeedColor))),
        const SizedBox(height: 15),
        AnimatedSwitcher(duration: 300.ms, child: Text(item.showTranslation ? item.translatedText : item.originalText, key: ValueKey<bool>(item.showTranslation), style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white70))),
        const SizedBox(height: 10),
        GestureDetector(onTap: () => state.toggleTranslation(item.id), child: Row(children: [Icon(Icons.translate, size: 14, color: state.moodColor), const SizedBox(width: 5), Text(item.showTranslation ? "Zobrazit originál" : "Zobrazit překlad", style: TextStyle(fontSize: 12, color: state.moodColor, fontWeight: FontWeight.bold))])),
        const SizedBox(height: 20), const Divider(color: Colors.white10), const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: Icon(item.isSaved ? Icons.bookmark : Icons.bookmark_border, color: item.isSaved ? state.moodColor : Colors.white54), onPressed: () { state.toggleSave(item.id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item.isSaved ? "Uloženo do Deníku" : "Odstraněno"))); }),
          IconButton(icon: const Icon(Icons.share, color: Colors.white54), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sdílení...")))),
          GestureDetector(onLongPress: () => state.dischargePrayer(item.id), child:  AnimatedContainer(duration: 500.ms, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(gradient: LinearGradient(colors: item.isLiked ? [state.moodColor, Colors.purple] : [Colors.white10, Colors.white10]), borderRadius: BorderRadius.circular(15)), child: Center(child: item.isLiked ? const Text("ODESLÁNO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)) : const Text("PODRŽET", style: TextStyle(fontSize: 10, color: Colors.white54)))))
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
        Expanded(child: GestureDetector(onTap: () => state.toggleJournalView(true), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: state.showJournal ? Colors.white10 : Colors.transparent, borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("Deník", style: TextStyle(color: Colors.white))))))
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
  
  void _showEditProfileDialog(BuildContext context, AppState state) {
    TextEditingController nameCtrl = TextEditingController(text: state.nickname); FaithType tempFaith = state.faith;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setState) { return AlertDialog(backgroundColor: const Color(0xFF101015), title: const Text("Upravit", style: TextStyle(color: Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Jméno", labelStyle: TextStyle(color: Colors.white54))), const SizedBox(height: 20), Wrap(spacing: 8, children: FaithType.values.map((f) { bool selected = tempFaith == f; return ChoiceChip(label: Text(f.toString().split('.').last.toUpperCase()), selected: selected, selectedColor: Colors.white, backgroundColor: Colors.black26, onSelected: (v) => setState(() => tempFaith = f)); }).toList())]), actions: [TextButton(onPressed: () { context.read<AppState>().login(nameCtrl.text, tempFaith); Navigator.pop(ctx); }, child: const Text("Uložit"))]); }));
  }
}

// C. CREATE SCREEN
class CreateScreen extends StatefulWidget { const CreateScreen({super.key}); @override State<CreateScreen> createState() => _CreateScreenState(); }
class _CreateScreenState extends State<CreateScreen> { double _stressVal = 5; final _ctrl = TextEditingController(); @override Widget build(BuildContext context) { return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.edit_note, size: 50, color: Colors.white54), const SizedBox(height: 20), Text("Vyslat Signál", style: GoogleFonts.cinzel(fontSize: 30, color: Colors.white)), const SizedBox(height: 40), GlassPanel(opacity: 0.1, child: TextField(controller: _ctrl, maxLines: 5, style: const TextStyle(color: Colors.white, fontSize: 18), decoration: const InputDecoration(hintText: "Co tě trápí? ...", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none))), const SizedBox(height: 30), const Text("Jakou tíhu cítíš?", style: TextStyle(color: Colors.white54)), Slider(value: _stressVal, min: 0, max: 10, divisions: 10, activeColor: const Color(0xFF6C63FF), onChanged: (v) => setState(() => _stressVal = v)), const SizedBox(height: 40), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { if (_ctrl.text.isNotEmpty) { context.read<AppState>().createPost(_ctrl.text, _stressVal); context.read<AppState>().setIndex(0); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signál odeslán."), backgroundColor: Color(0xFF6C63FF))); }}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("ODESLAT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))))])).animate().scale()); } }

// D. INSIGHTS SCREEN
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20), Text("Vhledy", style: GoogleFonts.cinzel(fontSize: 28)), 
        const SizedBox(height: 30), Center(child: GlassPanel(child: Column(children: [const Text("Globální Puls", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), const GlobalPulseRadar(), const SizedBox(height: 20), Text("Aktivních: 12,450", style: TextStyle(color: state.moodColor))]))), const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Efekt Modlitby", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), SizedBox(height: 150, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(7, (i) { return Column(mainAxisAlignment: MainAxisAlignment.end, children: [Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(width: 12, height: state.moodBefore[i] * 100, color: Colors.red.withValues(alpha: 0.5)), const SizedBox(width: 4), Container(width: 12, height: state.moodAfter[i] * 100, color: Colors.green)]), const SizedBox(height: 5), Text("D${i+1}", style: const TextStyle(fontSize: 10, color: Colors.white38))]); })))])),
        const SizedBox(height: 100),
      ]));
  }
}

// E. CHARITY SCREEN
class CharityScreen extends StatelessWidget { const CharityScreen({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [const SizedBox(height: 20), Text("Dopad", style: GoogleFonts.cinzel(fontSize: 28)), const SizedBox(height: 30), Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.4), blurRadius: 20)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Tvůj příspěvek", style: TextStyle(color: Colors.white70)), Text("${state.totalImpactMoney.toInt()} Kč", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))]), const Icon(Icons.volunteer_activism, size: 40, color: Colors.white)])), const SizedBox(height: 30), ...state.charityProjects.map((p) => Padding(padding: const EdgeInsets.only(bottom: 15), child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 15), LinearProgressIndicator(value: p.progress, backgroundColor: Colors.white10, color: p.color, minHeight: 8, borderRadius: BorderRadius.circular(5))])))), const SizedBox(height: 100)]).animate().slideX()); } }

// F. AURA MODAL
void _showAuraChat(BuildContext context) { showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) => const AuraModal()); }
class AuraModal extends StatelessWidget { const AuraModal({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(height: MediaQuery.of(context).size.height * 0.8, decoration: BoxDecoration(color: const Color(0xFF0A0A15).withValues(alpha: 0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(40)), border: Border.all(color: Colors.white10)), child: Column(children: [const SizedBox(height: 30), Icon(Icons.auto_awesome, size: 50, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(), const SizedBox(height: 20), Text("AURA AI", style: GoogleFonts.cinzel(fontSize: 24)), Expanded(child: ListView(padding: const EdgeInsets.all(30), children: state.chatHistory.map((msg) => Padding(padding: const EdgeInsets.only(bottom: 20), child: Text(msg, style: TextStyle(color: msg.startsWith("Ty") ? Colors.white : state.moodColor, fontSize: 16)))).toList())), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 30, right: 30), child: TextField(onSubmitted: (val) => context.read<AppState>().sendMessage(val), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Napiš...", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none))))]))); } }