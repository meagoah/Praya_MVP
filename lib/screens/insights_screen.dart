import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../widgets/base_widgets.dart';
import '../utils/painters.dart'; // Potřebuje RadarPainter!

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20), Text("Vhledy", style: GoogleFonts.cinzel(fontSize: 28)), 
        const Text("Analýza dopadu modlitby (Real-time data)", style: TextStyle(color: Colors.white54)), const SizedBox(height: 30),
        
        Center(child: GlassPanel(child: Column(children: [
          const Text("Globální Puls", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const GlobalPulseRadar(), 
          const SizedBox(height: 20),
          Text("Aktivních poutníků: 12,450", style: TextStyle(color: state.moodColor))
        ]))),
        
        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Efekt Modlitby (Před vs. Po)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 20),
          SizedBox(height: 150, width: double.infinity, child: CustomPaint(painter: TrendChartPainter(state.weeklyTrends, state.moodColor))),
          const SizedBox(height: 15), 
          Row(children: [Icon(Icons.circle, size: 8, color: state.moodColor), const SizedBox(width: 5), const Text("Aktivita", style: TextStyle(fontSize: 10, color: Colors.white54)), const SizedBox(width: 15), Container(width: 8, height: 8, color: Colors.blue.withValues(alpha: 0.5)), const SizedBox(width: 5), const Text("Pokles Stresu", style: TextStyle(fontSize: 10, color: Colors.white54))])
        ])),
        
        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Mood Grid (30 dní)", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 15),
          Wrap(spacing: 5, runSpacing: 5, children: state.monthlyMoodMap.map((val) => Container(width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: Color.lerp(Colors.greenAccent, Colors.redAccent, val)!.withValues(alpha: 0.7)))).toList())
        ])),

        const SizedBox(height: 20),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Psychologický Profil", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 15), ...state.emotionDistribution.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 12)), Text("${(e.value * 100).toInt()}%", style: TextStyle(color: state.moodColor))]), const SizedBox(height: 5), LinearProgressIndicator(value: e.value, backgroundColor: Colors.white10, color: state.moodColor, minHeight: 6, borderRadius: BorderRadius.circular(5))])))])),
        const SizedBox(height: 100),
      ]));
  }
}

class TrendChartPainter extends CustomPainter {
  final List<List<double>> data; final Color color;
  TrendChartPainter(this.data, this.color);
  @override void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke; final paintFill = Paint()..color = Colors.blue.withValues(alpha: 0.2)..style = PaintingStyle.fill; final pathLine = Path(); final pathFill = Path(); double step = size.width / (data.length - 1);
    pathFill.moveTo(0, size.height); for (int i = 0; i < data.length; i++) { double x = i * step; double yLine = size.height - (data[i][1] * size.height); double yFill = size.height - (data[i][0] * size.height * 0.8); if (i == 0) { pathLine.moveTo(x, yLine); pathFill.lineTo(x, yFill); } else { pathLine.lineTo(x, yLine); pathFill.lineTo(x, yFill); } } pathFill.lineTo(size.width, size.height); pathFill.close(); canvas.drawPath(pathFill, paintFill); canvas.drawPath(pathLine, paintLine);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}