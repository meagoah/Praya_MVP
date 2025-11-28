import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
import '../models/data_models.dart';

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