import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

// --- 1. DATA MODELS & LOGIC ---

enum FaithType { universal, christian, muslim, atheist, spiritual }

class FeedItem {
  String id;
  String author;
  String country;
  String originalText;
  String translatedText;
  bool showTranslation;
  int likes;
  bool isLiked;
  
  FeedItem({
    required this.id, required this.author, required this.country, 
    required this.originalText, required this.translatedText, 
    this.likes = 0, this.isLiked = false, this.showTranslation = false
  });
}

class CharityProject {
  String title;
  String description;
  double progress; // 0.0 - 1.0
  String raised;
  Color color;
  CharityProject(this.title, this.description, this.progress, this.raised, this.color);
}

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  String nickname = "";
  FaithType faith = FaithType.universal;
  
  int navIndex = 0;
  int auraPoints = 2450;
  int level = 5; 
  double currentStress = 0.5; 
  
  // CHARITY DATA
  double totalImpactMoney = 450.0; // Tvoje vygenerovaná částka
  List<CharityProject> charityProjects = [
    CharityProject("Voda pro Afriku", "Výstavba studní v oblasti Sahelu.", 0.75, "750k / 1M Kč", Colors.cyan),
    CharityProject("Vzdělání dětí", "Školní pomůcky pro sirotčinec v Nepálu.", 0.40, "40k / 100k Kč", Colors.orange),
    CharityProject("Oprava Kapličky", "Záchrana kulturního dědictví v Sudetech.", 0.90, "90k / 100k Kč", Colors.green),
  ];

  // FEED DATA
  List<FeedItem> feed = [
    FeedItem(
      id: "1", author: "Maria", country: "BR", 
      originalText: "Meu filho tem cirurgia amanhã. Preciso sentir que não estou sozinha nisso.",
      translatedText: "Můj syn má zítra operaci. Potřebuji cítit, že v tom nejsem sama.",
      likes: 342
    ),
    FeedItem(
      id: "2", author: "John", country: "US", 
      originalText: "Praying for clarity in my career. The anxiety is overwhelming today.",
      translatedText: "Modlím se za jasnost v mé kariéře. Úzkost je dnes ohromující.",
      likes: 890
    ),
    FeedItem(
      id: "3", author: "Aisha", country: "AE", 
      originalText: "نبحث عن النور في الأوقات المظلمة",
      translatedText: "Hledáme světlo v temných časech.",
      likes: 120
    ),
  ];

  List<String> chatHistory = ["Aura: Vítám tě. Cítím z tebe dnes napětí. Jak ti mohu posloužit?"];

  Color get moodColor {
    Color base;
    switch (faith) {
      case FaithType.christian: base = Colors.amber; break;
      case FaithType.muslim: base = Colors.green; break;
      case FaithType.atheist: base = Colors.teal; break;
      default: base = const Color(0xFF00D2FF);
    }
    return Color.lerp(base, const Color(0xFFFF4B4B), currentStress)!;
  }

  void login(String name, FaithType selectedFaith) {
    nickname = name;
    faith = selectedFaith;
    isLoggedIn = true;
    notifyListeners();
  }

  void setIndex(int i) { navIndex = i; notifyListeners(); }
  void updateStress(double val) { currentStress = val; notifyListeners(); }

  void toggleTranslation(String id) {
    var item = feed.firstWhere((e) => e.id == id);
    item.showTranslation = !item.showTranslation;
    notifyListeners();
  }

  void createPost(String text, double stress) {
    feed.insert(0, FeedItem(
      id: DateTime.now().toString(), author: nickname.isEmpty ? "Ty" : nickname, country: "CZ",
      originalText: text, translatedText: text, showTranslation: true
    ));
    auraPoints += 50;
    currentStress = stress;
    totalImpactMoney += 5; // Příspěvek na charitu za aktivitu
    notifyListeners();
  }

  void dischargePrayer(String id) {
    var item = feed.firstWhere((e) => e.id == id);
    item.likes++; item.isLiked = true;
    auraPoints += 15; totalImpactMoney += 1;
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void sendMessage(String text) {
    chatHistory.add("Ty: $text"); notifyListeners();
    Future.delayed(1500.ms, () { chatHistory.add("Aura: Rozumím. Tvá slova rezonují. Zpracovávám tvou emoci..."); notifyListeners(); });
  }
}

// --- 2. UI COMPONENTS ---

class LivingBackground extends StatelessWidget {
  const LivingBackground({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Stack(
      children: [
        Container(color: const Color(0xFF05050A)),
        AnimatedPositioned(
          duration: 2000.ms, top: state.currentStress * -50, left: -100,
          child: AnimatedContainer(duration: 1000.ms, width: 500, height: 500, decoration: BoxDecoration(shape: BoxShape.circle, color: state.moodColor.withValues(alpha: 0.15), boxShadow: [BoxShadow(color: state.moodColor, blurRadius: 120 + (state.currentStress * 100))])).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 4000.ms),
        ),
        Positioned(bottom: -100, right: -100, child: AnimatedContainer(duration: 1000.ms, width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent.withValues(alpha: 0.1), boxShadow: [BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.2), blurRadius: 150)])).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.3, 1.3), duration: 5000.ms)),
        Opacity(opacity: 0.03, child: Container(decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://www.transparenttextures.com/patterns/stardust.png"), repeat: ImageRepeat.repeat)))),
      ],
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool glow;
  final double opacity;
  const GlassPanel({super.key, required this.child, this.onTap, this.glow = false, this.opacity = 0.03});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: 500.ms, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: opacity), borderRadius: BorderRadius.circular(24), border: Border.all(color: glow ? state.moodColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08)), boxShadow: glow ? [BoxShadow(color: state.moodColor.withValues(alpha: 0.2), blurRadius: 30)] : []),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PrayaLogo extends StatelessWidget {
  final double size;
  const PrayaLogo({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(alignment: Alignment.center, children: [
            Icon(Icons.water_drop, size: size, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).shimmer(duration: 2000.ms, color: Colors.white),
            Icon(Icons.water_drop_outlined, size: size, color: Colors.white.withValues(alpha: 0.5)),
          ]),
        const SizedBox(height: 5),
        Text("PRAYA", style: GoogleFonts.cinzel(fontSize: size * 0.5, letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.white)),
    ]);
  }
}

// --- 3. MAIN ENTRY ---

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const PrayApp()));
}

class PrayApp extends StatelessWidget {
  const PrayApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)),
      home: const RootSwitcher(),
    );
  }
}

class RootSwitcher extends StatelessWidget {
  const RootSwitcher({super.key});
  @override
  Widget build(BuildContext context) {
    var isLoggedIn = context.select<AppState, bool>((s) => s.isLoggedIn);
    return isLoggedIn ? const MainLayout() : const OnboardingScreen();
  }
}

// --- 4. ONBOARDING ---
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
              child: Column(children: [
                  const Spacer(),
                  const PrayaLogo(size: 90).animate().scale(duration: 1000.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  Text("Drop of Hope. Shared by Humanity.", style: GoogleFonts.outfit(color: Colors.white54)),
                  const Spacer(),
                  GlassPanel(child: Column(children: [
                      TextField(controller: _nameCtrl, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "Tvé jméno (Poutník)", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none)),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 10),
                      const Text("Kde hledáš sílu?", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: FaithType.values.map((f) {
                          bool selected = _selectedFaith == f;
                          return ChoiceChip(label: Text(f.toString().split('.').last.toUpperCase()), selected: selected, onSelected: (v) => setState(() => _selectedFaith = f), selectedColor: Colors.white, backgroundColor: Colors.black26, labelStyle: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 10));
                        }).toList())
                    ])),
                  const SizedBox(height: 30),
                  SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { context.read<AppState>().login(_nameCtrl.text.isEmpty ? "Poutník" : _nameCtrl.text, _selectedFaith); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("VSTOUPIT DO ŘEKY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)))),
                  const Spacer(),
              ]),
            ),
          )
        ],
      ),
    );
  }
}

// --- 5. MAIN LAYOUT (5 ITEMS) ---

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    // 5 Stránek: Feed, Journey, Create, Insights, Charity
    return Scaffold(
      body: Stack(
        children: [
          const LivingBackground(),
          SafeArea(
            child: IndexedStack(
              index: state.navIndex,
              children: const [HomeFeedScreen(), JourneyScreen(), CreateScreen(), InsightsScreen(), CharityScreen()],
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: _buildAdvancedDock(context, state)),
          Positioned(bottom: 120, right: 20, child: FloatingActionButton(backgroundColor: Colors.black, onPressed: () => _openAura(context), child: const Icon(Icons.auto_awesome, color: Colors.white).animate(onPlay: (c)=>c.repeat()).shimmer(duration: 2000.ms, color: state.moodColor)).animate().scale(duration: 400.ms, curve: Curves.elasticOut))
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
          
          // CREATE BUTTON (Central)
          GestureDetector(
            onTap: () { HapticFeedback.mediumImpact(); state.setIndex(2); },
            child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [state.moodColor, Colors.purple]), boxShadow: [BoxShadow(color: state.moodColor.withValues(alpha: 0.4), blurRadius: 15)]), child: const Icon(Icons.add, color: Colors.white, size: 28)),
          ).animate(target: state.navIndex == 2 ? 1 : 0).scale(end: const Offset(1.1, 1.1)),
          
          _dockItem(Icons.pie_chart_outline, 3, state),
          _dockItem(Icons.volunteer_activism, 4, state), // Charity is back!
        ],
      ),
    );
  }

  Widget _dockItem(IconData icon, int index, AppState state) {
    bool active = state.navIndex == index;
    return GestureDetector(onTap: () { HapticFeedback.lightImpact(); state.setIndex(index); }, child: AnimatedContainer(duration: 300.ms, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: active ? Colors.white10 : Colors.transparent, shape: BoxShape.circle), child: Icon(icon, color: active ? state.moodColor : Colors.white38, size: 24)));
  }
}

// --- 6. SCREENS ---

// A. FEED (Translated)
class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const PrayaLogo(size: 30),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text("${state.auraPoints} ✨", style: const TextStyle(fontWeight: FontWeight.bold)))
          ]),
          const SizedBox(height: 20),
          GlassPanel(child: Column(children: [
               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Vnitřní stav (Biofeedback)", style: TextStyle(fontSize: 12, color: Colors.white54)), Icon(Icons.circle, size: 8, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale()]),
               const SizedBox(height: 10),
               SliderTheme(data: SliderThemeData(trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10), activeTrackColor: state.moodColor, thumbColor: Colors.white), child: Slider(value: state.currentStress, onChanged: (v) => state.updateStress(v))),
            ])),
          const SizedBox(height: 20),
          ...state.feed.map((item) => _buildTranslatorCard(context, item, state)),
          const SizedBox(height: 100),
      ]).animate().fadeIn(),
    );
  }

  Widget _buildTranslatorCard(BuildContext context, FeedItem item, AppState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GlassPanel(
        glow: item.isLiked,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 14, backgroundColor: Colors.white10, child: Text(item.author[0], style: const TextStyle(color: Colors.white, fontSize: 12))),
            const SizedBox(width: 10),
            Text(item.author, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
            Text("• ${item.country}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const Spacer(),
            if (item.isLiked) const Icon(Icons.check, color: Colors.white, size: 16)
          ]),
          const SizedBox(height: 15),
          AnimatedSwitcher(duration: 300.ms, child: Text(item.showTranslation ? item.translatedText : item.originalText, key: ValueKey<bool>(item.showTranslation), style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white70))),
          const SizedBox(height: 10),
          GestureDetector(onTap: () => state.toggleTranslation(item.id), child: Row(children: [Icon(Icons.translate, size: 14, color: state.moodColor), const SizedBox(width: 5), Text(item.showTranslation ? "Zobrazit originál" : "Zobrazit překlad", style: TextStyle(fontSize: 12, color: state.moodColor, fontWeight: FontWeight.bold))])),
          const SizedBox(height: 20),
          GestureDetector(onLongPress: () => state.dischargePrayer(item.id), child:  AnimatedContainer(duration: 500.ms, width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(gradient: LinearGradient(colors: item.isLiked ? [state.moodColor, Colors.purple] : [Colors.white10, Colors.white10]), borderRadius: BorderRadius.circular(15)), child: Center(child: item.isLiked ? const Text("ENERGIE ODESLÁNA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white, fontSize: 12)) : const Text("PODRŽ PRO PODPORU", style: TextStyle(fontSize: 12, color: Colors.white54)))))
        ]),
      ),
    );
  }
}

// B. JOURNEY
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(children: [
        const SizedBox(height: 20),
        Text("Cesta Duše", style: GoogleFonts.cinzel(fontSize: 28)),
        const SizedBox(height: 30),
        SizedBox(height: 300, child: Stack(alignment: Alignment.center, children: [
          Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1))),
          Icon(Icons.park, size: 180, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05), duration: 3000.ms).shimmer(duration: 2000.ms, color: Colors.white),
        ])),
        Align(alignment: Alignment.centerLeft, child: Text("Hvězdná Mapa", style: GoogleFonts.cinzel(fontSize: 18))),
        const SizedBox(height: 20),
        _buildConstellationNode(context, 5, "Světlonoš", false, state),
        _buildPathLine(),
        _buildConstellationNode(context, 3, "Strážce", true, state),
        _buildPathLine(active: true),
        _buildConstellationNode(context, 1, "Poutník", true, state),
        const SizedBox(height: 100),
      ]).animate().scale(),
    );
  }
  Widget _buildConstellationNode(BuildContext context, int level, String title, bool unlocked, AppState state) {
    return Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: unlocked ? state.moodColor : Colors.white10, shape: BoxShape.circle, boxShadow: unlocked ? [BoxShadow(color: state.moodColor, blurRadius: 15)] : []), child: Icon(unlocked ? Icons.star : Icons.lock, color: unlocked ? Colors.white : Colors.white24, size: 20)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: unlocked ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 16)), if (unlocked && level == 3) Text("Současná úroveň (2450/3000 XP)", style: TextStyle(color: state.moodColor, fontSize: 10))])]);
  }
  Widget _buildPathLine({bool active = false}) { return Container(margin: const EdgeInsets.only(left: 19, top: 5, bottom: 5), width: 2, height: 30, color: active ? Colors.white54 : Colors.white10); }
}

// C. CREATE
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.edit_note, size: 50, color: Colors.white54),
            const SizedBox(height: 20),
            Text("Vyslat Signál", style: GoogleFonts.cinzel(fontSize: 30, color: Colors.white)),
            const SizedBox(height: 40),
            GlassPanel(opacity: 0.1, child: TextField(controller: _ctrl, maxLines: 5, style: const TextStyle(color: Colors.white, fontSize: 18), decoration: const InputDecoration(hintText: "Co tě trápí? ...", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none))),
            const SizedBox(height: 30),
            const Text("Jakou tíhu cítíš?", style: TextStyle(color: Colors.white54)),
            Slider(value: _stressVal, min: 0, max: 10, divisions: 10, activeColor: const Color(0xFF6C63FF), onChanged: (v) => setState(() => _stressVal = v)),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { if (_ctrl.text.isNotEmpty) { context.read<AppState>().createPost(_ctrl.text, _stressVal); context.read<AppState>().setIndex(0); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signál odeslán. +50 Bodů."), backgroundColor: Color(0xFF6C63FF))); }}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("ODESLAT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))))
        ]),
      ).animate().scale(),
    );
  }
}

// D. INSIGHTS (EXPANDED)
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Text("Vhledy", style: GoogleFonts.cinzel(fontSize: 28)),
        const Text("Komplexní spirituální analýza", style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 30),
        
        // Graph 1: Stress
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Pokles Stresu (7 dní)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: [0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.3].map((e) => Container(width: 20, height: e * 150, color: Color.lerp(Colors.green, Colors.red, e), margin: const EdgeInsets.symmetric(horizontal: 5))).toList()),
          const SizedBox(height: 10),
          const Text("Trend: -40% Stresu", style: TextStyle(color: Colors.green))
        ])),
        const SizedBox(height: 20),
        
        // Graph 2: Global Impact (Simulated Pie)
        GlassPanel(child: Row(children: [
          SizedBox(width: 100, height: 100, child: Stack(children: [
            const CircularProgressIndicator(value: 1, color: Colors.white10),
            const CircularProgressIndicator(value: 0.7, color: Colors.amber, strokeWidth: 8),
            Center(child: Text("70%", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
          ])),
          const SizedBox(width: 20),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Globální Cíl", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("1.4M Modliteb", style: TextStyle(fontSize: 20, color: Colors.white70)),
            Text("Spojené úsilí všech poutníků.", style: TextStyle(fontSize: 12, color: Colors.white38))
          ]))
        ])),
        const SizedBox(height: 100),
      ]),
    );
  }
}

// E. CHARITY (RESTORED & UPGRADED)
class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Text("Dopad", style: GoogleFonts.cinzel(fontSize: 28)),
        const SizedBox(height: 30),
        
        // IMPACT WALLET
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.4), blurRadius: 20)]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Tvůj příspěvek", style: TextStyle(color: Colors.white70)),
              Text("${state.totalImpactMoney.toInt()} Kč", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ]),
            const Icon(Icons.volunteer_activism, size: 40, color: Colors.white),
          ]),
        ),
        const SizedBox(height: 30),
        const Align(alignment: Alignment.centerLeft, child: Text("Aktivní Projekty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 15),
        ...state.charityProjects.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(p.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 15),
            LinearProgressIndicator(value: p.progress, backgroundColor: Colors.white10, color: p.color, minHeight: 8, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("${(p.progress * 100).toInt()}%", style: TextStyle(color: p.color, fontWeight: FontWeight.bold)),
              Text(p.raised, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ])
          ])),
        )),
        const SizedBox(height: 100),
      ]).animate().slideX(),
    );
  }
}

// F. AURA MODAL
void _openAura(BuildContext context) { showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) => const AuraModal()); }
class AuraModal extends StatelessWidget {
  const AuraModal({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(height: MediaQuery.of(context).size.height * 0.8, decoration: BoxDecoration(color: const Color(0xFF0A0A15).withValues(alpha: 0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(40)), border: Border.all(color: Colors.white10)), child: Column(children: [const SizedBox(height: 30), Icon(Icons.auto_awesome, size: 50, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(), const SizedBox(height: 20), Text("AURA AI", style: GoogleFonts.cinzel(fontSize: 24)), Expanded(child: ListView(padding: const EdgeInsets.all(30), children: state.chatHistory.map((msg) => Padding(padding: const EdgeInsets.only(bottom: 20), child: Text(msg, style: TextStyle(color: msg.startsWith("Ty") ? Colors.white : state.moodColor, fontSize: 16)))).toList())), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 30, right: 30), child: TextField(onSubmitted: (val) => context.read<AppState>().sendMessage(val), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Napiš...", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none))))])));
  }
}