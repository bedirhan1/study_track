import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/study_session.dart';
import 'timer_screen.dart';
import 'goal_screen.dart';
import 'community_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

/// Ana Kontrol Paneli (Dashboard)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Servisleri başlatıyoruz
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final userId = authService.currentUserId!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("StudyTrack", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Profil butonuna tıklandığında Profil sayfasına yönlendirir
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          )
        ],
      ),
    
      // İçeriğin çok yayılmasını engellemek için maksimum genişlik belirliyoruz
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Bugünkü Özet", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                // 1. ADIM: Önce kullanıcının hedefini çekiyoruz
                StreamBuilder<DocumentSnapshot>(
                  stream: firestoreService.getDailyGoal(userId),
                  builder: (context, goalSnapshot) {
                    int dailyGoalMinutes = 60; // Varsayılan hedef
                    if (goalSnapshot.hasData && goalSnapshot.data!.exists) {
                      dailyGoalMinutes = goalSnapshot.data!['dailyMinutes'];
                    }

                    // 2. ADIM: Sonra kullanıcının bugünkü çalışmalarını çekiyoruz
                    return StreamBuilder<List<StudySession>>(
                      stream: firestoreService.getTodaysSessions(userId),
                      builder: (context, sessionSnapshot) {
                        int totalSeconds = 0;
                        if (sessionSnapshot.hasData) {
                          // Tüm oturumların sürelerini topluyoruz
                          totalSeconds = sessionSnapshot.data!.fold(0, (sum, item) => sum + item.durationInSeconds);
                        }

                        int totalMinutes = totalSeconds ~/ 60; // Ekranda göstermek için dakika

                        // İlerleme Hesabı
                        // Dakika yerine saniye bazlı hesaplayarak çubuğun daha hassas dolmasını sağlıyoruz.
                        int goalInSeconds = dailyGoalMinutes * 60;
                        double progress = (goalInSeconds > 0) 
                            ? (totalSeconds / goalInSeconds).clamp(0.0, 1.0)
                            : 0.0;

                        // İlerleme Kartı Tasarımı
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.indigo, Colors.indigo.shade400]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withValues(alpha: 0.3),
                                blurRadius: 10, 
                                offset: const Offset(0, 5)
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text("$totalMinutes / $dailyGoalMinutes dk", 
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: progress, 
                                minHeight: 10, 
                                borderRadius: BorderRadius.circular(6),
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Text("Günlük Hedef: %${(progress * 100).toInt()}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 25),
                const Text("Hızlı Menü", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Menü Butonları (Grid Yapısı)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, 
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.5, // Dikdörtgen görünüm için oran (Genişlik / Yükseklik)
                  children: [
                    _buildMenuButton(context, "Çalışmaya Başla", Icons.play_circle_filled, Colors.orange, const TimerScreen()),
                    _buildMenuButton(context, "Hedeflerim", Icons.track_changes, Colors.purple, const GoalScreen()),
                    _buildMenuButton(context, "Topluluk", Icons.forum, Colors.green, const CommunityScreen()),
                    _buildMenuButton(context, "İstatistikler", Icons.assessment, Colors.blue, const StatsScreen()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tekrar eden kodları önlemek için buton oluşturucu yardımcı fonksiyon
  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color, Widget? targetScreen) {
    return InkWell(
      onTap: () {
        if (targetScreen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu özellik yakında eklenecek.")));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}