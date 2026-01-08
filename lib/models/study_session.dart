import 'package:cloud_firestore/cloud_firestore.dart';

/// Çalışma Oturumu Modeli
/// Veritabanındaki 'study_sessions' koleksiyonundaki her bir belgeyi temsil eder.
class StudySession {
  final String? id;          // Belge ID'si
  final String userId;       // Hangi kullanıcıya ait?
  final DateTime date;       // Ne zaman çalışıldı?
  final int durationInSeconds; // Kaç saniye sürdü?
  final String subject;      // Hangi ders çalışıldı?

  StudySession({
    this.id,
    required this.userId,
    required this.date,
    required this.durationInSeconds,
    required this.subject,
  });

  /// Nesneyi JSON formatına (Map) çevirir. 
  /// Veritabanına yazarken kullanılır.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date), // DateTime'ı Firestore Timestamp'e çevirir
      'durationInSeconds': durationInSeconds,
      'subject': subject,
    };
  }

  /// Veritabanından gelen veriyi (DocumentSnapshot) nesneye çevirir.
  /// Veritabanından okurken kullanılır.
  factory StudySession.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return StudySession(
      id: doc.id,
      userId: data['userId'] ?? '',
      // Firestore Timestamp'i tekrar Dart DateTime'a çevirir
      date: (data['date'] as Timestamp).toDate(),
      durationInSeconds: data['durationInSeconds'] ?? 0,
      subject: data['subject'] ?? 'Bilinmiyor',
    );
  }
}