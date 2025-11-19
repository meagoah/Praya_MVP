import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

// --- 1. STATE MANAGEMENT & DATA MODELS ---

// Enums pro víru a typ uživatele
enum FaithType { christian, muslim, atheist, spiritual, universal }

class UserProfile {
  String nickname;
  FaithType faith;
  bool isIncognito;
  int auraPoints;
  int treeLevel;
  double currentStressLevel; // 1-10 (Research data)

  UserProfile({
    this.nickname = "Poutník",
    this.faith = FaithType.spiritual,
    this.isIncognito = false,
    this.auraPoints = 0,
    this.treeLevel = 1,
    this.currentStressLevel = 5.0,
  });
}

// Hlavní Provider pro správu stavu aplikace
class AppState extends ChangeNotifier {
  UserProfile user = UserProfile();
  List<PrayerCardModel> prayers = [];

  // Nastavení "Skinu" aplikace podle víry
  ThemeData get currentTheme {
    Color primaryColor;
    switch (user.faith) {
      case FaithType.christian:
        primaryColor = Colors.amber;
        break; // Gold
      case FaithType.muslim:
        primaryColor = Colors.green;
        break; // Green
      case FaithType.atheist:
        primaryColor = Colors.teal;
        break; // Science Teal
      default:
        primaryColor = Colors.purpleAccent; // Spiritual
    }

    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0A0A12), // Deep space dark
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: Colors.white70,
        surface: const Color(0xFF151520),
      ),
      textTheme: GoogleFonts.ralewayTextTheme(ThemeData.dark().textTheme),
    );
  }

  // Terminologie podle víry (Dynamic Wording)
  String get termPrayer {
    switch (user.faith) {
      case FaithType.atheist:
        return "Myšlenka";
      case FaithType.muslim:
        return "Dua";
      case FaithType.christian:
        return "Modlitba";
      default:
        return "Intence";
    }
  }

  String get termAction {
    switch (user.faith) {
      case FaithType.atheist:
        return "Vyslat sílu";
      default:
        return "Zapálit svíčku";
    }
  }

  // Mock Data Generator
  void generateMockData() {
    prayers = [
      PrayerCardModel(
          author: "Maria, BR",
          content: "Prosím za uzdravení mé matky. Čekají nás těžké testy.",
          supporters: 124,
          countryCode: "BR"),
      PrayerCardModel(
          author: "Unknown Pilgrim",
          content: "Mám strach z budoucnosti. Potřebuji cítit klid.",
          supporters: 89,
          countryCode: "US",
          isAnonymous: true),
      PrayerCardModel(
          author: "David, CZ",
          content: "Díky za sílu zvládnout dnešní den. Cítím vděčnost.",
          supporters: 256,
          countryCode: "CZ",
          type: PrayerType.gratitude),
    ];
    notifyListeners();
  }

  // Akce: Zapálení svíčky (Gamifikace)
  void lightCandle(int index) {
    prayers[index].supporters++;
    prayers[index].isSupportedByMe = true;
    user.auraPoints += 5;
    _checkTreeGrowth();
    notifyListeners();
    HapticFeedback.mediumImpact(); // Fyzická odezva
  }

  // Logika růstu stromu
  void _checkTreeGrowth() {
    if (user.auraPoints > user.treeLevel * 50) {
      user.treeLevel++;
    }
  }

  // Uložení profilu
  void updateProfile(FaithType faith, bool incognito) {
    user.faith = faith;
    user.isIncognito = incognito;
    notifyListeners();
  }

  // Research Input
  void submitStressLevel(double value) {
    user.currentStressLevel = value;
    notifyListeners();
  }
}

enum PrayerType { request, gratitude }

class PrayerCardModel {
  final String author;
  final String content;
  int supporters;
  final String countryCode;
  final bool isAnonymous;
  final PrayerType type;
  bool isSupportedByMe;

  PrayerCardModel({
    required this.author,
    required this.content,
    required this.supporters,
    required this.countryCode,
    this.isAnonymous = false,
    this.type = PrayerType.request,
    this.isSupportedByMe = false,
  });
}

// --- 2. HLAVNÍ APLIKACE ---

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..generateMockData(),
      child: const PrayaApp(),
    ),
  );
}

class PrayaApp extends StatelessWidget {
  const PrayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return MaterialApp(
      title: 'Praya.app',
      debugShowCheckedModeBanner: false,
      theme: appState.currentTheme,
      home: const OnboardingScreen(), // Startovací bod
    );
  }
}

// --- 3. OBRAZOVKY (SCREENS) ---

// A. ONBOARDING (The Soul ID)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  FaithType selectedFaith = FaithType.spiritual;
  bool incognito = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 80, color: Colors.white70)
                  .animate()
                  .fadeIn(duration: 1000.ms),
              const SizedBox(height: 20),
              Text("PRAYA",
                  style: GoogleFonts.cinzel(
                      fontSize: 40, color: Colors.white, letterSpacing: 5)),
              Text("Connect Spirit. Measure Hope.",
                  style: GoogleFonts.raleway(color: Colors.white54)),
              const SizedBox(height: 60),

              Text("Odkud čerpáte sílu?",
                  style:
                      GoogleFonts.raleway(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: FaithType.values.map((faith) {
                  return ChoiceChip(
                    label: Text(_getFaithLabel(faith)),
                    selected: selectedFaith == faith,
                    onSelected: (selected) {
                      setState(() => selectedFaith = faith);
                    },
                    // Opraveno: withValues místo withOpacity
                    selectedColor:
                        Colors.purpleAccent.withValues(alpha: 0.5),
                    backgroundColor: Colors.black26,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
              SwitchListTile(
                title: const Text("Incognito Monk Mode",
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text("Vystupovat anonymně jako 'Poutník'",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                value: incognito,
                // Opraveno: activeTrackColor místo activeColor
                activeTrackColor: Colors.purpleAccent,
                onChanged: (val) => setState(() => incognito = val),
              ),

              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  context
                      .read<AppState>()
                      .updateProfile(selectedFaith, incognito);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()));
                },
                child: const Text("VSTOUPIT DO ŘEKY"),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getFaithLabel(FaithType f) {
    switch (f) {
      case FaithType.christian:
        return "Křesťanství";
      case FaithType.muslim:
        return "Islám";
      case FaithType.atheist:
        return "Věda / Ateista";
      case FaithType.spiritual:
        return "Spiritualita";
      case FaithType.universal:
        return "Univerzální";
    }
  }
}

// B. MAIN NAVIGATION
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final pages = [const FeedScreen(), const TreeProfileScreen()];

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0A12),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.white24,
        currentIndex: _index,
        onTap: (idx) => setState(() => _index = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.waves), label: "Řeka"),
          BottomNavigationBarItem(icon: Icon(Icons.park), label: "Můj Strom"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.auto_awesome), // Aura AI
        onPressed: () => _showAuraAIChat(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// C. FEED SCREEN (The River)
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A12),
        title: Text("Řeka Naděje",
            style: GoogleFonts.cinzel(color: Colors.white)),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddPrayerModal(context)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.prayers.length,
        itemBuilder: (ctx, i) {
          var prayer = state.prayers[i];
          return _buildPrayerCard(context, prayer, i, state);
        },
      ),
    );
  }

  Widget _buildPrayerCard(
      BuildContext context, PrayerCardModel prayer, int index, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF151520),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: prayer.isSupportedByMe
                  ? state.currentTheme.primaryColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1),
          boxShadow: [
            if (prayer.isSupportedByMe)
              BoxShadow(
                  color: state.currentTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 1)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white10,
                  child: Text(prayer.countryCode,
                      style: const TextStyle(fontSize: 10))),
              const SizedBox(width: 10),
              Text(prayer.isAnonymous ? "Tichý Poutník" : prayer.author,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.translate,
                  size: 16, color: Colors.white24) // AI Translation indicator
            ],
          ),
          const SizedBox(height: 15),
          Text(prayer.content,
              style: const TextStyle(
                  fontSize: 16, height: 1.5, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Interaction Button
              GestureDetector(
                onTap: () => state.lightCandle(index),
                child: AnimatedContainer(
                  duration: 300.ms,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: prayer.isSupportedByMe
                          ? state.currentTheme.primaryColor.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(Icons.light_mode,
                          size: 18,
                          color: prayer.isSupportedByMe
                              ? state.currentTheme.primaryColor
                              : Colors.white54),
                      const SizedBox(width: 8),
                      Text("${state.termAction} (${prayer.supporters})",
                          style: TextStyle(
                              color: prayer.isSupportedByMe
                                  ? state.currentTheme.primaryColor
                                  : Colors.white54,
                              fontSize: 12))
                    ],
                  ),
                ),
              ),
              // Donation Button (MVP Mock)
              const Icon(Icons.volunteer_activism,
                  size: 18, color: Colors.white24),
            ],
          )
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}

// D. PROFILE SCREEN (Tree of Life)
class TreeProfileScreen extends StatelessWidget {
  const TreeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Research Dashboard Widget
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Text("Váš Stress Level (Research)",
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Slider(
                    value: state.user.currentStressLevel,
                    min: 0, // DŮLEŽITÉ: Přidáno min
                    max: 10, // DŮLEŽITÉ: Přidáno max
                    divisions: 10,
                    activeColor: state.currentTheme.primaryColor,
                    onChanged: (val) => state.submitStressLevel(val),
                  ),
                  Text("Aktuální: ${state.user.currentStressLevel.toInt()}/10",
                      style: const TextStyle(color: Colors.white))
                ],
              ),
            ),
            const Spacer(),

            // THE TREE (Gamification Visualization)
            Icon(
              Icons.park, // Symbol stromu
              size: 100.0 + (state.user.treeLevel * 20),
              // Opraveno: withValues místo withOpacity
              color: state.currentTheme.primaryColor.withValues(
                  alpha: min(1.0, 0.5 + (state.user.auraPoints / 100))),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                // DŮLEŽITÁ OPRAVA: Místo .boxShadow (které padalo) používáme bezpečnější .shimmer
                .shimmer(duration: 2000.ms, color: Colors.white24)
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 3000.ms),

            const SizedBox(height: 20),
            Text("Strom Života (Level ${state.user.treeLevel})",
                style: GoogleFonts.cinzel(fontSize: 24, color: Colors.white)),
            Text("${state.user.auraPoints} Aura Bodů",
                style: const TextStyle(color: Colors.white54)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// E. MODALS & AI CHAT (Funkce)

void _showAddPrayerModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF151520),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Vyslat signál",
              style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
                hintText: "Co ti leží na srdci?",
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none),
            style: TextStyle(color: Colors.white),
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          // Pre-Research Slider
          const Text("Jak velkou tíhu cítíš (1-10)?",
              style: TextStyle(color: Colors.white54)),
          // OPRAVA: Slider má definované rozmezí
          const Slider(
            value: 7,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: null,
            activeColor: Colors.grey,
            inactiveColor: Colors.white10,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text("ODESLAT", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

void _showAuraAIChat(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black.withValues(alpha: 0.9),
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
            const SizedBox(width: 10),
            Text("Aura AI Guide",
                style: GoogleFonts.cinzel(color: Colors.white))
          ]),
          const Divider(color: Colors.white24),
          Expanded(
            child: ListView(
              children: [
                _buildChatBubble(
                    "Ahoj, jsem Aura. Vidím, že tvůj strom dnes trochu povadl. Cítíš se unaveně?",
                    false),
                _buildChatBubble("Ano, mám strach z práce.", true),
                _buildChatBubble(
                    "To je přirozené. Strach je jen stín, který ukazuje, že ti na tom záleží. Chceš, abychom spolu vytvořili krátkou intenci pro klid mysli?",
                    false),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Napiš zprávu...",
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    ),
  );
}

Widget _buildChatBubble(String text, bool isMe) {
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.blueAccent.withValues(alpha: 0.2)
            : Colors.purpleAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isMe ? const Radius.circular(20) : Radius.circular(0),
          bottomRight: isMe ? Radius.circular(0) : const Radius.circular(20),
        ),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    ),
  );
}