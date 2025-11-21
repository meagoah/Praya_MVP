import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math';

// --- 1. DATA MODELS ---

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
  bool isSaved;
  bool isHidden; 
  List<String> privateNotes;
  // NEW: Unikátní barva pro generativní umění
  Color artSeedColor; 

  FeedItem({
    required this.id, required this.author, required this.country, 
    required this.originalText, required this.translatedText, 
    this.likes = 0, this.isLiked = false, this.showTranslation = false,
    this.isSaved = false, this.isHidden = false,
    List<String>? privateNotes,
    Color? artSeedColor,
  }) : privateNotes = privateNotes ?? [], artSeedColor = artSeedColor ?? Colors.blue;
}

class CharityProject {
  String title;
  String description;
  double progress;
  String raised;
  Color color;
  CharityProject(this.title, this.description, this.progress, this.raised, this.color);
}

class LevelInfo {
  final String title;
  final String description;
  final String perk;
  LevelInfo(this.title, this.description, this.perk);
}

// --- 2. APP STATE ---

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  String nickname = "";
  FaithType faith = FaithType.universal;
  
  int navIndex = 0;
  int auraPoints = 2450;
  int level = 5; 
  double currentStress = 0.5; 
  bool showJournal = false;
  double totalImpactMoney = 450.0; 

  // INSIGHTS DATA
  final List<double> moodBefore = [0.8, 0.7, 0.9, 0.6, 0.8, 0.5, 0.7];
  final List<double> moodAfter = [0.4, 0.3, 0.5, 0.2, 0.4, 0.2, 0.3];
  final Map<String, double> emotionDistribution = {"Vděčnost": 0.45, "Prosba / Úzkost": 0.30, "Naděje": 0.15, "Smutek": 0.10};

  List<CharityProject> charityProjects = [
    CharityProject("Voda pro Afriku", "Výstavba studní v oblasti Sahelu.", 0.75, "750k / 1M Kč", Colors.cyan),
    CharityProject("Vzdělání dětí", "Školní pomůcky pro sirotčinec v Nepálu.", 0.40, "40k / 100k Kč", Colors.orange),
    CharityProject("Oprava Kapličky", "Záchrana kulturního dědictví v Sudetech.", 0.90, "90k / 100k Kč", Colors.green),
  ];

  List<FeedItem> feed = [
    FeedItem(id: "1", author: "Maria", country: "BR", originalText: "Meu filho tem cirurgia amanhã.", translatedText: "Můj syn má zítra operaci.", likes: 342, artSeedColor: Colors.orange),
    FeedItem(id: "2", author: "John", country: "US", originalText: "Praying for clarity.", translatedText: "Modlím se za jasnost.", likes: 890, artSeedColor: Colors.blue),
    FeedItem(id: "3", author: "Aisha", country: "AE", originalText: "نبحث عن النور", translatedText: "Hledáme světlo.", likes: 120, artSeedColor: Colors.purple),
  ];

  List<String> chatHistory = ["Aura: Vítám tě. Cítím z tebe dnes napětí. Jak ti mohu posloužit?"];

  Color get moodColor {
    Color base;
    switch (faith) {
      case FaithType.christian: base = const Color(0xFFFFC107); 
      case FaithType.muslim: base = const Color(0xFF4CAF50); 
      case FaithType.atheist: base = const Color(0xFF26A69A); 
      default: base = const Color(0xFF29B6F6); 
    }
    return Color.lerp(base, const Color(0xFFE57373), currentStress)!;
  }
  
  List<FeedItem> get savedPosts => feed.where((i) => i.isSaved && !i.isHidden).toList();
  List<FeedItem> get visibleFeed => feed.where((i) => !i.isHidden).toList();

  LevelInfo getLevelData(int targetLevel) {
    // Zkrácená logika pro MVP
    if (targetLevel <= 1) return LevelInfo("Poutník", "Začátek cesty.", "Feed");
    if (targetLevel <= 5) return LevelInfo("Hledač", "Hledáš pravdu.", "Art Gen");
    if (targetLevel <= 10) return LevelInfo("Strážce", "Chráníš světlo.", "Aura Voice");
    return LevelInfo("Světlonoš", "Záříš pro ostatní.", "Global Map");
  }
  
  List<int> get milestones => [50, 40, 30, 20, 15, 10, 5, 3, 2, 1];

  void login(String name, FaithType selectedFaith) { nickname = name; faith = selectedFaith; isLoggedIn = true; notifyListeners(); }
  void setIndex(int i) { navIndex = i; notifyListeners(); }
  void toggleJournalView(bool show) { showJournal = show; notifyListeners(); }
  void updateStress(double val) { currentStress = val; notifyListeners(); }
  void toggleTranslation(String id) { var item = feed.firstWhere((e) => e.id == id); item.showTranslation = !item.showTranslation; notifyListeners(); }
  void toggleSave(String id) { var item = feed.firstWhere((e) => e.id == id); item.isSaved = !item.isSaved; notifyListeners(); }
  void addPrivateNote(String id, String note) { var item = feed.firstWhere((e) => e.id == id); item.privateNotes.add(note); notifyListeners(); }
  void reportPost(String id) { var item = feed.firstWhere((e) => e.id == id); item.isHidden = true; notifyListeners(); }
  
  void createPost(String text, double stress) {
    // Generujeme "Art Color" na základě textu (hash)
    Color generatedColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withValues(alpha: 1.0);
    feed.insert(0, FeedItem(id: DateTime.now().toString(), author: nickname.isEmpty ? "Ty" : nickname, country: "CZ", originalText: text, translatedText: text, showTranslation: true, artSeedColor: generatedColor));
    auraPoints += 50; currentStress = stress; totalImpactMoney += 5; notifyListeners();
  }

  void dischargePrayer(String id) {
    var item = feed.firstWhere((e) => e.id == id); item.likes++; item.isLiked = true; auraPoints += 15; totalImpactMoney += 1; notifyListeners(); HapticFeedback.heavyImpact();
  }

  void sendMessage(String text) {
    chatHistory.add("Ty: $text"); notifyListeners(); Future.delayed(1500.ms, () { chatHistory.add("Aura: Rozumím. Tvá slova rezonují. Zpracovávám tvou emoci..."); notifyListeners(); });
  }
}

// --- 3. UI COMPONENTS ---

class LivingBackground extends StatelessWidget {
  const LivingBackground({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Stack(children: [
        Container(color: const Color(0xFF080810)), 
        AnimatedPositioned(duration: 3000.ms, top: state.currentStress * -30, left: -50, child: AnimatedContainer(duration: 2000.ms, width: 600, height: 600, decoration: BoxDecoration(shape: BoxShape.circle, color: state.moodColor.withValues(alpha: 0.08), boxShadow: [BoxShadow(color: state.moodColor.withValues(alpha: 0.15), blurRadius: 150)])).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 6000.ms)),
        Positioned(bottom: -150, right: -100, child: AnimatedContainer(duration: 2000.ms, width: 500, height: 500, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.withValues(alpha: 0.05), boxShadow: [BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.1), blurRadius: 180)])).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 7000.ms)),
        Opacity(opacity: 0.02, child: Container(decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://www.transparenttextures.com/patterns/stardust.png"), repeat: ImageRepeat.repeat)))),
    ]);
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
    return GestureDetector(onTap: onTap, child: ClipRRect(borderRadius: BorderRadius.circular(24), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: AnimatedContainer(duration: 500.ms, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: opacity), borderRadius: BorderRadius.circular(24), border: Border.all(color: glow ? state.moodColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)), boxShadow: glow ? [BoxShadow(color: state.moodColor.withValues(alpha: 0.1), blurRadius: 20)] : []), child: child))));
  }
}

class PrayaLogo extends StatelessWidget {
  final double size;
  const PrayaLogo({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(alignment: Alignment.center, children: [Icon(Icons.water_drop, size: size, color: state.moodColor.withValues(alpha: 0.8)).animate(onPlay: (c)=>c.repeat(reverse: true)).shimmer(duration: 3000.ms, color: Colors.white54), Icon(Icons.water_drop_outlined, size: size, color: Colors.white.withValues(alpha: 0.3))]),
        const SizedBox(height: 5), Text("PRAYA", style: GoogleFonts.cinzel(fontSize: size * 0.5, letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.white)),
    ]);
  }
}

// --- NEW: GENERATIVE PRAYER ART ---
class PrayerArtWidget extends StatelessWidget {
  final Color seedColor;
  const PrayerArtWidget({super.key, required this.seedColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: CustomPaint(
        painter: MandalaPainter(seedColor),
      ),
    );
  }
}

class MandalaPainter extends CustomPainter {
  final Color color;
  MandalaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = color.withValues(alpha: 0.5);
    
    // Generativní kruhy (Mandala)
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(center, (i + 1) * 8.0, paint);
    }
    // Paprsky
    for (int i = 0; i < 8; i++) {
      double angle = (i * pi) / 4;
      canvas.drawLine(
        center + Offset(cos(angle) * 10, sin(angle) * 10),
        center + Offset(cos(angle) * 40, sin(angle) * 40),
        paint..color = color.withValues(alpha: 0.3)
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- NEW: GLOBAL PULSE RADAR ---
class GlobalPulseRadar extends StatefulWidget {
  const GlobalPulseRadar({super.key});
  @override
  State<GlobalPulseRadar> createState() => _GlobalPulseRadarState();
}

class _GlobalPulseRadarState extends State<GlobalPulseRadar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: RadarPainter(_controller.value),
          );
        },
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;
  RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = Colors.white.withValues(alpha: 0.1);
    
    // Statické kruhy
    canvas.drawCircle(center, 40, paint);
    canvas.drawCircle(center, 70, paint);
    canvas.drawCircle(center, 90, paint);
    
    // Pulzující vlna
    final wavePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = Colors.cyanAccent.withValues(alpha: 1.0 - progress);
    canvas.drawCircle(center, progress * 90, wavePaint);

    // "Modlitby" (tečky)
    final dotPaint = Paint()..style = PaintingStyle.fill..color = Colors.amber;
    final random = Random(42); // Pevný seed pro stabilitu
    for (int i = 0; i < 5; i++) {
      double angle = random.nextDouble() * 2 * pi + (progress * pi); // Rotace
      double dist = 30 + random.nextDouble() * 50;
      canvas.drawCircle(center + Offset(cos(angle) * dist, sin(angle) * dist), 3, dotPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- 4. MAIN ENTRY ---

void main() { runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const PrayApp())); }
class PrayApp extends StatelessWidget { const PrayApp({super.key}); @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark().copyWith(textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)), home: const RootSwitcher()); } }
class RootSwitcher extends StatelessWidget { const RootSwitcher({super.key}); @override Widget build(BuildContext context) { var isLoggedIn = context.select<AppState, bool>((s) => s.isLoggedIn); return isLoggedIn ? const MainLayout() : const OnboardingScreen(); } }

// --- 5. SCREENS ---

// ONBOARDING
class OnboardingScreen extends StatefulWidget { const OnboardingScreen({super.key}); @override State<OnboardingScreen> createState() => _OnboardingScreenState(); }
class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController(); FaithType _selectedFaith = FaithType.universal;
  @override Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false, body: Stack(children: [const LivingBackground(), SafeArea(child: Padding(padding: const EdgeInsets.all(30.0), child: Column(children: [const Spacer(), const PrayaLogo(size: 90), const SizedBox(height: 20), Text("Drop of Hope. Shared by Humanity.", style: GoogleFonts.outfit(color: Colors.white54)), const Spacer(), GlassPanel(child: Column(children: [TextField(controller: _nameCtrl, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "Tvé jméno (Poutník)", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none)), const Divider(color: Colors.white10), const SizedBox(height: 10), const Text("Kde hledáš sílu?", style: TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(height: 10), Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: FaithType.values.map((f) { bool selected = _selectedFaith == f; return ChoiceChip(label: Text(f.toString().split('.').last.toUpperCase()), selected: selected, onSelected: (v) => setState(() => _selectedFaith = f), selectedColor: Colors.white, backgroundColor: Colors.black26, labelStyle: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 10)); }).toList())])), const SizedBox(height: 30), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { context.read<AppState>().login(_nameCtrl.text.isEmpty ? "Poutník" : _nameCtrl.text, _selectedFaith); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("VSTOUPIT DO ŘEKY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)))), const Spacer()]))) ]));
  }
}

// MAIN LAYOUT
class MainLayout extends StatelessWidget { const MainLayout({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return Scaffold(body: Stack(children: [const LivingBackground(), SafeArea(child: IndexedStack(index: state.navIndex, children: const [HomeFeedScreen(), JourneyScreen(), CreateScreen(), InsightsScreen(), CharityScreen()])), Align(alignment: Alignment.bottomCenter, child: _buildAdvancedDock(context, state)), Positioned(bottom: 120, right: 20, child: FloatingActionButton(backgroundColor: Colors.black, onPressed: () => _openAura(context), child: const Icon(Icons.auto_awesome, color: Colors.white).animate(onPlay: (c)=>c.repeat()).shimmer(duration: 2000.ms, color: state.moodColor)).animate().scale(duration: 400.ms, curve: Curves.elasticOut))])); }
  Widget _buildAdvancedDock(BuildContext context, AppState state) { return Container(margin: const EdgeInsets.only(bottom: 30, left: 15, right: 15), height: 75, decoration: BoxDecoration(color: const Color(0xFF0A0A12).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_dockItem(Icons.waves, 0, state), _dockItem(Icons.park_outlined, 1, state), GestureDetector(onTap: () { HapticFeedback.mediumImpact(); state.setIndex(2); }, child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [state.moodColor, Colors.purple]), boxShadow: [BoxShadow(color: state.moodColor.withValues(alpha: 0.4), blurRadius: 15)]), child: const Icon(Icons.add, color: Colors.white, size: 28))).animate(target: state.navIndex == 2 ? 1 : 0).scale(end: const Offset(1.1, 1.1)), _dockItem(Icons.pie_chart_outline, 3, state), _dockItem(Icons.volunteer_activism, 4, state)])); }
  Widget _dockItem(IconData icon, int index, AppState state) { bool active = state.navIndex == index; return GestureDetector(onTap: () { HapticFeedback.lightImpact(); state.setIndex(index); }, child: AnimatedContainer(duration: 300.ms, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: active ? Colors.white10 : Colors.transparent, shape: BoxShape.circle), child: Icon(icon, color: active ? state.moodColor : Colors.white38, size: 24))); }
}

// A. FEED SCREEN (WITH SOUL DASHBOARD)
class HomeFeedScreen extends StatelessWidget { const HomeFeedScreen({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const PrayaLogo(size: 24), Icon(Icons.notifications_none, color: Colors.white38)]), 
      const SizedBox(height: 20), 
      // SOUL DASHBOARD
      GlassPanel(glow: true, onTap: () => state.setIndex(1), child: Column(children: [
            Row(children: [Icon(Icons.park, color: state.moodColor), const SizedBox(width: 10), Text(state.getLevelData(state.level).title.toUpperCase(), style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)), const Spacer(), Text("Level ${state.level}", style: TextStyle(color: state.moodColor))]),
            const SizedBox(height: 15), LinearProgressIndicator(value: (state.auraPoints % 500) / 500, backgroundColor: Colors.white10, color: state.moodColor, minHeight: 8, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${state.auraPoints} XP", style: const TextStyle(fontSize: 10, color: Colors.white54)), Text("Do dalšího: ${(state.level * 500) - state.auraPoints} XP", style: TextStyle(fontSize: 10, color: state.moodColor))])
      ])),
      const SizedBox(height: 25),
      GlassPanel(child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Biofeedback", style: TextStyle(fontSize: 12, color: Colors.white54)), Icon(Icons.circle, size: 8, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale()]), const SizedBox(height: 10), SliderTheme(data: SliderThemeData(trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10), activeTrackColor: state.moodColor, thumbColor: Colors.white), child: Slider(value: state.currentStress, onChanged: (v) => state.updateStress(v)))]),), const SizedBox(height: 20), if (state.visibleFeed.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text("Řeka je klidná...", style: TextStyle(color: Colors.white38))), ...state.visibleFeed.map((item) => _buildEnhancedCard(context, item, state)), const SizedBox(height: 100)]).animate().fadeIn()); }
  
  Widget _buildEnhancedCard(BuildContext context, FeedItem item, AppState state) { return Padding(padding: const EdgeInsets.only(bottom: 15), child: GlassPanel(glow: item.isLiked, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 14, backgroundColor: Colors.white10, child: Text(item.author[0], style: const TextStyle(color: Colors.white, fontSize: 12))), const SizedBox(width: 10), Text(item.author, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 5), Text("• ${item.country}", style: const TextStyle(color: Colors.white38, fontSize: 12)), const Spacer(), if (item.isLiked) const Icon(Icons.check, color: Colors.white, size: 16), const SizedBox(width: 10), GestureDetector(onTap: () => _showReportSheet(context, state, item.id), child: const Icon(Icons.more_horiz, size: 20, color: Colors.white38))]), const SizedBox(height: 15), 
  // PRAYER ART INTEGRATION
  Center(child: Opacity(opacity: 0.6, child: PrayerArtWidget(seedColor: item.artSeedColor))),
  const SizedBox(height: 15),
  AnimatedSwitcher(duration: 300.ms, child: Text(item.showTranslation ? item.translatedText : item.originalText, key: ValueKey<bool>(item.showTranslation), style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white70))), const SizedBox(height: 10), GestureDetector(onTap: () => state.toggleTranslation(item.id), child: Row(children: [Icon(Icons.translate, size: 14, color: state.moodColor), const SizedBox(width: 5), Text(item.showTranslation ? "Zobrazit originál" : "Zobrazit překlad", style: TextStyle(fontSize: 12, color: state.moodColor, fontWeight: FontWeight.bold))])), const SizedBox(height: 20), const Divider(color: Colors.white10), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: Icon(item.isSaved ? Icons.bookmark : Icons.bookmark_border, color: item.isSaved ? state.moodColor : Colors.white54), onPressed: () { state.toggleSave(item.id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item.isSaved ? "Odstraněno z deníku" : "Uloženo do Deníku vděčnosti"))); }), IconButton(icon: const Icon(Icons.share, color: Colors.white54), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sdílení...")))), GestureDetector(onLongPress: () => state.dischargePrayer(item.id), child:  AnimatedContainer(duration: 500.ms, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(gradient: LinearGradient(colors: item.isLiked ? [state.moodColor, Colors.purple] : [Colors.white10, Colors.white10]), borderRadius: BorderRadius.circular(15)), child: Center(child: item.isLiked ? const Text("ODESLÁNO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)) : const Text("PODRŽET", style: TextStyle(fontSize: 10, color: Colors.white54)))))])]))); }
  void _showReportSheet(BuildContext context, AppState state, String id) { showModalBottomSheet(context: context, backgroundColor: const Color(0xFF101015), builder: (ctx) => Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Nahlásit příspěvek", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 20), ListTile(leading: const Icon(Icons.warning, color: Colors.red), title: const Text("Nenávistný projev", style: TextStyle(color: Colors.white)), onTap: () { state.reportPost(id); Navigator.pop(context); }), ListTile(leading: const Icon(Icons.block, color: Colors.orange), title: const Text("Spam nebo reklama", style: TextStyle(color: Colors.white)), onTap: () { state.reportPost(id); Navigator.pop(context); }), ListTile(leading: const Icon(Icons.sentiment_very_dissatisfied, color: Colors.blue), title: const Text("Negativní energie", style: TextStyle(color: Colors.white)), onTap: () { state.reportPost(id); Navigator.pop(context); })]))); }
}

// B. JOURNEY & JOURNAL
class JourneyScreen extends StatelessWidget { const JourneyScreen({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); LevelInfo currentLvl = state.getLevelData(state.level); return SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(children: [const SizedBox(height: 20), Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: Row(children: [Expanded(child: GestureDetector(onTap: () => state.toggleJournalView(false), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: !state.showJournal ? Colors.white10 : Colors.transparent, borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("Mapa Cesty", style: TextStyle(color: Colors.white)))))), Expanded(child: GestureDetector(onTap: () => state.toggleJournalView(true), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: state.showJournal ? Colors.white10 : Colors.transparent, borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("Můj Deník", style: TextStyle(color: Colors.white))))))])), const SizedBox(height: 30), if (!state.showJournal) ...[SizedBox(height: 300, child: Stack(alignment: Alignment.center, children: [Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1))), Icon(Icons.park, size: 180, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05)).shimmer(duration: 3000.ms, color: Colors.white)])), GlassPanel(glow: true, child: Column(children: [Text("Level ${state.level}", style: GoogleFonts.outfit(color: Colors.white54)), Text(currentLvl.title, style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: state.moodColor)), const SizedBox(height: 10), Text(currentLvl.description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 15), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.auto_awesome, size: 12, color: Colors.amber), const SizedBox(width: 5), Text("Odemčeno: ${currentLvl.perk}", style: const TextStyle(fontSize: 10, color: Colors.amber))]))])), const SizedBox(height: 30), Align(alignment: Alignment.centerLeft, child: Text("Hvězdná Mapa", style: GoogleFonts.cinzel(fontSize: 18))), const SizedBox(height: 20), ...state.milestones.map((milestone) { var data = state.getLevelData(milestone); bool unlocked = state.level >= milestone; bool isCurrent = state.level == milestone; return Column(children: [_buildNode(context, milestone, data.title, unlocked, isCurrent, state, data.perk), if (milestone != 1) _buildLine(active: unlocked)]); }), const SizedBox(height: 100)] else ...[if (state.savedPosts.isEmpty) const Padding(padding: EdgeInsets.only(top: 50), child: Text("Tvůj deník vděčnosti je prázdný.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38))), ...state.savedPosts.map((item) => Container(margin: const EdgeInsets.only(bottom: 15), child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Uloženo od: ${item.author}", style: const TextStyle(fontSize: 10, color: Colors.white54)), const SizedBox(height: 10), Text(item.originalText, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)), const Divider(color: Colors.white10, height: 30), const Text("Tvá reflexe:", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 5), item.privateNotes.isEmpty ? GestureDetector(onTap: () => _addNoteDialog(context, state, item.id), child: const Text("+ Přidat poznámku", style: TextStyle(color: Colors.white38))) : Column(children: item.privateNotes.map((n) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(n, style: const TextStyle(color: Colors.white)))).toList())]))))], const SizedBox(height: 100)]).animate().scale()); }
  Widget _buildNode(BuildContext context, int lvl, String title, bool unlocked, bool isCurrent, AppState state, String perk) { return GlassPanel(opacity: unlocked ? 0.08 : 0.02, child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: unlocked ? state.moodColor : Colors.white10, shape: BoxShape.circle, boxShadow: unlocked ? [BoxShadow(color: state.moodColor, blurRadius: 15)] : []), child: Icon(unlocked ? Icons.star : Icons.lock, color: unlocked ? Colors.white : Colors.white24, size: 20)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: unlocked ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 16)), Text("Level $lvl • Odměna: $perk", style: const TextStyle(color: Colors.white38, fontSize: 10)), if (isCurrent) Text("SOUČASNÁ ÚROVEŇ", style: TextStyle(color: state.moodColor, fontSize: 10, fontWeight: FontWeight.bold))]))])); }
  Widget _buildLine({bool active = false}) { return Container(margin: const EdgeInsets.symmetric(vertical: 5), width: 2, height: 20, color: active ? Colors.white54 : Colors.white10); }
  void _addNoteDialog(BuildContext context, AppState state, String id) { TextEditingController ctrl = TextEditingController(); showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF101015), title: const Text("Reflexe", style: TextStyle(color: Colors.white)), content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Co tě na tom oslovilo?", hintStyle: TextStyle(color: Colors.white38))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Zrušit")), TextButton(onPressed: () { if(ctrl.text.isNotEmpty) { state.addPrivateNote(id, ctrl.text); Navigator.pop(ctx); }}, child: const Text("Uložit"))])); }
}

// C. CREATE
class CreateScreen extends StatefulWidget { const CreateScreen({super.key}); @override State<CreateScreen> createState() => _CreateScreenState(); }
class _CreateScreenState extends State<CreateScreen> { double _stressVal = 5; final _ctrl = TextEditingController(); @override Widget build(BuildContext context) { return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.edit_note, size: 50, color: Colors.white54), const SizedBox(height: 20), Text("Vyslat Signál", style: GoogleFonts.cinzel(fontSize: 30, color: Colors.white)), const SizedBox(height: 40), GlassPanel(opacity: 0.1, child: TextField(controller: _ctrl, maxLines: 5, style: const TextStyle(color: Colors.white, fontSize: 18), decoration: const InputDecoration(hintText: "Co tě trápí? ...", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none))), const SizedBox(height: 30), const Text("Jakou tíhu cítíš?", style: TextStyle(color: Colors.white54)), Slider(value: _stressVal, min: 0, max: 10, divisions: 10, activeColor: const Color(0xFF6C63FF), onChanged: (v) => setState(() => _stressVal = v)), const SizedBox(height: 40), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { if (_ctrl.text.isNotEmpty) { context.read<AppState>().createPost(_ctrl.text, _stressVal); context.read<AppState>().setIndex(0); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signál odeslán. +50 Bodů."), backgroundColor: Color(0xFF6C63FF))); }}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("ODESLAT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))))])).animate().scale()); } }

// D. INSIGHTS (WITH GLOBAL PULSE RADAR)
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20), Text("Vhledy", style: GoogleFonts.cinzel(fontSize: 28)), 
        const Text("Analýza dopadu modlitby (Real-time data)", style: TextStyle(color: Colors.white54)), const SizedBox(height: 30),
        
        // GLOBAL PULSE RADAR (NEW!)
        Center(child: GlassPanel(child: Column(children: [
          const Text("Globální Puls", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const GlobalPulseRadar(), // The Mind-Blowing Part
          const SizedBox(height: 20),
          Text("Aktivních poutníků: 12,450", style: TextStyle(color: state.moodColor))
        ]))),
        
        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Efekt Modlitby (Před vs. Po)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 20),
          SizedBox(height: 150, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(7, (i) { return Column(mainAxisAlignment: MainAxisAlignment.end, children: [Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(width: 12, height: state.moodBefore[i] * 100, color: Colors.red.withValues(alpha: 0.5)), const SizedBox(width: 4), Container(width: 12, height: state.moodAfter[i] * 100, color: Colors.green)]), const SizedBox(height: 5), Text("D${i+1}", style: const TextStyle(fontSize: 10, color: Colors.white38))]); }))),
          const SizedBox(height: 15), const Row(children: [Icon(Icons.trending_down, color: Colors.green), SizedBox(width: 10), Text("Průměrný pokles napětí o 42%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])
        ])),
        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Psychologický Profil", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 15), ...state.emotionDistribution.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 12)), Text("${(e.value * 100).toInt()}%", style: TextStyle(color: state.moodColor))]), const SizedBox(height: 5), LinearProgressIndicator(value: e.value, backgroundColor: Colors.white10, color: state.moodColor, minHeight: 6, borderRadius: BorderRadius.circular(5))])))])),
        const SizedBox(height: 100),
      ]));
  }
}

// E. CHARITY
class CharityScreen extends StatelessWidget { const CharityScreen({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [const SizedBox(height: 20), Text("Dopad", style: GoogleFonts.cinzel(fontSize: 28)), const SizedBox(height: 30), Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.4), blurRadius: 20)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Tvůj příspěvek", style: TextStyle(color: Colors.white70)), Text("${state.totalImpactMoney.toInt()} Kč", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))]), const Icon(Icons.volunteer_activism, size: 40, color: Colors.white)])), const SizedBox(height: 30), ...state.charityProjects.map((p) => Padding(padding: const EdgeInsets.only(bottom: 15), child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 5), Text(p.description, style: const TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(height: 15), LinearProgressIndicator(value: p.progress, backgroundColor: Colors.white10, color: p.color, minHeight: 8, borderRadius: BorderRadius.circular(5)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${(p.progress * 100).toInt()}%", style: TextStyle(color: p.color, fontWeight: FontWeight.bold)), Text(p.raised, style: const TextStyle(color: Colors.white38, fontSize: 12))])])))), const SizedBox(height: 100)]).animate().slideX()); } }

// F. AURA MODAL
void _openAura(BuildContext context) { showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) => const AuraModal()); }
class AuraModal extends StatelessWidget { const AuraModal({super.key}); @override Widget build(BuildContext context) { var state = context.watch<AppState>(); return BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(height: MediaQuery.of(context).size.height * 0.8, decoration: BoxDecoration(color: const Color(0xFF0A0A15).withValues(alpha: 0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(40)), border: Border.all(color: Colors.white10)), child: Column(children: [const SizedBox(height: 30), Icon(Icons.auto_awesome, size: 50, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(), const SizedBox(height: 20), Text("AURA AI", style: GoogleFonts.cinzel(fontSize: 24)), Expanded(child: ListView(padding: const EdgeInsets.all(30), children: state.chatHistory.map((msg) => Padding(padding: const EdgeInsets.only(bottom: 20), child: Text(msg, style: TextStyle(color: msg.startsWith("Ty") ? Colors.white : state.moodColor, fontSize: 16)))).toList())), Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 30, right: 30), child: TextField(onSubmitted: (val) => context.read<AppState>().sendMessage(val), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Napiš...", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none))))]))); } }