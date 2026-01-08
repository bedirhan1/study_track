import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

/// Giriş Ekranı
/// Kullanıcının sisteme kimlik doğrulaması yaparak girdiği ilk ekrandır.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form alanlarındaki metinleri okumak ve yönetmek için controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Kimlik doğrulama işlemlerini yürüten servis
  final AuthService _authService = AuthService(); 
  
  // Giriş butonu tıklandığında dönen çarkı göstermek için durum değişkeni
  bool _isLoading = false; 

  /// Giriş Yap butonuna basıldığında çalışan ana fonksiyon
  void _handleLogin() async {
    // Kullanıcının yanlışlıkla başta/sonda bıraktığı boşlukları temizlemek için trim() fonksiyonu
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. ADIM: Doğrulama
    // Alanların boş olup olmadığını kontrol ediyoruz.
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("Lütfen tüm alanları doldurun!");
      return; // Hata varsa işlemi durdur
    }

    // 2. ADIM: Arayüzü 'Yükleniyor' moduna al
    setState(() => _isLoading = true);

    // 3. ADIM: Firebase üzerinden giriş yapmayı dene
    // AuthService sınıfındaki login fonksiyonunu çağırır.
    final user = await _authService.login(email, password);

    // Widget hala ekranda mı kontrolü
    if (mounted) {
      setState(() => _isLoading = false); // Yüklemeyi durdur

      if (user != null) {
        // GİRİŞ BAŞARILI: Ana ekrana (Dashboard) yönlendir.
        // pushReplacement: Geri tuşuna basıldığında tekrar Login ekranına dönmemesi için
        // Login ekranını yığından silip yerine Dashboard'u koyar.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // GİRİŞ HATALI: Kullanıcıya alt bantta (SnackBar) hata mesajı göster
        _showErrorSnackBar("Giriş başarısız! E-posta veya şifre hatalı.");
      }
    }
  }

  /// Hata mesajlarını ekranda göstermek için yardımcı fonksiyon
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent, // Hata olduğu için kırmızı renk
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( 
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              
              // Logo ve Başlık alanı
              const Icon(Icons.timer_outlined, size: 100, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text(
                "StudyTrack",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const Text("Çalışmanı takip et, hedefine ulaş."),
              const SizedBox(height: 48),

              // E-posta Girişi
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Şifre Girişi
              TextField(
                controller: _passwordController,
                obscureText: true, // Şifreyi yıldızlı (****) gösterir
                decoration: InputDecoration(
                  labelText: "Şifre",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Giriş Yap Butonu
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Giriş Yap", style: TextStyle(fontSize: 18)),
                    ),
              
              const SizedBox(height: 16),

              // Kayıt Ol Sayfasına Yönlendirme Linki
              TextButton(
                onPressed: () {
                  // push: Kullanıcı geri tuşuyla Login sayfasına dönebilir
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text("Hesabınız yok mu? Şimdi Kayıt Olun"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}