import 'package:cloud_firestore/cloud_firestore.dart';

/// Topluluk Gönderi Modeli
/// Topluluk ekranında paylaşılan her bir mesajın veri yapısını tanımlar.
/// Veritabanı (Firestore) ile Uygulama (Flutter) arasındaki veri dönüşümlerini yönetir.
class Post {
  final String? id;          // Gönderinin veritabanındaki benzersiz kimliği (Silme işlemi için gerekli)
  final String userId;       // Gönderiyi paylaşan kullanıcının ID'si (Kendi mesajını silme kontrolü için)
  final String userName;     // Gönderen kişinin o anki adı
  final String? userAvatarUrl; // Gönderen kişinin profil avatar URL'i
  final String message;      // Gönderinin metin içeriği
  final String? imageUrl;    // Gönderiye eklenen resim URL'i
  final DateTime createdAt;  // Gönderilme zamanı

  Post({
    this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.message,
    this.imageUrl,
    required this.createdAt,
  });

  /// Nesneyi JSON/Map formatına çevirir.
  /// Uygulamadan Veritabanına veri gönderirken kullanılır.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'message': message,
      'imageUrl': imageUrl,
      // Dart DateTime objesini, Firestore'un anlayacağı Timestamp formatına çeviriyoruz
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Veritabanından gelen veriyi Nesneye çevirir.
  /// Veritabanından veri okurken kullanılır.
  factory Post.fromFirestore(DocumentSnapshot doc) {
    // Veriyi Map (Anahtar-Değer) yapısı olarak alıyoruz
    Map data = doc.data() as Map;
    
    return Post(
      id: doc.id, // Belge ID'sini ayrıca alıyoruz
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonim', // Eğer isim verisi bozuksa varsayılan ata
      userAvatarUrl: data['userAvatarUrl'],
      message: data['message'] ?? '',
      imageUrl: data['imageUrl'],
      // Firestore Timestamp formatını tekrar uygulamanın kullanacağı DateTime formatına çeviriyoruz
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}