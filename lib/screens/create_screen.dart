import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  double _stressVal = 5;
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Zjistíme výšku klávesnice
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SizedBox.expand( // Roztáhnout na celou obrazovku
      child: SingleChildScrollView(
        // Povolíme scrollování, když klávesnice překryje obsah
        physics: const ClampingScrollPhysics(),
        child: Padding(
          // Přidáme padding dole, aby se obsah posunul nad klávesnici + rezerva
          padding: EdgeInsets.fromLTRB(25, 100, 25, bottomPadding + 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note, size: 50, color: Colors.white54),
              const SizedBox(height: 20),
              Text("Vyslat Signál", style: GoogleFonts.cinzel(fontSize: 30, color: Colors.white)),
              const SizedBox(height: 40),
              
              GlassPanel(
                opacity: 0.1,
                child: TextField(
                  controller: _ctrl,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  // Přidáme akci "Done" na klávesnici pro skrytí
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: "Co tě trápí? ...",
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              const Text("Jakou tíhu cítíš?", style: TextStyle(color: Colors.white54)),
              Slider(
                value: _stressVal,
                min: 0, max: 10, divisions: 10,
                activeColor: const Color(0xFF6C63FF),
                onChanged: (v) => setState(() => _stressVal = v)
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_ctrl.text.isNotEmpty) {
                      context.read<AppState>().createPost(_ctrl.text, _stressVal);
                      context.read<AppState>().setIndex(0);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signál odeslán."), backgroundColor: Color(0xFF6C63FF)));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text("ODESLAT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))
                ),
              )
            ],
          ),
        ),
      ),
    ).animate().scale();
  }
}