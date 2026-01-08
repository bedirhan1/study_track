import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Profil Ekranı
/// Kullanıcının bilgilerini güncellediği ve avatar seçtiği ekran.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  // Varsayılan avatar
  String _selectedAvatarUrl = "https://api.dicebear.com/7.x/avataaars/png?seed=Felix"; 

  // Kullanıcının seçebileceği hazır avatar listesi
  final List<String> _avatarOptions = [
    "https://api.dicebear.com/7.x/avataaars/png?seed=Felix",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Aneka",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Zack",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Midnight",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Sky",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Lilith",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Baby",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Grandma",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Veritabanından mevcut kullanıcı bilgilerini çeker ve forma doldurur.
  void _loadUserData() async {
    final userId = _authService.currentUserId!;
    final snapshot = await _firestoreService.getUserProfile(userId).first;
    
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _departmentController.text = data['department'] ?? '';
        // Eğer veritabanında kayıtlı foto varsa onu getir
        if (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
          _selectedAvatarUrl = data['photoUrl'];
        }
      });
    }
  }

  /// Güncellenen bilgileri Firestore'a kaydeder.
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    // Avatar resmi yüklemek yerine, sadece seçilen URL string'ini kaydediyoruz.
    await _firestoreService.updateUserProfile(
      _authService.currentUserId!,
      _nameController.text,
      _departmentController.text,
      _selectedAvatarUrl, 
    );

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil başarıyla güncellendi!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Düzenle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Seçili olan büyük avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.indigo.shade100,
              backgroundImage: NetworkImage(_selectedAvatarUrl),
            ),
            const SizedBox(height: 20),
            const Text("Bir Avatar Seçin:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            // Avatar seçim listesi
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarOptions.length,
                itemBuilder: (context, index) {
                  final url = _avatarOptions[index];
                  final isSelected = _selectedAvatarUrl == url;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatarUrl = url);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Seçili olanın etrafına renkli çerçeve ekle
                        border: isSelected ? Border.all(color: Colors.indigo, width: 3) : null,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: NetworkImage(url),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Ad Soyad", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _departmentController,
              decoration: const InputDecoration(labelText: "Bölüm / Sınıf", border: OutlineInputBorder(), prefixIcon: Icon(Icons.school)),
            ),
            
            const SizedBox(height: 40),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Kaydet"),
                ),
            
            const SizedBox(height: 20),
            // Çıkış yap butonu
            OutlinedButton.icon(
              onPressed: () async {
                await _authService.logout();
                // Tüm geçmişi silerek Login ekranına atar
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}