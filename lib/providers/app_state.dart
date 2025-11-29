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
    FeedItem(id: "1", author: "Maria", country: "BR", originalText: "Meu filho tem cirurgia amanhã. Preciso sentir que não estou sozinha nisso.", translatedText: "Můj syn má zítra operaci. Potřebuji cítit, že v tom nejsem sama.", likes: 342, artSeedColor: Colors.orangeAccent),
    FeedItem(id: "2", author: "John", country: "US", originalText: "Praying for clarity in my career. The anxiety is overwhelming today.", translatedText: "Modlím se za jasnost v mé kariéře. Úzkost je dnes ohromující.", likes: 890, artSeedColor: Colors.cyanAccent),
    FeedItem(id: "3", author: "Aisha", country: "AE", originalText: "نبحث عن النور في الأوقات المظلمة", translatedText: "Hledáme světlo v temných časech.", likes: 120, artSeedColor: Colors.purpleAccent),
  ];

  List<String> chatHistory = ["Aura: Vítám tě. Cítím z tebe dnes napětí. Jak ti mohu posloužit?"];

  // --- NOTIFIKACE ---
  List<AppNotification> notifications = [
    AppNotification(title: "Svíčka zapálena", subtitle: "Maria z Brazílie podpořila tvou modlitbu.", icon: Icons.light_mode, color: Colors.amber, timeAgo: "2m"),
    AppNotification(title: "Nový Level!", subtitle: "Dosáhl jsi úrovně Hledač.", icon: Icons.arrow_upward, color: Colors.cyan, timeAgo: "1h"),
    AppNotification(title: "Aura má vzkaz", subtitle: "Dnešní den je vhodný pro reflexi.", icon: Icons.auto_awesome, color: Colors.purpleAccent, timeAgo: "5h"),
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

  void askAuraAboutQuote(String quote) {
    chatHistory.add("Ty: Zaujal mě tento citát: \"$quote\". Co mi k němu můžeš říct hlubšího?");
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1000), () {
      chatHistory.add("Aura: To je hluboká myšlenka. Tento text nám připomíná, že naše vnitřní síla často pramení z propojení s něčím větším. Jak to rezonuje s tvou dnešní situací?");
      notifyListeners();
    });
  }
  
  void saveQuoteAsJournalEntry(String quote) {
    var newItem = FeedItem(
      id: "quote_${DateTime.now().millisecondsSinceEpoch}",
      author: "Moudrost dne",
      country: "Svět",
      originalText: quote,
      translatedText: quote,
      showTranslation: true,
      isSaved: true,
      artSeedColor: Colors.amber
    );
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
  
  // --- HELPERS (ZDE CHYBĚLY V MINULÉ VERZI!) ---
  // Filtrované seznamy pro UI
  List<FeedItem> get savedPosts => feed.where((i) => i.isSaved && !i.isHidden).toList();
  List<FeedItem> get visibleFeed => feed.where((i) => !i.isHidden).toList();
  
  // Leveling
  int get xpForNextLevel => level * 500;
  int get xpCurrentLevelStart => (level - 1) * 500;
  int get xpMissing => xpForNextLevel - auraPoints;
  double get levelProgress => (auraPoints - xpCurrentLevelStart) / 500.0;
  
  // Milníky pro mapu
  List<int> get milestones => [50, 20, 10, 5, 3, 2, 1];

  // --- BOHATÉ TEXTY PRO CESTU DUŠE (LORE) ---
  final Map<FaithType, Map<int, LevelInfo>> _progressionTrees = {
    FaithType.christian: {
      1: LevelInfo("Katechumen", "Tvá cesta začíná nasloucháním.", "Jako ten, kdo stojí v předsíni chrámu, učíš se vnímat potřeby druhých. Tvá modlitba je zatím tichá, ale tvé srdce se otevírá.", "Základní Feed"),
      2: LevelInfo("Hledající", "První kroky v modlitbě.", "Začínáš formulovat své vlastní prosby a chápeš sílu společenství. Tvá víra hledá oporu v Písmu a tradici.", "Deník Vděčnosti"),
      3: LevelInfo("Poutník", "Kráčíš po cestě světla.", "Nyní jsi na cestě. Tvá modlitba má směr a tvé nohy rytmus. Pomáháš nést břemena ostatních poutníků.", "Překlady Modliteb"),
      5: LevelInfo("Učedník", "Pravidelnost přináší ovoce.", "Denní disciplína modlitby mění tvé srdce. Stáváš se učedníkem Lásky, který nejen prosí, ale i děkuje.", "Detailní Statistiky"),
      10: LevelInfo("Strážce Víry", "Jsi oporou komunity.", "Ostatní se na tebe obracejí s důvěrou. Tvá modlitba je štítem pro ty, kteří nemají sílu se modlit sami.", "Aura AI Voice"),
      20: LevelInfo("Misionář", "Šíříš světlo do světa.", "Tvá víra překračuje hranice tvého domova. Zapaluješ světlo naděje v temných koutech světa.", "Global Impact"),
      50: LevelInfo("Apoštol Lásky", "Tvá víra hory přenáší.", "Dosáhl jsi vrcholu služby. Tvá přítomnost je modlitbou. Jsi živým důkazem síly společenství.", "Legacy Mode"),
    },
    FaithType.atheist: {
      1: LevelInfo("Pozorovatel", "Zkoumáš svět dat.", "Sleduješ toky lidských emocí a potřeb. Analyzuješ, jak sdílená myšlenka ovlivňuje realitu.", "Data Feed"),
      2: LevelInfo("Skeptik", "Ptáš se a ověřuješ.", "Nevěříš slepě, ale hledáš důkazy. Tvá skepse je zdravá, protože vede k hlubšímu pochopení lidské psychiky.", "Deník Myšlenek"),
      3: LevelInfo("Hledač Faktů", "Nacházíš souvislosti.", "Začínáš vidět vzorce v chaosu. Uvědomuješ si, že podpora komunity má měřitelný dopad na well-being.", "Překlady Idejí"),
      5: LevelInfo("Analytik", "Chápeš vzorce mysli.", "Tvá mysl je nástroj. Používáš logiku k tomu, abys efektivně pomáhal tam, kde je to nejvíce třeba.", "Psycho-Stats"),
      10: LevelInfo("Empatik", "Cítíš, co říkají data.", "Čísla se mění v příběhy. Rozumíš, že za každým datovým bodem je lidský osud, který stojí za to podpořit.", "AI Psycholog"),
      20: LevelInfo("Filantrop", "Tvé činy mají reálný dopad.", "Měníš svět ne modlitbou, ale činem. Tvé zdroje a energie směřují tam, kde mění životy.", "Allocation Power"),
      50: LevelInfo("Vizionář", "Tvoříš budoucnost lidstva.", "Vidíš svět ne takový, jaký je, ale jaký by mohl být. Jsi architektem lepší společnosti.", "Global Influence"),
    },
    FaithType.muslim: {
      1: LevelInfo("Hledající (Talib)", "Hledáš pravdu.", "Tvá cesta začíná upřímnou snahou poznat Vůli. Jsi jako student, který sedí u nohou moudrosti.", "Dua Feed"),
      2: LevelInfo("Probuzený", "Otevíráš oči srdce.", "Začínáš vnímat znamení v každodenním životě. Tvá vděčnost roste s každým nádechem.", "Sabr Tracker"),
      3: LevelInfo("Poutník (Salik)", "Kráčíš po přímé stezce.", "Tvá cesta je jasná. Vytrvalost a trpělivost (Sabr) jsou tvými společníky na cestě k Bohu.", "Překlady"),
      5: LevelInfo("Služebník (Abid)", "Sloužíš stvořiteli.", "V modlitbě nacházíš klid. Tvá služba lidem je formou uctívání. Jsi užitečný pro svou Ummu.", "Ibadah Stats"),
      10: LevelInfo("Pamatující (Zakir)", "Srdce nezapomíná.", "Tvé srdce je stále ve spojení. Každý tvůj tep je připomínkou Vyšší moci.", "AI Imam"),
      20: LevelInfo("Vědoucí (Alim)", "Znalost je světlo.", "Tvá moudrost je majákem. Pomáháš ostatním orientovat se ve složitostech života.", "Halaqa Groups"),
      50: LevelInfo("Přítel (Wali)", "Blízko zdroji.", "Jsi tím, kdo je blízký Bohu. Tvá přítomnost přináší mír a požehnání (Baraka) ostatním.", "Barakah Mode"),
    },
    FaithType.universal: { 
      1: LevelInfo("Probuzený", "Otevřel jsi oči novému vnímání.", "Uvědomuješ si, že nejsi oddělený od celku. Tvá cesta k jednotě právě začíná.", "Řeka Naděje"),
      2: LevelInfo("Novic", "Učíš se pracovat s energií.", "Zjišťuješ, že tvá myšlenka má váhu. Učíš se směrovat svou pozornost tam, kde je třeba.", "Osobní Deník"),
      3: LevelInfo("Hledač Světla", "Aktivně vyhledáváš spojení.", "Tvá duše rezonuje s příběhy druhých. Hledáš světlo v sobě i v ostatních.", "Univerzální Překlad"),
      5: LevelInfo("Světlonoš", "Tvá energie inspiruje ostatní.", "Stáváš se zdrojem. Tvá pozitivita a naděje jsou nakažlivé a léčí okolí.", "Aura Analytika"),
      10: LevelInfo("Strážce Frekvence", "Udržuješ harmonii v chaosu.", "Když ostatní panikaří, ty držíš prostor klidu. Jsi kotvou v bouři.", "Healing AI"),
      20: LevelInfo("Tkadlec Osudu", "Vidíš souvislosti.", "Chápeš jemné předivo osudu. Víš, že náhody neexistují a vše je propojeno.", "Circle Maker"),
      50: LevelInfo("Kosmické Vědomí", "Jsi jedno s celkem.", "Hranice mezi tebou a vesmírem mizí. Jsi kapkou v oceánu i oceánem v kapce.", "Avatar"),
    }
  };

  LevelInfo getLevelData(int targetLevel) {
    var tree = _progressionTrees[faith] ?? _progressionTrees[FaithType.universal]!;
    var definedLevels = tree.keys.toList()..sort();
    int bestMatch = definedLevels.lastWhere((k) => k <= targetLevel, orElse: () => 1);
    return tree[bestMatch]!;
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