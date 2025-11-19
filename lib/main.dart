import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:ui';

// --- 1. DATA & STATE ---

class ChatMessage {
  final String text;
  final bool isMe;
  ChatMessage(this.text, this.isMe);
}

class AppState extends ChangeNotifier {
  int selectedIndex = 0;
  int userPoints = 1240;
  List<ChatMessage> auraMessages = [
    ChatMessage("Ahoj, jsem Aura. Cítím, že dnes je tvůj strom trochu neklidný. Chceš si promluvit?", false),
  ];
  
  // Mock Data pro Feed
  List<Map<String, dynamic>> feedItems = [
    {"author": "Maria (BR)", "text": "Prosím o zdraví pro mé děti.", "likes": 45},
    {"author": "John (US)", "text": "Děkuji za sílu v práci.", "likes": 12},
  ];

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void sendMessageToAura(String text) {
    auraMessages.add(ChatMessage(text, true));
    notifyListeners();
    // Fake AI response simulation
    Future.delayed(2000.ms, () {
      auraMessages.add(ChatMessage("Slyším tě. Tvá intence byla zaznamenána do Stromu života. Jak se cítíš teď?", false));
      notifyListeners();
    });
  }

  void createPost(String text) {
    feedItems.insert(0, {"author": "Ty (Právě teď)", "text": text, "likes": 0});
    userPoints += 10;
    notifyListeners();
  }
}

// --- 2. UI COMPONENTS ---

class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GlassCard({super.key, required this.child, this.opacity = 0.08, this.padding = const EdgeInsets.all(20), this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// --- 3. HLAVNÍ APLIKACE ---

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const PrayApp(),
    ),
  );
}

class PrayApp extends StatelessWidget {
  const PrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrayApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05050A),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF6C63FF), secondary: Color(0xFF00D2FF)),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    
    final List<Widget> pages = [
      const DashboardHome(),
      const JourneyScreen(),
      const CreateScreen(), // Prostřední obrazovka
      const InsightsScreen(),
      const CharityScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Pozadí
          Positioned(top: -100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.withValues(alpha: 0.15), boxShadow: [BoxShadow(blurRadius: 150, color: Colors.purple)]))),
          Positioned(bottom: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withValues(alpha: 0.15), boxShadow: [BoxShadow(blurRadius: 150, color: Colors.blue)]))),
          
          // Obsah
          SafeArea(child: pages[state.selectedIndex]),
        ],
      ),
      // Aura AI Button (Floating)
      floatingActionButton: state.selectedIndex != 2 ? FloatingActionButton(
        onPressed: () => _showAuraChat(context),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ).animate().scale(duration: 300.ms) : null,
      
      bottomNavigationBar: _buildNavBar(context, state),
    );
  }

  Widget _buildNavBar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.black.withValues(alpha: 0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view, 0, state),
          _navItem(Icons.park_outlined, 1, state),
          _centerNavItem(context, state), // CREATE BUTTON
          _navItem(Icons.bar_chart, 3, state),
          _navItem(Icons.volunteer_activism, 4, state),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, AppState state) {
    bool isSelected = state.selectedIndex == index;
    return GestureDetector(
      onTap: () => state.setIndex(index),
      child: Icon(icon, color: isSelected ? const Color(0xFF00D2FF) : Colors.white38, size: 26),
    );
  }

  Widget _centerNavItem(BuildContext context, AppState state) {
    return GestureDetector(
      onTap: () => state.setIndex(2),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF6C63FF)]),
          boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.4), blurRadius: 15)]
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

// --- 4. OBRAZOVKY ---

// A. DASHBOARD
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Řeka Naděje", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            Chip(label: Text("${state.userPoints} Aura"), backgroundColor: Colors.white10),
          ]),
          const SizedBox(height: 20),
          ...state.feedItems.map((item) => _prayerCard(item)).toList(),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _prayerCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
               CircleAvatar(child: Text(item['author'][0]), radius: 12, backgroundColor: Colors.white10),
               const SizedBox(width: 10),
               Text(item['author'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            ]),
            const SizedBox(height: 10),
            Text(item['text'], style: const TextStyle(fontSize: 16, height: 1.4)),
            const SizedBox(height: 15),
            Row(children: [
              const Icon(Icons.light_mode, size: 16, color: Colors.amber),
              const SizedBox(width: 5),
              Text("${item['likes']} svíček", style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ])
          ],
        ),
      ),
    );
  }
}

// B. CREATE SCREEN (Nový příspěvek)
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  double _stressValue = 5;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Vyslat Signál", style: GoogleFonts.cinzel(fontSize: 30, color: Colors.white)),
          const SizedBox(height: 30),
          
          GlassCard(
            child: TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Co ti leží na srdci? (Neboj se, jsme v tom spolu...)",
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Research Slider
          const Text("Jakou tíhu cítíš právě teď?", style: TextStyle(color: Colors.white54)),
          Slider(
            value: _stressValue,
            min: 0, max: 10, divisions: 10,
            activeColor: const Color(0xFF00D2FF),
            label: _stressValue.round().toString(),
            onChanged: (val) => setState(() => _stressValue = val),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
            Text("Klid", style: TextStyle(fontSize: 10, color: Colors.white30)),
            Text("Beznaděj", style: TextStyle(fontSize: 10, color: Colors.white30)),
          ]),
          
          const SizedBox(height: 40),
          
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context.read<AppState>().createPost(_controller.text);
                context.read<AppState>().setIndex(0); // Zpět na dashboard
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tvá modlitba byla vyslána do Řeky.")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("ODESLAT SIGNÁL", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ).animate().slideY(begin: 0.1, end: 0),
    );
  }
}

// C. AURA AI CHAT (Modal)
void _showAuraChat(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const AuraChatModal(),
  );
}

class AuraChatModal extends StatefulWidget {
  const AuraChatModal({super.key});
  @override
  State<AuraChatModal> createState() => _AuraChatModalState();
}

class _AuraChatModalState extends State<AuraChatModal> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF101018),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Row(children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF6C63FF)),
              const SizedBox(width: 10),
              Text("Aura AI Guide", style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          
          // Chat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.auraMessages.length,
              itemBuilder: (ctx, i) {
                final msg = state.auraMessages[i];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: msg.isMe ? const Color(0xFF6C63FF).withValues(alpha: 0.3) : Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(msg.text, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          
          // Input
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            color: Colors.black26,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Napiš zprávu...",
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () {
                    if (_textCtrl.text.isNotEmpty) {
                      context.read<AppState>().sendMessageToAura(_textCtrl.text);
                      _textCtrl.clear();
                    }
                  },
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}

// D. PLACEHOLDER SCREENS
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Icon(Icons.park, size: 100, color: Colors.white24));
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Icon(Icons.bar_chart, size: 100, color: Colors.white24));
}

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Icon(Icons.volunteer_activism, size: 100, color: Colors.white24));
}