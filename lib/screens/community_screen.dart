import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/post.dart';

/// Topluluk Ekranı
/// Kullanıcıların mesaj paylaşabildiği ve birbirlerinin mesajlarını görebildiği sosyal alan.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _messageController = TextEditingController();
  bool _isSharing = false;

  /// Mesaj gönderme işlemi
  void _sharePost() async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isSharing = true);

    // 1. Adım: Mesajın yanında doğru kişinin gözükmesi için veritabanından kullanıcının güncel adını ve avatarını çekiyoruz.

    final userSnapshot = await _firestoreService.getUserProfile(_authService.currentUserId!).first;
    String currentUserName = "Öğrenci";
    String? currentUserAvatar;

    if (userSnapshot.exists) {
      final data = userSnapshot.data() as Map<String, dynamic>;
      currentUserName = data['name'] ?? "Öğrenci";
      currentUserAvatar = data['photoUrl'];
    }

    // 2. Adım: Post nesnesini oluşturup kaydediyoruz.
    final post = Post(
      userId: _authService.currentUserId!, // Mesajın sahibi
      userName: currentUserName,
      userAvatarUrl: currentUserAvatar,
      message: _messageController.text,
      createdAt: DateTime.now(),
    );

    await _firestoreService.savePost(post);
    _messageController.clear();
    setState(() => _isSharing = false);
  }

  /// Silme işlemi için onay penceresi gösterir.
  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mesajı Sil"),
        content: const Text("Bu mesajı silmek istediğine emin misin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              await _firestoreService.deletePost(postId);
              Navigator.of(ctx).pop(); // Pencereyi kapat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mesaj silindi.")),
              );
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUserId; // O anki kullanıcının ID'si

    return Scaffold(
      appBar: AppBar(title: const Text("Topluluk Akışı")),
      body: Column(
        children: [
          // Üst kısım: Mesaj yazma alanı
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Bugün neler çalıştın? Paylaş...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _isSharing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.send, color: Colors.indigo),
                      onPressed: _sharePost,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Alt kısım: Mesaj listesi
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: _firestoreService.getPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final posts = snapshot.data!;
                if (posts.isEmpty) return const Center(child: Text("Henüz kimse bir şey yazmadı. İlk sen ol!"));

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    
                    // Yetkilendirme Kontrolü (Mesajın sahibi olup olmadığını kontrol eder)
                    final isMyPost = post.userId == currentUserId;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      // Kendi mesajlarımızı ayırt etmek için hafif renk tonu veriyoruz
                      color: isMyPost ? Colors.indigo.shade50 : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: post.userAvatarUrl != null
                                ? CircleAvatar(backgroundImage: NetworkImage(post.userAvatarUrl!))
                                : const CircleAvatar(child: Icon(Icons.person)), 
                            title: Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              "${post.createdAt.day}.${post.createdAt.month}.${post.createdAt.year} • ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            // Sadece mesaj sahibi silme butonunu görebilir
                            trailing: isMyPost 
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(post.id!),
                                )
                              : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            child: Text(post.message, style: const TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}