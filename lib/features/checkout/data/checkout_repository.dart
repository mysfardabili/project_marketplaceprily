// lib/features/checkout/data/checkout_repository.dart

import 'package:preloft_app/features/cart/domain/cart_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository yang menangani proses checkout dan pembuatan pesanan.
class CheckoutRepository {
  /// Membuat instance [CheckoutRepository] dengan [SupabaseClient] yang diberikan.
  CheckoutRepository(this._client);
  final SupabaseClient _client;

  /// Membuat pesanan dari [cartItems] melalui fungsi RPC Supabase.
  ///
  /// Menggunakan transaksi database untuk memastikan konsistensi data.
  /// Mengembalikan ID pesanan yang baru dibuat.
  Future<String> createOrderFromCart(
    List<CartItem> cartItems,
    double totalPrice,
    String userId,
  ) async {
    try {
      final itemsJson = cartItems
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price_per_item': item.product.price,
              })
          .toList();

      final orderId = await _client.rpc(
        'create_order_from_cart',
        params: {
          'p_user_id': userId,
          'p_total_price': totalPrice,
          'p_items': itemsJson,
        },
      );

      return orderId as String;
    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }
}
