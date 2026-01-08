import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Kayıt Ol Ekranı
/// Kullanıcının e-posta ve şifre ile sisteme yeni bir hesap oluşturduğu ekrandır.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Kullanıcının girdiği metinleri okumak için controller yapıları
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Kayıt işlemleri için Auth servisini çağırıyoruz
  final AuthService _authService = AuthService();
  
  // Kayıt işlemi sürerken butonu gizleyip dönen çarkı göstermek için durum değişkeni
  bool _isLoading = false;

  /// Kayıt Ol butonuna basıldığında çalışan ana fonksiyon
  void _handleRegister() async {
    // 1. ADIM: Basit Doğrulama (Validation)
    // E-posta boşsa veya şifre 6 karakterden kısaysa kullanıcıyı uyar.
    if (_emailController.text.isEmpty || _passwordController.text.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Geçerli bir e-posta ve en az 6 haneli şifre girin!")),
        );
      }
      return; // Hata varsa fonksiyonu burada durdur
    }

    // 2. ADIM: Yükleniyor animasyonunu başlat
    setState(() => _isLoading = true);
    
    // Kullanıcının yanlışlıkla sona koyduğu boşlukları silmek için trim() fonksiyonu
    final user = await _authService.register(
      _emailController.text.trim(), 
      _passwordController.text.trim()
    );
    
    // İşlem bitti (başarılı veya başarısız), yükleniyor animasyonunu durdur
    setState(() => _isLoading = false);

    // 3. ADIM: Sonucu kontrol et ve yönlendir
    if (user != null) {
      // Kayıt başarılıysa bilgi ver ve önceki sayfaya (Giriş) dön
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kayıt başarılı! Giriş yapabilirsiniz.")));
        Navigator.pop(context); 
      }
    } else {
      // Kayıt başarısızsa (örn: e-posta zaten kayıtlıysa) hata göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kayıt başarısız. Bu e-posta zaten kullanımda olabilir.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hesap Oluştur")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // E-posta giriş alanı
            TextField(
              controller: _emailController, 
              decoration: const InputDecoration(labelText: "E-posta", border: OutlineInputBorder())
            ),
            const SizedBox(height: 16),
            
            // Şifre giriş alanı
            TextField(
              controller: _passwordController, 
              obscureText: true, 
              decoration: const InputDecoration(labelText: "Şifre", border: OutlineInputBorder())
            ),
            const SizedBox(height: 24),
            
            // Yükleniyor durumuna göre arayüz değişimi
            _isLoading 
              ? const CircularProgressIndicator() // İşlem sürerken dönen çark
              : ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Kayıt Ol"),
                ),
          ],
        ),
      ),
    );
  }
}