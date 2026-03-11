// lib/features/auth/data/auth_repository.dart

import 'dart:async';

import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository yang menangani semua operasi autentikasi
/// menggunakan Supabase sebagai backend.
class AuthRepository {
  /// Membuat instance [AuthRepository] dengan [SupabaseClient] yang diberikan.
  AuthRepository(this._client);
  final SupabaseClient _client;

  /// Stream yang memancarkan perubahan state autentikasi pengguna.
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange
          .map((data) => data.session?.user);

  /// Mengembalikan pengguna yang sedang login, atau `null` jika belum login.
  User? get currentUser => _client.auth.currentUser;

  /// Mengambil profil pengguna berdasarkan [userId] secara realtime.
  ///
  /// Mengembalikan [UserModel] jika ditemukan, atau `null` jika tidak ada.
  Stream<UserModel?> getUserProfile(String userId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .limit(1)
        .map(
          (data) => data.isEmpty ? null : UserModel.fromMap(data.first),
        )
        .handleError((Object error) {
          return null;
        });
  }

  /// Mendaftarkan pengguna baru dengan [email], [password], [name],
  /// [role], dan opsional [waNumber].
  ///
  /// Melempar [Exception] jika pendaftaran gagal.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? waNumber,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role.name,
          'wa_number': waNumber,
        },
      );
    } on AuthException catch (e) {
      throw Exception('Gagal mendaftar: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat mendaftar.');
    }
  }

  /// Login menggunakan [email] dan [password].
  ///
  /// Melempar [Exception] jika login gagal.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception('Gagal login: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat login.');
    }
  }

  /// Mengirim email reset password ke alamat [email].
  ///
  /// Melempar [Exception] jika pengiriman gagal.
  Future<void> resetPasswordForEmail({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Gagal mengirim email reset: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga.');
    }
  }

  /// Mengubah password pengguna yang sedang login menjadi [newPassword].
  ///
  /// Melempar [Exception] jika perubahan password gagal.
  Future<void> changePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Gagal mengubah password: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga.');
    }
  }

  /// Melakukan logout untuk pengguna yang sedang login.
  ///
  /// Melempar [Exception] jika logout gagal.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Gagal logout: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat logout.');
    }
  }
}
