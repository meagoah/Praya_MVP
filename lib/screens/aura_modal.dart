import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart'; // Potřebujeme pro SoulSignatureWidget

class AuraModal extends StatelessWidget {
  const AuraModal({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF05050A).withValues(alpha: 0.95), // Temnější, hlubší pozadí
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(color: state.moodColor.withValues(alpha: 0.1), blurRadius: 50, spreadRadius: 5)
          ]
        ),
        child: Stack(
          children: [
            // 1. Ambientní pozadí (Soul Signature)
            Positioned.fill(
              child: Opacity(
                opacity: 0.05, 
                child: SoulSignatureWidget(text: "Aura AI Context", seedColor: state.moodColor)
              ),
            ),
            
            // 2. Obsah
            Column(
              children: [
                const SizedBox(height: 30),
                
                // THE SACRED CORE (Místo blikající ikony)
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: state.moodColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(color: state.moodColor.withValues(alpha: 0.2), blurRadius: 20)
                    ]
                  ),
                  child: Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.9), size: 30),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .boxShadow(
                  duration: 4000.ms, // Pomalý dech (4s)
                  begin: BoxShadow(color: state.moodColor.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 0),
                  end: BoxShadow(color: state.moodColor.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 15),
                ),

                const SizedBox(height: 20),
                Text("AURA AI", style: GoogleFonts.cinzel(fontSize: 24, letterSpacing: 5, color: Colors.white)),
                Text("Průvodce tvou duší", style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
                
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),

                // Chat History
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(25),
                    itemCount: state.chatHistory.length,
                    itemBuilder: (ctx, i) {
                      final msg = state.chatHistory[i];
                      final isMe = msg.startsWith("Ty:");
                      final text = msg.replaceFirst(isMe ? "Ty: " : "Aura: ", "");
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: isMe ? state.moodColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(color: isMe ? state.moodColor.withValues(alpha: 0.3) : Colors.white10),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(20)
                            )
                          ),
                          child: Text(
                            text, 
                            style: GoogleFonts.outfit(
                              color: isMe ? Colors.white : Colors.white70, 
                              fontSize: 16,
                              height: 1.4
                            )
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                      );
                    },
                  ),
                ),
                
                // Input Field
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 30, 
                    left: 25, 
                    right: 25, 
                    top: 20
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05050A),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))
                  ),
                  child: TextField(
                    onSubmitted: (val) => context.read<AppState>().sendMessage(val),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: state.moodColor,
                    decoration: InputDecoration(
                      hintText: "Napiš zprávu...",
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      filled: true, 
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: state.moodColor.withValues(alpha: 0.3))),
                      suffixIcon: Icon(Icons.send, color: state.moodColor.withValues(alpha: 0.5))
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}