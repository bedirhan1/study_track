import 'dart:async';
import 'package:flutter/material.dart';
import '../models/study_session.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Çalışma Zamanlayıcısı (Kronometre)
/// Kullanıcının ders çalışma süresini takip eder ve veritabanına kaydeder.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;      // Arka planda saniye sayan mekanizma
  int _seconds = 0;   // Geçen toplam süre (saniye cinsinden)
  bool _isRunning = false; // Sayaç çalışıyor mu?

  final _subjectController = TextEditingController(); // Ders adı girişi için

  /// Sayacı Başlatma Fonksiyonu
  void _startTimer() {
    setState(() => _isRunning = true);
    // Her 1 saniyede bir _seconds değişkenini 1 artırır
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  /// Sayacı Duraklatma Fonksiyonu
  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel(); // Saymayı durdur
      setState(() => _isRunning = false);
    }
  }

  /// Çalışmayı Bitir ve Kaydet Penceresi
  void _stopAndSave() {
    _pauseTimer(); // Önce durdur
    
    // Kullanıcıdan ders adını girmesini isteyen pencere aç
    showDialog(
      context: context,
      barrierDismissible: false, // Boşluğa tıklayınca kapanmasın
      builder: (context) => AlertDialog(
        title: const Text("Çalışmayı Kaydet"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Toplam Süre: ${_formatTime(_seconds)}"),
            const SizedBox(height: 10),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                hintText: "Ders adı gir (Örn: Web Programlama)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // İptal et ve geri dön
            },
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Veritabanına kaydetme işlemi
              if (_subjectController.text.isNotEmpty) {
                final session = StudySession(
                  userId: AuthService().currentUserId!,
                  date: DateTime.now(),
                  durationInSeconds: _seconds,
                  subject: _subjectController.text,
                );
                
                await FirestoreService().saveStudySession(session);
                
                if (mounted) {
                  Navigator.pop(context); // Pencereyi kapat
                  Navigator.pop(context); // Timer ekranından çık (Dashboard'a dön)
                }
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  /// Saniyeyi "00:00:00" formatına çeviren yardımcı fonksiyon
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zamanlayıcı")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Süre Göstergesi
            Text(
              _formatTime(_seconds),
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
            ),
            const SizedBox(height: 50),
            
            // Kontrol Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başlat / Duraklat Butonu
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? "Duraklat" : "Başlat"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: _isRunning ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                // Bitir Butonu
                ElevatedButton.icon(
                  onPressed: _seconds > 0 ? _stopAndSave : null, // Süre 0 ise tıklanamaz
                  icon: const Icon(Icons.stop),
                  label: const Text("Bitir"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}