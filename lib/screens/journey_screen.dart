import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pro HapticFeedback
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Cesta Duše", style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white54),
                onPressed: () => _showEditProfileDialog(context, state),
                tooltip: "Upravit profil",
              )
            ],
          ),
          
          const SizedBox(height: 30),

          // PŘEPÍNAČ
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => state.toggleJournalView(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !state.showJournal ? Colors.white10 : Colors.transparent,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: const Center(child: Text("Mapa", style: TextStyle(color: Colors.white)))
                  )
                )
              ), 
              Expanded(
                child: GestureDetector(
                  onTap: () => state.toggleJournalView(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: state.showJournal ? Colors.white10 : Colors.transparent,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: const Center(child: Text("Můj Deník", style: TextStyle(color: Colors.white)))
                  )
                )
              )
            ]),
          ),
          
          const SizedBox(height: 30),

          if (!state.showJournal) ...[
            // --- MAP VIEW ---
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1)
                    ),
                  ),
                  Icon(Icons.park, size: 180, color: state.moodColor)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
                    .shimmer(duration: 3000.ms, color: Colors.white)
                ]
              )
            ),
            
            // Karta aktuálního levelu (S POPISEM)
            GlassPanel(
              glow: true,
              child: Column(
                children: [
                  Text("${state.nickname} • Level ${state.level}", style: GoogleFonts.outfit(color: Colors.white54)),
                  Text(currentLvl.title, style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: state.moodColor)),
                  const SizedBox(height: 10),
                  // ZDE JE TEN HLAVNÍ TEXT (LORE)
                  Text(currentLvl.subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.4)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 12, color: Colors.amber),
                        const SizedBox(width: 5),
                        Text("Odemčeno: ${currentLvl.perk}", style: const TextStyle(fontSize: 10, color: Colors.amber))
                      ],
                    )
                  )
                ]
              )
            ),
            
            const SizedBox(height: 30),
            Align(alignment: Alignment.centerLeft, child: Text("Hvězdná Mapa", style: GoogleFonts.cinzel(fontSize: 18))),
            const SizedBox(height: 20),
            
            // Mapa s popisky
            ...state.milestones.map((milestone) {
              var data = state.getLevelData(milestone);
              bool unlocked = state.level >= milestone;
              bool isCurrent = state.level == milestone;
              return Column(
                children: [
                  _ExpandableNode(
                    lvl: milestone,
                    title: data.title,
                    subtitle: data.subtitle, // Zde předáváme ten "Hint" text
                    description: data.detailedDescription, // A tady ten dlouhý popis
                    perk: data.perk,
                    unlocked: unlocked,
                    isCurrent: isCurrent,
                    color: state.moodColor
                  ),
                  if (milestone != 1)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      width: 2, height: 20,
                      color: unlocked ? Colors.white54 : Colors.white10
                    )
                ]
              );
            }),
            
            const SizedBox(height: 100)
            
          ] else ...[
            // --- JOURNAL VIEW ---
            if (state.savedPosts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text("Tvůj deník vděčnosti je prázdný.\nUlož si příspěvky z Řeky.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38))
              ),
              
            ...state.savedPosts.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Uloženo od: ${item.author}", style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    const SizedBox(height: 10),
                    Text(item.originalText, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)),
                    const Divider(color: Colors.white10, height: 30),
                    const Text("Tvá reflexe:", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    item.privateNotes.isEmpty 
                      ? GestureDetector(
                          onTap: () => _addNoteDialog(context, state, item.id),
                          child: const Text("+ Přidat poznámku", style: TextStyle(color: Colors.white38))
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: item.privateNotes.map((n) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(n, style: const TextStyle(color: Colors.white))
                          )).toList()
                        )
                  ]
                )
              )
            ))
          ],
          
          const SizedBox(height: 100),
        ],
      ).animate().scale(),
    );
  }

  void _addNoteDialog(BuildContext context, AppState state, String id) {
    TextEditingController ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101015),
        title: const Text("Reflexe", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Co tě na tom oslovilo?", hintStyle: TextStyle(color: Colors.white38))
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Zrušit")),
          TextButton(onPressed: () {
            if(ctrl.text.isNotEmpty) {
              state.addPrivateNote(id, ctrl.text);
              Navigator.pop(ctx);
            }
          }, child: const Text("Uložit"))
        ]
      )
    );
  }
  
  void _showEditProfileDialog(BuildContext context, AppState state) {
    TextEditingController nameCtrl = TextEditingController(text: state.nickname);
    FaithType tempFaith = state.faith;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF101015),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Upravit Profil", style: GoogleFonts.cinzel(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Jméno", labelStyle: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(height: 20),
                const Align(alignment: Alignment.centerLeft, child: Text("Změnit cestu (Víra):", style: TextStyle(color: Colors.white54, fontSize: 12))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: FaithType.values.map((f) {
                    bool selected = tempFaith == f;
                    return ChoiceChip(
                      label: Text(f.toString().split('.').last.toUpperCase()),
                      selected: selected,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.black26,
                      labelStyle: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 10),
                      onSelected: (v) => setState(() => tempFaith = f),
                    );
                  }).toList(),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Zrušit")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white),
                onPressed: () {
                  state.updateProfile(nameCtrl.text, tempFaith);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil byl aktualizován.")));
                },
                child: const Text("Uložit")
              )
            ],
          );
        }
      )
    );
  }
}

// --- EXPANDABLE NODE S TEXTEM ---
class _ExpandableNode extends StatefulWidget {
  final int lvl;
  final String title;
  final String subtitle; // TOTO JE TEN TEXT, CO CHCEŠ VIDĚT
  final String description;
  final String perk;
  final bool unlocked;
  final bool isCurrent;
  final Color color;

  const _ExpandableNode({required this.lvl, required this.title, required this.subtitle, required this.description, required this.perk, required this.unlocked, required this.isCurrent, required this.color});

  @override
  State<_ExpandableNode> createState() => _ExpandableNodeState();
}

class _ExpandableNodeState extends State<_ExpandableNode> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         setState(() => isExpanded = !isExpanded);
         HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white.withValues(alpha: 0.08) : (widget.unlocked ? Colors.white.withValues(alpha: 0.03) : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.isCurrent ? widget.color : (widget.unlocked ? Colors.white24 : Colors.white10)),
          boxShadow: widget.isCurrent ? [BoxShadow(color: widget.color.withValues(alpha: 0.2), blurRadius: 15)] : []
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HLAVIČKA
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: widget.unlocked ? widget.color : Colors.white10, shape: BoxShape.circle),
                  child: Icon(widget.unlocked ? (widget.isCurrent ? Icons.place : Icons.check) : Icons.lock, color: widget.unlocked ? Colors.white : Colors.white24, size: 20)
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: TextStyle(color: widget.unlocked ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 16)),
                      
                      // --- ZDE JE TEN VRÁCENÝ TEXT ---
                      if (widget.unlocked || widget.isCurrent)
                        Text(widget.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.2))
                      else 
                         Text("Lvl ${widget.lvl} - Zamčeno", style: const TextStyle(color: Colors.white24, fontSize: 10)),
                      // -------------------------------
                    ],
                  ),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white24, size: 16)
              ],
            ),
            
            // ROZBALOVACÍ OBSAH
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 10),
                  // Tady je detailní popis (Lore)
                  Text(widget.description, style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: widget.color),
                        const SizedBox(width: 10),
                        Expanded(child: Text("Odměna: ${widget.perk}", style: TextStyle(color: widget.color, fontSize: 12, fontWeight: FontWeight.bold)))
                      ],
                    ),
                  )
                ],
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: 300.ms,
            )
          ],
        ),
      ),
    );
  }
}