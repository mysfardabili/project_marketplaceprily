// lib/features/product/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:preloft_app/features/chat/presentation/providers/chat_provider.dart'; // Import chat provider
import 'package:preloft_app/features/product/presentation/providers/product_provider.dart';
import 'package:preloft_app/features/product/presentation/widgets/product_card.dart';
import 'package:preloft_app/shared/widgets/empty_state_widget.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';
import 'package:preloft_app/shared/widgets/badge_icon_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsStreamProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final cartItemCount = ref.watch(cartItemCountProvider);
    final totalUnreadMessages = ref.watch(totalUnreadMessagesProvider); // Tonton total pesan belum dibaca

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preloft'),
        actions: [
          BadgeIconButton(
            icon: Icons.chat_bubble_outline,
            tooltip: 'Kotak Masuk',
            onPressed: () => context.push('/chats'),
            badgeCount: totalUnreadMessages,
          ),
          BadgeIconButton(
            icon: Icons.shopping_cart_outlined,
            tooltip: 'Keranjang',
            onPressed: () => context.push('/cart'),
            badgeCount: cartItemCount,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return EmptyStateWidget(
              title: 'Belum Ada Produk',
              message: 'Jadilah yang pertama untuk menjual barang di sini!',
              icon: Icons.storefront,
              onRefresh: () => ref.invalidate(allProductsStreamProvider),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allProductsStreamProvider),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Disesuaikan agar card tidak terpotong
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => ProductCard(
                product: products[index],
                margin: EdgeInsets.zero, // Gunakan spacing dari GridView
              ),
            ),
          );
        },
        loading: () => const Center(child: LoadingWidget(message: 'Memuat produk...')),
        error: (err, stack) => Center(
          child: EmptyStateWidget(
            title: 'Oops, Terjadi Kesalahan',
            message: err.toString(),
            icon: Icons.error_outline,
            onRefresh: () => ref.invalidate(allProductsStreamProvider),
          ),
        ),
      ),
      floatingActionButton: userProfile?.role == UserRole.penjual
          ? FloatingActionButton(
              onPressed: () => context.push('/add-product'),
              tooltip: 'Tambah Produk',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
