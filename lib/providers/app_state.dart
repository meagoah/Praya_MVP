import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:math';
import '../models/data_models.dart';

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  String nickname = "";
  FaithType faith = FaithType.universal;
  
  int navIndex = 0;
  int auraPoints = 2450;
  int get level => (auraPoints / 500).floor() + 1;
  
  double currentStress = 0.5; 
  bool showJournal = false;
  double totalImpactMoney = 450.0; 

  // --- DATA PRO INSIGHTS ---
  final List<double> moodBefore = [0.8, 0.7, 0.9, 0.6, 0.8, 0.5, 0.7];
  final List<double> moodAfter = [0.4, 0.3, 0.5, 0.2, 0.4, 0.2, 0.3];
  final Map<String, double> emotionDistribution = {"Vděčnost": 0.45, "Prosba / Úzkost": 0.30, "Naděje": 0.15, "Smutek": 0.10};
  final List<List<double>> weeklyTrends = [[0.8, 0.2], [0.7, 0.3], [0.9, 0.1], [0.6, 0.6], [0.4, 0.8], [0.3, 0.9], [0.2, 0.8]];
  final List<double> monthlyMoodMap = List.generate(30, (index) => (sin(index * 0.5) + 1) / 2 * 0.8 + 0.1);

  // --- CHARITA ---
  List<CharityProject> charityProjects = [
    CharityProject("Voda pro Afriku", "Výstavba studní v oblasti Sahelu.", 0.75, "750k / 1M Kč", Colors.cyan),
    CharityProject("Vzdělání dětí", "Školní pomůcky pro sirotčinec v Nepálu.", 0.40, "40k / 100k Kč", Colors.orange),
    CharityProject("Oprava Kapličky", "Záchrana kulturního dědictví v Sudetech.", 0.90, "90k / 100k Kč", Colors.green),
  ];

  // --- FEED ---
  List<FeedItem> feed = [
    FeedItem(id: "1", author: "Maria", country: "BR", originalText: "Meu filho tem cirurgia amanhã.", translatedText: "Můj syn má zítra operaci.", likes: 342, artSeedColor: Colors.orangeAccent),
    FeedItem(id: "2", author: "John", country: "US", originalText: "Praying for clarity.", translatedText: "Modlím se za jasnost.", likes: 890, artSeedColor: Colors.cyanAccent),
    FeedItem(id: "3", author: "Aisha", country: "AE", originalText: "نبحث عن النور", translatedText: "Hledáme světlo.", likes: 120, artSeedColor: Colors.purpleAccent),
  ];

  List<String> chatHistory = ["Aura: Vítám tě. Cítím z tebe dnes napětí. Jak ti mohu posloužit?"];

  // --- NOTIFIKACE ---
  List<AppNotification> notifications = [
    AppNotification(title: "Svíčka zapálena", subtitle: "Maria z Brazílie podpořila tvou modlitbu.", icon: Icons.light_mode, color: Colors.amber, timeAgo: "2m"),
    AppNotification(title: "Nový Level!", subtitle: "Dosáhl jsi úrovně Hledač.", icon: Icons.arrow_upward, color: Colors.cyan, timeAgo: "1h"),
  ];
  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;
  void markNotificationsAsRead() { for (var n in notifications) { n.isRead = true; } notifyListeners(); }

  // --- DENNÍ CITÁTY ---
  final Map<FaithType, String> _dailyQuotes = {
    FaithType.christian: "Všechno mohu v Kristu, který mi dává sílu. (Filipským 4:13)",
    FaithType.muslim: "Bůh nezatíží duši nad její možnosti. (Korán 2:286)",
    FaithType.atheist: "Vesmír je změna; náš život je takový, jaký ho dělají naše myšlenky. (Marcus Aurelius)",
    FaithType.spiritual: "To, co hledáš, hledá tebe. (Rumi)",
    FaithType.universal: "Láska je mostem mezi tebou a vším ostatním. (Rumi)",
  };
  
  String get currentQuote => _dailyQuotes[faith] ?? _dailyQuotes[FaithType.universal]!;

  // Funkce pro zeptání se Aury (přidá do chatu)
  void askAuraAboutQuote(String quote) {
    chatHistory.add("Ty: Zaujal mě tento text: \"$quote\". Co mi k němu můžeš říct?");
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1000), () {
      chatHistory.add("Aura: To je hluboká myšlenka. Tento text nám připomíná, že naše vnitřní síla často pramení z propojení s něčím větším. Jak to rezonuje s tvou dnešní situací?");
      notifyListeners();
    });
  }
  
  // --- NOVÁ FUNKCE: ULOŽENÍ CITÁTU DO DENÍKU ---
  void saveQuoteAsJournalEntry(String quote) {
    // Vytvoříme "falešný" FeedItem, který reprezentuje uložený citát
    var newItem = FeedItem(
      id: "quote_${DateTime.now().millisecondsSinceEpoch}",
      author: "Moudrost dne",
      country: "World",
      originalText: quote,
      translatedText: quote,
      showTranslation: true,
      isSaved: true, // <--- Důležité: Rovnou uloženo
      artSeedColor: Colors.amber
    );
    
    // Přidáme ho na začátek feedu (nebo jen do paměti, ale pro MVP do feedu, aby byl vidět v deníku)
    feed.insert(0, newItem);
    notifyListeners();
  }

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
  
  // HELPERS
  List<FeedItem> get savedPosts => feed.where((i) => i.isSaved && !i.isHidden).toList();
  List<FeedItem> get visibleFeed => feed.where((i) => !i.isHidden).toList();
  int get xpForNextLevel => level * 500;
  int get xpCurrentLevelStart => (level - 1) * 500;
  int get xpMissing => xpForNextLevel - auraPoints;
  double get levelProgress => (auraPoints - xpCurrentLevelStart) / 500.0;
  List<int> get milestones => [50, 40, 30, 20, 15, 10, 5, 3, 2, 1];

  LevelInfo getLevelData(int targetLevel) {
    if (targetLevel <= 1) return LevelInfo("Poutník", "Začátek cesty", "Jsi na začátku.", "Feed");
    if (targetLevel <= 5) return LevelInfo("Hledač", "Hledání pravdy", "Hledáš souvislosti.", "Art Gen");
    if (targetLevel <= 10) return LevelInfo("Strážce", "Chráníš světlo", "Jsi oporou.", "Aura Voice");
    return LevelInfo("Světlonoš", "Záříš pro ostatní", "Inspiruješ.", "Global Map");
  }

  // ACTIONS
  void login(String name, FaithType selectedFaith) { nickname = name; faith = selectedFaith; isLoggedIn = true; notifyListeners(); }
  void updateProfile(String name, FaithType selectedFaith) { nickname = name; faith = selectedFaith; notifyListeners(); }
  void setIndex(int i) { navIndex = i; notifyListeners(); }
  void toggleJournalView(bool show) { showJournal = show; notifyListeners(); }
  void updateStress(double val) { currentStress = val; notifyListeners(); }
  void toggleTranslation(String id) { var item = feed.firstWhere((e) => e.id == id); item.showTranslation = !item.showTranslation; notifyListeners(); }
  void toggleSave(String id) { var item = feed.firstWhere((e) => e.id == id); item.isSaved = !item.isSaved; notifyListeners(); }
  void addPrivateNote(String id, String note) { var item = feed.firstWhere((e) => e.id == id); item.privateNotes.add(note); notifyListeners(); }
  void reportPost(String id) { var item = feed.firstWhere((e) => e.id == id); item.isHidden = true; notifyListeners(); }
  
  void createPost(String text, double stress) {
    Color generatedColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withValues(alpha: 1.0);
    feed.insert(0, FeedItem(id: DateTime.now().toString(), author: nickname.isEmpty ? "Ty" : nickname, country: "CZ", originalText: text, translatedText: text, showTranslation: true, artSeedColor: generatedColor));
    auraPoints += 50; currentStress = stress; totalImpactMoney += 5; notifyListeners();
  }

  void dischargePrayer(String id) {
    var item = feed.firstWhere((e) => e.id == id); item.likes++; item.isLiked = true; auraPoints += 15; totalImpactMoney += 1; notifyListeners(); HapticFeedback.heavyImpact();
  }
  
  void allocateCharity(String title) { totalImpactMoney += 10; notifyListeners(); HapticFeedback.mediumImpact(); }
  void sendMessage(String text) { chatHistory.add("Ty: $text"); notifyListeners(); Future.delayed(const Duration(milliseconds: 1500), () { chatHistory.add("Aura: Rozumím. Tvá slova rezonují. Zpracovávám tvou emoci..."); notifyListeners(); }); }
}