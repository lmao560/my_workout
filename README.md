# 💪 My Workout App

Aplikasi workout personal berbasis Flutter yang dirancang untuk membantu pengguna mengelola rutinitas olahraga sehari-hari dengan tampilan retro yang unik dan pengalaman pengguna yang menyenangkan.

---

## 📱 Tampilan & Tema

Aplikasi ini menggunakan tema **neo-brutalist retro** dengan karakteristik:
- Warna dominan cream (`#FDE7B3`) dengan aksen merah, hijau, dan teal
- Border hitam tebal dengan shadow offset untuk efek retro
- Font **Russo One** untuk teks umum dan **Press Start 2P** untuk judul
- Animasi tombol arcade — tombol "turun" saat ditekan seperti tombol arcade fisik
- Sound effect untuk setiap interaksi (klik tombol, mulai exercise, rest, selesai)

---

## ✨ Fitur Utama

### 🏋️ Custom Workout Builder
- Buat workout dengan nama dan kumpulan exercise
- Setiap exercise dapat dikonfigurasi:
  - **Repetition** — jumlah set dan repetisi per set
  - **Duration** — jumlah set dan durasi per set (dalam detik)
  - Rest time antar set
- Drag & drop untuk mengubah urutan exercise
- Edit dan hapus exercise
- Duplikasi workout yang sudah ada (Copy)
- Preview isi workout sebelum dijalankan

### ▶️ Workout Session
- Pilih exercise mana saja yang ingin dijalankan (tidak harus berurutan)
- Flow per exercise:
- Timer countdown dengan tampilan flip clock (HH:MM:SS)
- Indikator sisa set dengan dot visual
- Tombol **Skip Rest** untuk melewati waktu istirahat
- Tampilan celebration saat exercise selesai (dengan foto retro frame)
- Tombol **Complete** aktif hanya setelah semua exercise diselesaikan

### 📋 History
- Riwayat semua workout yang telah diselesaikan
- Informasi per sesi: tanggal, jam, dan total durasi
- Detail exercise per sesi (expand/collapse)
- Hapus history yang tidak diperlukan

### ✅ Validasi
- Nama workout tidak boleh duplikat
- Minimal 3 exercise per workout
- Nama exercise tidak boleh kosong
- Minimal sets, reps, dan durasi
- Konfirmasi saat keluar dari form yang belum disimpan
- Konfirmasi saat keluar dari exercise yang sedang berjalan

---

## 🔊 Sound Effects

| Sound | Trigger |
|---|---|
| Button Click | Setiap tombol ditekan |
| Start Exercise | Tombol Start exercise |
| Rest Start | Masuk fase istirahat |
| Countdown | 3 detik terakhir timer |
| Rest End | Timer istirahat selesai |
| Exercise Done | Exercise selesai |
| Complete | Workout selesai |
| Save | Simpan exercise |
| Create | Buat/update workout |
| Typing | Saat mengetik di field input |

---

## 🗄️ Storage & Database

### Arsitektur — Repository Pattern

Semua akses data dilakukan melalui abstract interface:
```dart
abstract class WorkoutRepository {
  Future<List<Workout>> getAll();
  Future<Workout?> getById(String id);
  Future<void> save(Workout workout);
  Future<void> delete(String id);
}
```

Interface yang sama diterapkan untuk:
- `WorkoutRepository` — data workout
- `WorkoutPlanRepository` — jadwal workout
- `HistoryRepository` — riwayat sesi

### Implementasi — Hive

Aplikasi menggunakan **Hive** sebagai local database:
- Data tersimpan permanen di storage internal HP
- Data tetap ada meskipun app ditutup atau HP di-restart
- Tidak memerlukan koneksi internet

Tiga box Hive yang digunakan:

| Box | Isi |
|---|---|
| `workouts` | Semua data workout yang dibuat user |
| `plans` | Data jadwal workout |
| `history` | Riwayat sesi yang diselesaikan |

### Serialization

Semua model sudah memiliki `toJson()` dan `fromJson()` untuk kompatibilitas dengan Hive maupun storage lain di masa depan.

### Migrasi Storage

Karena menggunakan repository pattern, mengganti storage hanya perlu mengubah 1 baris di `main.dart`:
```dart
// Ganti ini:
final workoutRepo = HiveWorkoutRepository();

// Menjadi implementasi lain, misalnya SQLite:
final workoutRepo = SqliteWorkoutRepository();
```

Tidak ada perubahan di controller atau UI.

---

## 🏗️ Arsitektur Kode
lib/
├── models/
│   ├── exercise.dart       # Exercise, ExerciseType
│   ├── workout.dart        # Workout
│   ├── schedule.dart       # ScheduledWorkout, WorkoutPlan, Weekday
│   ├── session.dart        # ExerciseProgress, WorkoutSession
│   ├── history.dart        # WorkoutHistory, ExerciseResult
│   └── models.dart         # Barrel export
│
├── repository/
│   ├── repository.dart          # Abstract interfaces
│   ├── in_memory_repository.dart # Implementasi sementara (dev)
│   └── hive_repository.dart     # Implementasi permanen (production)
│
├── services/
│   ├── timer_service.dart  # Countdown timer reusable
│   ├── sound_service.dart  # Audio playback
│   └── id_services.dart    # ID generation
│
├── controllers/
│   ├── workout_controller.dart         # Session logic
│   ├── workout_builder_controller.dart # Create/edit workout
│   ├── workout_list_controller.dart    # CRUD list workout
│   ├── history_controller.dart         # History management
│   └── schedule_controller.dart        # Schedule management
│
├── screens/
│   ├── builder/
│   │   ├── workout_list_screen.dart    # Daftar workout
│   │   └── workout_builder_screen.dart # Form buat/edit workout
│   ├── session/
│   │   ├── workout_session_screen.dart # List exercise dalam session
│   │   └── exercise_active_screen.dart # Timer & flow exercise aktif
│   └── history/
│       └── history_screen.dart         # Riwayat workout
│
└── widgets/
├── animated_button.dart      # Tombol dengan animasi arcade
└── week_calender_widget.dart # Widget kalender mingguan

### State Management

Menggunakan **Provider** dengan **ChangeNotifier** — sederhana, built-in, tanpa dependency berat.

### Flow Session
[ACTIVE]
├── Repetition → tunggu onNextSet()
└── Duration   → TimerService auto-jalan
│
▼
[RESTING] → timer habis
│
▼
isLastSet?
├── Tidak → set berikutnya → [ACTIVE]
└── Ya    → [WAITING FINISH] → user tap FINISH → [COMPLETED]

---

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework utama |
| Dart | Bahasa pemrograman |
| Provider | State management |
| Hive | Local database |
| audioplayers | Sound effects |
| google_fonts | Typography |
| flutter_launcher_icons | App icon generator |

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK >= 3.0.0
- Android SDK >= 34
- Device Android atau emulator

### Langkah
```bash
# Clone repository
git clone https://github.com/lmao560/my_workout.git

# Masuk ke folder project
cd my_workout

# Install dependencies
flutter pub get

# Jalankan app
flutter run
```

### Build APK Release
```bash
flutter build apk --release
```
APK tersimpan di:
build/app/outputs/flutter-apk/app-release.apk
---

## 📦 Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  audioplayers: ^5.2.1
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
  flutter_launcher_icons: ^0.13.1
```

---

## 🔮 Pengembangan Selanjutnya

Fitur yang dapat dikembangkan di masa depan:

- [ ] **Progress tracking** — grafik perkembangan workout per minggu
- [ ] **Notifikasi** — reminder jadwal workout
- [ ] **Export history** — simpan history sebagai PDF
- [ ] **Dark mode** — tema gelap
- [ ] **Workout sharing** — bagikan workout ke pengguna lain
- [ ] **Rest time skip dengan animasi** — transisi lebih halus
- [ ] **Custom rest time per exercise** — rest time berbeda tiap exercise

---

## 👤 Developer

Dibuat oleh **lmao560**

---

*Dibuat dengan Flutter 💙*
