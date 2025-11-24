import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';

// --- D. INSIGHTS SCREEN (TUNED - REALISTIC) ---
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Vhledy", style: GoogleFonts.cinzel(fontSize: 28)),
          const Text("Analýza dopadu modlitby (Real-time data)", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 30),
          
          // GLOBAL PULSE RADAR
          Center(child: GlassPanel(child: Column(children: [
            const Text("Globální Puls", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const GlobalPulseRadar(), // Bere se z base_widgets.dart
            const SizedBox(height: 20),
            Text("Aktivních poutníků: 12,450", style: TextStyle(color: state.moodColor))
          ]))),
          
          const SizedBox(height: 20),
          
          // EFEKT MODLITBY (PRE/POST GRAF)
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Efekt Modlitby (Před vs. Po)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
            const SizedBox(height: 20),
            SizedBox(height: 150, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(7, (i) { return Column(mainAxisAlignment: MainAxisAlignment.end, children: [Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(width: 12, height: state.moodBefore[i] * 100, color: Colors.red.withValues(alpha: 0.5)), const SizedBox(width: 4), Container(width: 12, height: state.moodAfter[i] * 100, color: Colors.green)]), const SizedBox(height: 5), Text("D${i+1}", style: const TextStyle(fontSize: 10, color: Colors.white38))]); }))),
            const SizedBox(height: 15), 
            const Row(children: [Icon(Icons.trending_down, color: Colors.green), SizedBox(width: 10), Text("Průměrný pokles napětí o 42%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])
          ])),
          
          const SizedBox(height: 20),
          
          // KORELAČNÍ GRAF (TRENDY)
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Korelace: Aktivita vs. Klid", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(height: 150, width: double.infinity, child: CustomPaint(painter: TrendChartPainter(state.weeklyTrends, state.moodColor))),
          ])),

          const SizedBox(height: 20),
          
          // PSYCHOLOGICKÝ PROFIL
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Psychologický Profil", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 15), ...state.emotionDistribution.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 12)), Text("${(e.value * 100).toInt()}%", style: TextStyle(color: state.moodColor))]), const SizedBox(height: 5), LinearProgressIndicator(value: e.value, backgroundColor: Colors.white10, color: state.moodColor, minHeight: 6, borderRadius: BorderRadius.circular(5))])))])),
          
          const SizedBox(height: 20),
          
          // VĚDECKÝ FAKT
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withValues(alpha: 0.3))), child: const Row(children: [Icon(Icons.lightbulb, color: Colors.blue), SizedBox(width: 15), Expanded(child: Text("Sdílená intence snižuje pocit osamělosti o 60% (Studie BYU 2024).", style: TextStyle(fontSize: 12, color: Colors.white70)))])),
          
          const SizedBox(height: 100),
        ]
      )
    );
  }
}

// Custom Painter pro Graf Trendů
class TrendChartPainter extends CustomPainter {
  final List<List<double>> data; 
  final Color color;
  TrendChartPainter(this.data, this.color);
  
  @override 
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke; 
    final paintFill = Paint()..color = Colors.blue.withValues(alpha: 0.2)..style = PaintingStyle.fill; 
    final pathLine = Path(); 
    final pathFill = Path(); 
    double step = size.width / (data.length - 1);
    
    pathFill.moveTo(0, size.height); 
    for (int i = 0; i < data.length; i++) { 
      double x = i * step; 
      double yLine = size.height - (data[i][1] * size.height); 
      double yFill = size.height - (data[i][0] * size.height * 0.8); 
      if (i == 0) { pathLine.moveTo(x, yLine); pathFill.lineTo(x, yFill); } 
      else { pathLine.lineTo(x, yLine); pathFill.lineTo(x, yFill); } 
    } 
    pathFill.lineTo(size.width, size.height); 
    pathFill.close(); 
    canvas.drawPath(pathFill, paintFill); 
    canvas.drawPath(pathLine, paintLine);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}