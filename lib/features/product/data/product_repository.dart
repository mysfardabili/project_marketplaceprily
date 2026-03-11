// lib/features/product/data/product_repository.dart

import 'dart:typed_data';

import 'package:preloft_app/features/product/domain/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository yang menangani semua operasi CRUD untuk produk.
class ProductRepository {
  /// Membuat instance [ProductRepository] dengan [SupabaseClient] yang diberikan.
  ProductRepository(this._client);
  final SupabaseClient _client;

  /// Mengunggah gambar produk menggunakan kontennya [imageBytes].
  ///
  /// Mengembalikan URL publik gambar yang berhasil diunggah.
  Future<String> uploadProductImage({
    required Uint8List imageBytes,
    required String fileName,
    required String productId,
  }) async {
    try {
      final imageExtension = fileName.split('.').last.toLowerCase();
      final mimeTypeExtension =
          imageExtension == 'jpg' ? 'jpeg' : imageExtension;
      final uploadPath = '/$productId/product.$imageExtension';

      await _client.storage.from('product-images').uploadBinary(
            uploadPath,
            imageBytes,
            fileOptions: FileOptions(
              contentType: 'image/$mimeTypeExtension',
              upsert: true,
            ),
          );

      return _client.storage
          .from('product-images')
          .getPublicUrl(uploadPath);
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  /// Membuat produk baru di database dengan [data] yang diberikan.
  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      await _client.from('products').insert(data);
    } catch (e) {
      throw Exception('Gagal membuat produk: $e');
    }
  }

  /// Mengembalikan stream semua produk yang tersedia, dibatasi 100 item.
  Stream<List<ProductModel>> getAllProductsStream() {
    try {
      return _client
          .from('products')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .limit(100)
          .map((data) => data.map(ProductModel.fromMap).toList());
    } catch (e) {
      return Stream.error(Exception('Gagal mengambil data produk: $e'));
    }
  }

  /// Mengembalikan stream produk milik pengguna dengan [userId].
  Stream<List<ProductModel>> getMyProductsStream(String userId) {
    try {
      return _client
          .from('products')
          .stream(primaryKey: ['id'])
          .eq('seller_id', userId)
          .order('created_at')
          .map((data) => data.map(ProductModel.fromMap).toList());
    } catch (e) {
      return Stream.error(
        Exception('Gagal mengambil data produk saya: $e'),
      );
    }
  }

  /// Memperbarui produk dengan [productId] menggunakan [data] yang diberikan.
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _client.from('products').update(data).eq('id', productId);
    } catch (e) {
      throw Exception('Gagal memperbarui produk: $e');
    }
  }

  /// Menghapus produk dengan [productId] dari database.
  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }
}
