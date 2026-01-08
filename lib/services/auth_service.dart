import 'package:firebase_auth/firebase_auth.dart';

  /// Kullanıcı Kimlik Doğrulama İşlemleri (Authentication)
  /// Firebase Auth servisini kullanarak Giriş, Kayıt ve Çıkış işlemlerini yönetir.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mevcut kullanıcının ID'sini alır
  String? get currentUserId => _auth.currentUser?.uid;

  // Kayıt olma fonksiyonu
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Kayıt Hatası: $e");
      return null;
    }
  }

  // Giriş yapma fonksiyonu
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Giriş Hatası: $e");
      return null;
    }
  }

  // Çıkış yapma fonksiyonu
  Future<void> logout() async {
    await _auth.signOut();
  }
}