import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/study_session.dart';
import '../models/post.dart';

/// Bu sınıf, uygulamanın Veritabanı (Firestore) ve Dosya Depolama (Storage)
/// işlemlerini yönetir. Tüm veri alışverişi buradan geçer.
class FirestoreService {
  // Veritabanı örneğini oluşturuyoruz
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Dosya depolama örneğini oluşturuyoruz (Şimdilik aktif kullanılmıyor ama altyapı hazır)
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==========================================
  // 1. BÖLÜM: ÇALIŞMA OTURUMLARI (Zamanlayıcı)
  // ==========================================

  /// Tamamlanan bir çalışma oturumunu veritabanına kaydeder.
  Future<void> saveStudySession(StudySession session) async {
    await _db.collection('study_sessions').add(session.toMap());
  }

  /// Kullanıcının SADECE BUGÜN yaptığı çalışmaları getirir.
  /// Dashboard ekranındaki özet ve ilerleme çubuğu için kullanılır.
  Stream<List<StudySession>> getTodaysSessions(String userId) {
    // Bugünün başlangıç saatini (00:00) buluyoruz
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    
    return _db
        .collection('study_sessions')
        .where('userId', isEqualTo: userId) // Sadece bu kullanıcının verileri
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay)) // Sadece bugünden sonrakiler
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => StudySession.fromFirestore(doc)).toList());
  }

  /// Son 7 günün verilerini getirir.
  /// İstatistikler ekranındaki grafik için kullanılır.
  Stream<List<StudySession>> getLast7DaysSessions(String userId) {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    return _db
        .collection('study_sessions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        // Not: Index hatası almamak için orderBy kod tarafında yapılıyor.
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => StudySession.fromFirestore(doc)).toList());
  }

  // ==========================================
  // 2. BÖLÜM: HEDEF YÖNETİMİ
  // ==========================================

  /// Kullanıcının günlük çalışma hedefini (dakika cinsinden) kaydeder.
  Future<void> saveDailyGoal(String userId, int minutes) async {
    // set() metodu varsa günceller, yoksa yeni oluşturur (merge mantığı)
    await _db.collection('goals').doc(userId).set({'dailyMinutes': minutes});
  }

  /// Kullanıcının mevcut hedefini dinler (Stream).
  Stream<DocumentSnapshot> getDailyGoal(String userId) {
    return _db.collection('goals').doc(userId).snapshots();
  }

  // ==========================================
  // 3. BÖLÜM: TOPLULUK VE PAYLAŞIM
  // ==========================================
  
  /// Yeni bir topluluk mesajını veritabanına ekler.
  Future<void> savePost(Post post) async {
    await _db.collection('posts').add(post.toMap());
  }

  /// Belirtilen ID'ye sahip mesajı siler.
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  /// Tüm topluluk mesajlarını tarihe göre (yeniden eskiye) getirir.
  Stream<List<Post>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true) // En yeniler en üstte
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }
  
  // Storage işlemleri (İleride resim yükleme açılırsa kullanılacak)
  Future<String?> uploadPostImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('post_images').child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Storage Hatası: $e");
      return null;
    }
  }

  // ==========================================
  // 4. BÖLÜM: KULLANICI PROFİLİ
  // ==========================================

  /// Kullanıcının ad, bölüm ve avatar bilgilerini günceller.
  Future<void> updateUserProfile(String userId, String name, String department, String? photoUrl) async {
    await _db.collection('users').doc(userId).set({
      'name': name,
      'department': department,
      'photoUrl': photoUrl,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true)); // Mevcut diğer verileri silmeden güncelle
  }

  /// Kullanıcının profil bilgilerini getirir.
  Stream<DocumentSnapshot> getUserProfile(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }
}