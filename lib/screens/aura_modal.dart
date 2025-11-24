import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart'; // Potřebujeme pro SoulSignatureWidget

class AuraModal extends StatefulWidget {
  const AuraModal({super.key});

  @override
  State<AuraModal> createState() => _AuraModalState();
}

class _AuraModalState extends State<AuraModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<AppState>().sendMessage(text);
      _controller.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    // Získáme výšku klávesnice
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF05050A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(color: state.moodColor.withValues(alpha: 0.1), blurRadius: 50, spreadRadius: 5)
          ]
        ),
        child: Stack(
          children: [
            // 1. Ambientní pozadí
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
                
                // THE SACRED CORE (Dýchající Orb)
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: state.moodColor.withValues(alpha: 0.5), width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5))
                    ]
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .boxShadow(
                  duration: 4000.ms, 
                  curve: Curves.easeInOutSine,
                  begin: BoxShadow(color: state.moodColor.withValues(alpha: 0.0), blurRadius: 0, spreadRadius: 0),
                  end: BoxShadow(color: state.moodColor.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10),
                ),

                const SizedBox(height: 20),
                Text("AURA AI", style: GoogleFonts.cinzel(fontSize: 24, letterSpacing: 5, color: Colors.white)),
                Text("Průvodce tvou duší", style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
                
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),

                // Chat History
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(30),
                    itemCount: state.chatHistory.length,
                    itemBuilder: (ctx, i) {
                      final msg = state.chatHistory[i];
                      final isMe = msg.startsWith("Ty:");
                      final text = msg.replaceAll("Ty: ", "").replaceAll("Aura: ", "");
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isMe ? state.moodColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : const Radius.circular(20)
                              ),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05))
                            ),
                            child: Text(
                              text, 
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.white70, 
                                fontSize: 16,
                                height: 1.4
                              )
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // INPUT AREA (ZCELA NOVÝ DESIGN)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    bottom: keyboardHeight + 20, 
                    left: 15, 
                    right: 15, 
                    top: 15
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05050A), // Pozadí lišty (aby neprosvítal chat)
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end, // Zarovnání dolů, kdyby bylo pole víceřádkové
                    children: [
                      // Textové pole
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1))
                          ),
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: state.moodColor,
                            minLines: 1,
                            maxLines: 4, // Pole se může zvětšit
                            decoration: InputDecoration(
                              hintText: "Napiš zprávu...",
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // SAMOSTATNÉ TLAČÍTKO ODESLAT (Button)
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 50, 
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.moodColor, // Plná barva
                            boxShadow: [
                              BoxShadow(color: state.moodColor.withValues(alpha: 0.4), blurRadius: 10)
                            ]
                          ),
                          child: const Icon(Icons.arrow_upward, color: Colors.black, size: 24), // Černá šipka pro kontrast
                        ),
                      )
                    ],
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