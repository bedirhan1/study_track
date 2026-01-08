import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'firebase_options.dart';

/// Uygulamanın Başlangıç Noktası
void main() async {
  // Flutter motorunun bağlandığından emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlatıyoruz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyTrack',
      
      // Uygulamanın genel tema ayarları
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      
      // Başlangıç rotası
      initialRoute: '/',
      
      // Sayfa rotaları
      routes: {
        '/': (context) => const LoginScreen(),       // Giriş Ekranı
        '/register': (context) => const RegisterScreen(), // Kayıt Ekranı
        '/dashboard': (context) => const DashboardScreen(), // Ana Ekran
        '/profile': (context) => const ProfileScreen(),     // Profil Ekranı
      },
    );
  }
}