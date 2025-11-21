import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
import '../models/data_models.dart';

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