# Preloft - Aplikasi Marketplace Barang Preloved

**Preloft** adalah aplikasi marketplace modern yang dibangun menggunakan **Flutter**, **Supabase** (BaaS), dan **Riverpod** (State Management). Proyek ini dirancang menggunakan arsitektur **Feature-First** yang dikombinasikan dengan prinsip **Clean Architecture** untuk menghasilkan kode yang modular, efisien, dan mudah dipelihara.

Dalam versi terbarunya, aplikasi ini telah mengimplementasikan performa query data sisi server (_Client-Side Filtering Fixes_ & _Limiters_) dan perbaikan antarmuka pengguna (_UI/UX Improvements_).

---

## Fitur Utama

- **Autentikasi Pengguna**: Sistem Login & Register aman yang terintegrasi langsung dengan Supabase Auth.
- **Manajemen Produk (CRUD)**: Pengguna dengan peran (`role`) sebagai **Penjual** dapat menambahkan, mengedit, dan menghapus produk mereka sendiri.
- **Server-Side Filtering**: Optimalisasi pengambilan data produk milik penjual langsung melalui _query_ Supabase (terhindar dari _fetching_ data berlebih).
- **Katalog Produk Responsif**: Menggunakan tampilan `GridView` untuk memaksimalkan presentasi produk di layar.
- **Sistem Fitur Interaktif**: Badge notifikasi pesan (Chat/Kotak Masuk) dan Keranjang yang intuitif dengan struktur pembuatan _widget_ yang Modular & Reusable.
- **Navigasi Modern**: Mengandalkan `GoRouter` untuk _routing_ yang presisi berbasis state.
- **State Management Handal**: Menggunakan **Riverpod** yang reaktif, sehingga UI otomatis ter-update dan _memory-leak_ terhindari (menggunakan `AutoDispose`).

## Arsitektur Proyek

Proyek ini mengadopsi struktur direktori **Feature-First**. Setiap fitur mandiri diisolasi ke dalam foldernya sendiri, memudahkan kerja kolaborasi.

```text
lib/
├── core/          # Kode inti (konfigurasi routing, tema, provider Supabase global)
├── features/      # Layer presentasi dan data masing-masing komponen
│   ├── admin/
│   ├── auth/
│   ├── cart/
│   ├── chat/
│   ├── checkout/
│   ├── product/   # (Contoh: Manajemen produk, provider produk stream)
│   └── profile/
├── shared/        # Komponen fungsional (Reusable Widget seperti Badge UI, Loading, EmptyState)
└── main.dart      # Titik masuk utama / Inisialisasi Environment Variables (DotEnv)
```

Setiap vitur dalam folder `features/` umumnya mematuhi tiga lapis (layer) **Clean Architecture**:

1. **`domain`**: Model/entitas murni (contoh: `ProductModel`, `UserModel`).
2. **`data`**: _Repository_ yang berinteraksi langsung dengan _backend_ (_Supabase client calls_).
3. **`presentation`**: UI (`screens`, `widgets`) beserta _State/Notifier_ (_Riverpod_ providers).

---

## Panduan Memulai (Getting Started)

Pastikan Anda memiliki [Flutter SDK](https://flutter.dev/docs/get-started/install) minimal versi terbaru (mendukung Material 3) dan akun [Supabase](https://supabase.com/).

### 1. Clone Repositori

```bash
git clone https://github.com/Rifki-abd/MarketPlaceprily.git
cd MarketPlaceprily
```

### 2. Konfigurasi Variabel Lingkungan (.env)

Buat sebuah file bernama `.env` di dalam folder `lib/` (pastikan nama file sesuai dengan path yang dideklarasikan di `pubspec.yaml`).
Isi file tersebut dengan _URL_ dan _Anon Key_ Supabase dari proyek database Anda:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

_(Ingat: File `.env` sudah masuk dalam `.gitignore` sehingga tidak akan terlempar ke public repository)._

### 3. Install Dependensi

Jalankan perintah berikut untuk mengunduh semua paket (`riverpod`, `supabase_flutter`, `go_router`, dll):

```bash
flutter pub get
```

### 4. Jalankan Aplikasi

Jalankan aplikasi ke emulator atau perangkat fisik Anda:

```bash
flutter run
```

---

## Linting & Kualitas Kode

Proyek ini menggunakan standar ketat dari [`very_good_analysis`](https://pub.dev/packages/very_good_analysis) untuk memastikan konsistensi (_Clean Code_).
Periksa seluruh kode sebelum melakukan _commit_:

```bash
flutter analyze
```

---

Didesain dan dikembangkan sebagai bagian dari solusi modern e-commerce preloved (Preloft).
