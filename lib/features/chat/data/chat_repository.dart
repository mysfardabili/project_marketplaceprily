// lib/features/chat/data/chat_repository.dart

import 'package:preloft_app/features/chat/domain/chat_room_detail_model.dart';
import 'package:preloft_app/features/chat/domain/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository yang menangani semua operasi terkait chat dan pesan.
class ChatRepository {
  /// Membuat instance [ChatRepository] dengan [SupabaseClient] yang diberikan.
  ChatRepository(this._client);
  final SupabaseClient _client;

  /// Memulai sesi chat baru atau mendapatkan ID sesi chat yang sudah ada
  /// antara [buyerId] dan [sellerId] untuk produk [productId].
  Future<String> startOrGetChatRoom({
    required String buyerId,
    required String sellerId,
    required String productId,
  }) async {
    try {
      final data = await _client.rpc(
        'start_or_get_chat_room',
        params: {
          'p_buyer_id': buyerId,
          'p_seller_id': sellerId,
          'p_product_id': productId,
        },
      );
      return data as String;
    } catch (e) {
      throw Exception('Gagal memulai atau mendapatkan chat room: $e');
    }
  }

  /// Mengirim pesan ke dalam [chatRoomId] oleh [senderId].
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  }) async {
    try {
      await _client.from('messages').insert({
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'content': content,
      });
    } catch (e) {
      throw Exception('Gagal mengirim pesan: $e');
    }
  }

  /// Mereset hitungan pesan belum dibaca untuk [userId] di [chatRoomId].
  ///
  /// Operasi ini dijalankan di latar belakang; kegagalannya diabaikan.
  Future<void> resetUnreadCount({
    required String chatRoomId,
    required String userId,
  }) async {
    try {
      await _client.rpc(
        'reset_unread_count',
        params: {
          'p_chat_room_id': chatRoomId,
          'p_user_id': userId,
        },
      );
    } catch (_) {
      // Operasi latar belakang; kegagalan tidak perlu di-propagate.
    }
  }

  /// Mengembalikan stream daftar pesan dari [chatRoomId] secara realtime.
  Stream<List<Message>> getMessagesStream(String chatRoomId) {
    try {
      return _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true)
          .map((maps) => maps.map(Message.fromMap).toList());
    } catch (e) {
      throw Exception('Gagal mendapatkan stream pesan: $e');
    }
  }

  /// Mengembalikan stream daftar chat room milik pengguna yang sedang login.
  Stream<List<ChatRoomDetail>> getChatRoomListStream() {
    try {
      return _client
          .from('chat_room_details')
          .stream(primaryKey: ['id'])
          .order('last_message_at')
          .map((maps) => maps.map(ChatRoomDetail.fromMap).toList());
    } catch (e) {
      throw Exception('Gagal mendapatkan daftar chat: $e');
    }
  }
}
