import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/study_session.dart';
import 'package:intl/intl.dart';

/// İstatistikler Ekranı
/// Kullanıcının son 7 günlük çalışma performansını grafik olarak gösterir.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Haftalık İstatistikler")),
      body: StreamBuilder<List<StudySession>>(
        // Son 7 günün verilerini çekiyoruz
        stream: firestoreService.getLast7DaysSessions(authService.currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // --- Veri İşleme (Data Processing) ---
          // Gelen ham veriyi (List<StudySession>), günlere göre gruplanmış toplamlara çeviriyoruz.
          // Örn: {"Pzt": 45.0, "Sal": 120.0}
          Map<String, double> dailyStats = {};
          for (var session in snapshot.data!) {
            String dayName = DateFormat('E').format(session.date); // Gün ismini al (Mon, Tue...)
            dailyStats[dayName] = (dailyStats[dayName] ?? 0) + (session.durationInSeconds / 60);
          }

          // Son 7 günün isim listesini oluşturuyoruz (Grafiğin X ekseni için)
          List<String> last7Days = List.generate(7, (index) {
            return DateFormat('E').format(DateTime.now().subtract(Duration(days: 6 - index)));
          });

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text("Son 7 Günlük Çalışma (Dakika)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                // Grafik Alanı (SizedBox ile yükseklik sınırlaması yaparak taşmayı önledik)
                SizedBox(
                  height: 300, 
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false), // Izgaraları gizle
                      titlesData: FlTitlesData(
                        show: true,
                        // Alt Eksen (X Axis): Gün isimleri
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                                 return Padding(
                                   padding: const EdgeInsets.only(top: 8.0),
                                   child: Text(last7Days[value.toInt()], style: const TextStyle(fontSize: 12)),
                                 );
                              }
                              return const Text("");
                            },
                          ),
                        ),
                        // Diğer eksenlerdeki yazıları gizliyoruz
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      // Çubukların Oluşturulması
                      barGroups: List.generate(7, (index) {
                        String day = last7Days[index];
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: dailyStats[day] ?? 0, // O günün verisi yoksa 0 göster
                              color: Colors.indigo,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                              // Arka plandaki gri çubuk (hedef çizgisi görseli)
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 60, 
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Grafik altındaki liste görünümü
                Expanded(
                  child: ListView(
                    children: dailyStats.entries.map((e) => Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.timer, color: Colors.indigo),
                        title: Text(e.key == DateFormat('E').format(DateTime.now()) ? "Bugün" : e.key),
                        trailing: Text("${e.value.toStringAsFixed(1)} dk", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )).toList(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}