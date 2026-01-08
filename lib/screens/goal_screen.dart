import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Hedef Belirleme Ekranı
/// Kullanıcının günlük çalışma hedefini dakika cinsinden girdiği ekrandır.
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _goalController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  bool _isSaving = false; // Kayıt işlemi sırasında butonu pasif yapmak için

  /// Hedefi veritabanına kaydeder
  void _saveGoal() async {
    if (_goalController.text.isEmpty) return;
    
    setState(() => _isSaving = true);
    
    // Klavyeden girilen metni sayıya çevirip servise gönderiyoruz
    await _firestoreService.saveDailyGoal(
      _authService.currentUserId!,
      int.parse(_goalController.text),
    );
    
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hedef başarıyla güncellendi!")),
      );
      Navigator.pop(context); // İşlem bitince önceki ekrana dön
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hedef Belirle")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Günlük çalışma hedefinizi dakika cinsinden giriniz:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            // Sayı Giriş Alanı
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number, // Sadece sayı klavyesi açılır
              decoration: InputDecoration(
                hintText: "Örn: 120",
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Hedefi Kaydet"),
                  ),
          ],
        ),
      ),
    );
  }
}