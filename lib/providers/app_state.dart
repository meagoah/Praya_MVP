import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pro HapticFeedback
import 'dart:math';
import '../models/data_models.dart';

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  String nickname = "";
  FaithType faith = FaithType.universal;
  
  int navIndex = 0;
  int auraPoints = 2450;
  
  // Level se počítá dynamicky
  int get level => (auraPoints / 500).floor() + 1;
  
  double currentStress = 0.5; 
  bool showJournal = false;
  double totalImpactMoney = 450.0; 

  // Helpers
  int get xpForNextLevel => level * 500;
  int get xpCurrentLevelStart => (level - 1) * 500;
  int get xpMissing => xpForNextLevel - auraPoints;
  double get levelProgress {
    int pointsInCurrentLevel = auraPoints - xpCurrentLevelStart;
    return pointsInCurrentLevel / 500.0;
  }

  // --- NOTIFIKACE (Ozvěny) ---
  List<AppNotification> notifications = [
    AppNotification(title: "Svíčka zapálena", subtitle: "Maria z Brazílie podpořila tvou modlitbu.", icon: Icons.light_mode, color: Colors.amber, timeAgo: "2m"),
    AppNotification(title: "Nový Level!", subtitle: "Dosáhl jsi úrovně Hledač.", icon: Icons.arrow_upward, color: Colors.cyan, timeAgo: "1h"),
    AppNotification(title: "Aura má vzkaz", subtitle: "Dnešní den je vhodný pro reflexi.", icon: Icons.auto_awesome, color: Colors.purpleAccent, timeAgo: "5h"),
  ];

  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;

  void markNotificationsAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // Data pro Insights
  final List<double> moodBefore = [0.8, 0.7, 0.9, 0.6, 0.8, 0.5, 0.7];
  final List<double> moodAfter = [0.4, 0.3, 0.5, 0.2, 0.4, 0.2, 0.3];
  final Map<String, double> emotionDistribution = {"Vděčnost": 0.45, "Prosba / Úzkost": 0.30, "Naděje": 0.15, "Smutek": 0.10};

  // Simulace trendu
  final List<List<double>> weeklyTrends = [
    [0.8, 0.2], [0.7, 0.3], [0.9, 0.1], 
    [0.6, 0.6], [0.4, 0.8], [0.3, 0.9], [0.2, 0.8] 
  ];
  
  final List<double> monthlyMoodMap = List.generate(30, (index) => (sin(index * 0.5) + 1) / 2 * 0.8 + 0.1);

  List<CharityProject> charityProjects = [
    CharityProject("Voda pro Afriku", "Výstavba studní v oblasti Sahelu.", 0.75, "750k / 1M Kč", Colors.cyan),
    CharityProject("Vzdělání dětí", "Školní pomůcky pro sirotčinec v Nepálu.", 0.40, "40k / 100k Kč", Colors.orange),
    CharityProject("Oprava Kapličky", "Záchrana kulturního dědictví v Sudetech.", 0.90, "90k / 100k Kč", Colors.green),
  ];

  List<FeedItem> feed = [
    FeedItem(id: "1", author: "Maria", country: "BR", originalText: "Meu filho tem cirurgia amanhã. Preciso sentir que não estou sozinha nisso.", translatedText: "Můj syn má zítra operaci. Potřebuji cítit, že v tom nejsem sama.", likes: 342, artSeedColor: Colors.orangeAccent),
    FeedItem(id: "2", author: "John", country: "US", originalText: "Praying for clarity in my career. The anxiety is overwhelming today.", translatedText: "Modlím se za jasnost v mé kariéře. Úzkost je dnes ohromující.", likes: 890, artSeedColor: Colors.cyanAccent),
    FeedItem(id: "3", author: "Aisha", country: "AE", originalText: "نبحث عن النور في الأوقات المظلمة", translatedText: "Hledáme světlo v temných časech.", likes: 120, artSeedColor: Colors.purpleAccent),
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
    switch (faith) {
      case FaithType.christian:
        if (targetLevel <= 1) return LevelInfo("Katechumen", "Začátek cesty.", "Feed");
        if (targetLevel <= 3) return LevelInfo("Poutník", "Cesta modlitby.", "Překlady");
        if (targetLevel <= 5) return LevelInfo("Učedník", "Pravidelná praxe.", "Statistiky");
        if (targetLevel <= 10) return LevelInfo("Strážce Víry", "Opora komunity.", "Aura Voice");
        if (targetLevel <= 20) return LevelInfo("Misionář", "Šíření světla.", "Global Impact");
        return LevelInfo("Apoštol Lásky", "Víra hory přenáší.", "Legacy Mode");
      case FaithType.atheist:
        if (targetLevel <= 1) return LevelInfo("Pozorovatel", "Zkoumání dat.", "Feed");
        if (targetLevel <= 3) return LevelInfo("Analytik", "Síla psychiky.", "Studie");
        if (targetLevel <= 5) return LevelInfo("Empatik", "Podpora ostatních.", "Tracker");
        if (targetLevel <= 10) return LevelInfo("Humanista", "Měnění světa.", "Impact Report");
        return LevelInfo("Vizionář", "Budoucnost lidstva.", "Global Influence");
      case FaithType.muslim:
        if (targetLevel <= 1) return LevelInfo("Hledající", "Hledání pravdy.", "Dua Feed");
        if (targetLevel <= 3) return LevelInfo("Poutník", "Přímá stezka.", "Překlady");
        if (targetLevel <= 5) return LevelInfo("Služebník", "Služba stvořiteli.", "Ibadah Stats");
        if (targetLevel <= 10) return LevelInfo("Pamatující", "Srdce nezapomíná.", "AI Imam");
        return LevelInfo("Přítel (Wali)", "Blízko zdroji.", "Barakah Mode");
      default: 
        if (targetLevel <= 1) return LevelInfo("Probuzený", "Nové vnímání.", "Řeka Naděje");
        if (targetLevel <= 3) return LevelInfo("Hledač Světla", "Hledání spojení.", "Aura");
        if (targetLevel <= 5) return LevelInfo("Světlonoš", "Inspirace ostatních.", "Analytika");
        if (targetLevel <= 10) return LevelInfo("Strážce Frekvence", "Harmonie v chaosu.", "Healing Mode");
        if (targetLevel <= 20) return LevelInfo("Tkadlec Osudu", "Vidění souvislostí.", "Deep Connect");
        return LevelInfo("Kosmické Vědomí", "Jednota s celkem.", "Avatar");
    }
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
    Color generatedColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withValues(alpha: 1.0);
    feed.insert(0, FeedItem(id: DateTime.now().toString(), author: nickname.isEmpty ? "Ty" : nickname, country: "CZ", originalText: text, translatedText: text, showTranslation: true, artSeedColor: generatedColor));
    auraPoints += 50; currentStress = stress; totalImpactMoney += 5; notifyListeners();
  }

  void dischargePrayer(String id) {
    var item = feed.firstWhere((e) => e.id == id); item.likes++; item.isLiked = true; auraPoints += 15; totalImpactMoney += 1; notifyListeners(); HapticFeedback.heavyImpact();
  }
  
  void allocateCharity(String title) {
    totalImpactMoney += 10; 
    notifyListeners();
    HapticFeedback.mediumImpact();
  }

  void sendMessage(String text) {
    chatHistory.add("Ty: $text"); notifyListeners(); Future.delayed(const Duration(milliseconds: 1500), () { chatHistory.add("Aura: Rozumím. Tvá slova rezonují. Zpracovávám tvou emoci..."); notifyListeners(); });
  }
}