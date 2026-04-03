// ── MODEL HARI LIBUR ──────────────────────────────────────────
class HariLibur {
  final String nama;

  /// false = Libur Nasional (merah), true = Cuti Bersama (oranye)
  final bool isCutiBersama;

  const HariLibur(this.nama, this.isCutiBersama);
}

// ── DATA HARI LIBUR NASIONAL INDONESIA ───────────────────────
//  Sumber: SKB 3 Menteri (Kemendagri, Kemenag, Kemenaker)
//  Coverage: 2024 · 2025 · 2026
class HariLiburIndonesia {
  static final Map<String, HariLibur> data = {
    // ── 2024 ─────────────────────────────────────────────────
    '2024-01-01': HariLibur('Tahun Baru Masehi', false),
    '2024-02-08': HariLibur('Tahun Baru Imlek 2575', false),
    '2024-02-09': HariLibur('Cuti Bersama Imlek', true),
    '2024-03-11': HariLibur('Isra Miraj Nabi Muhammad', false),
    '2024-03-12': HariLibur('Cuti Bersama Isra Miraj', true),
    '2024-03-29': HariLibur('Jumat Agung', false),
    '2024-03-31': HariLibur('Hari Paskah', false),
    '2024-04-11': HariLibur('Hari Raya Nyepi', false),
    '2024-04-08': HariLibur('Cuti Bersama Idul Fitri', true),
    '2024-04-09': HariLibur('Cuti Bersama Idul Fitri', true),
    '2024-04-10': HariLibur('Idul Fitri 1445 H', false),
    '2024-04-12': HariLibur('Idul Fitri 1445 H (2)', false),
    '2024-04-15': HariLibur('Cuti Bersama Idul Fitri', true),
    '2024-05-01': HariLibur('Hari Buruh Internasional', false),
    '2024-05-09': HariLibur('Kenaikan Isa Al-Masih', false),
    '2024-05-10': HariLibur('Cuti Bersama Kenaikan Isa', true),
    '2024-05-23': HariLibur('Hari Raya Waisak', false),
    '2024-05-24': HariLibur('Cuti Bersama Waisak', true),
    '2024-06-01': HariLibur('Hari Lahir Pancasila', false),
    '2024-06-17': HariLibur('Idul Adha 1445 H', false),
    '2024-06-18': HariLibur('Cuti Bersama Idul Adha', true),
    '2024-07-07': HariLibur('Tahun Baru Islam 1446 H', false),
    '2024-08-17': HariLibur('HUT Kemerdekaan RI ke-79', false),
    '2024-09-16': HariLibur('Maulid Nabi Muhammad SAW', false),
    '2024-12-25': HariLibur('Hari Raya Natal', false),
    '2024-12-26': HariLibur('Cuti Bersama Natal', true),

    // ── 2025 ─────────────────────────────────────────────────
    '2025-01-01': HariLibur('Tahun Baru Masehi', false),
    '2025-01-27': HariLibur('Cuti Bersama Imlek', true),
    '2025-01-28': HariLibur('Tahun Baru Imlek 2576', false),
    '2025-01-29': HariLibur('Cuti Bersama Imlek', true),
    '2025-03-28': HariLibur('Isra Miraj Nabi Muhammad', false),
    '2025-03-29': HariLibur('Hari Raya Nyepi', false),
    '2025-03-31': HariLibur('Idul Fitri 1446 H', false),
    '2025-04-01': HariLibur('Idul Fitri 1446 H (2)', false),
    '2025-04-02': HariLibur('Cuti Bersama Idul Fitri', true),
    '2025-04-03': HariLibur('Cuti Bersama Idul Fitri', true),
    '2025-04-04': HariLibur('Cuti Bersama Idul Fitri', true),
    '2025-04-07': HariLibur('Cuti Bersama Idul Fitri', true),
    '2025-04-18': HariLibur('Jumat Agung', false),
    '2025-04-20': HariLibur('Hari Paskah', false),
    '2025-05-01': HariLibur('Hari Buruh Internasional', false),
    '2025-05-12': HariLibur('Hari Raya Waisak', false),
    '2025-05-13': HariLibur('Cuti Bersama Waisak', true),
    '2025-05-29': HariLibur('Kenaikan Isa Al-Masih', false),
    '2025-05-30': HariLibur('Cuti Bersama Kenaikan Isa', true),
    '2025-06-01': HariLibur('Hari Lahir Pancasila', false),
    '2025-06-06': HariLibur('Idul Adha 1446 H', false),
    '2025-06-09': HariLibur('Cuti Bersama Idul Adha', true),
    '2025-06-27': HariLibur('Tahun Baru Islam 1447 H', false),
    '2025-08-17': HariLibur('HUT Kemerdekaan RI ke-80', false),
    '2025-09-05': HariLibur('Maulid Nabi Muhammad SAW', false),
    '2025-12-25': HariLibur('Hari Raya Natal', false),
    '2025-12-26': HariLibur('Cuti Bersama Natal', true),

    // ── 2026 ─────────────────────────────────────────────────
    '2026-01-01': HariLibur('Tahun Baru Masehi', false),
    '2026-02-17': HariLibur('Tahun Baru Imlek 2577', false),
    '2026-02-18': HariLibur('Cuti Bersama Imlek', true),
    '2026-03-19': HariLibur('Isra Miraj Nabi Muhammad', false),
    '2026-03-20': HariLibur('Hari Raya Nyepi', false),
    '2026-03-21': HariLibur('Idul Fitri 1447 H', false),
    '2026-03-22': HariLibur('Idul Fitri 1447 H (2)', false),
    '2026-03-23': HariLibur('Cuti Bersama Idul Fitri', true),
    '2026-03-24': HariLibur('Cuti Bersama Idul Fitri', true),
    '2026-03-25': HariLibur('Cuti Bersama Idul Fitri', true),
    '2026-03-26': HariLibur('Cuti Bersama Idul Fitri', true),
    '2026-04-03': HariLibur('Jumat Agung', false),
    '2026-04-05': HariLibur('Hari Paskah', false),
    '2026-05-01': HariLibur('Hari Buruh Internasional', false),
    '2026-05-14': HariLibur('Kenaikan Isa Al-Masih', false),
    '2026-05-26': HariLibur('Hari Raya Waisak', false),
    '2026-05-27': HariLibur('Cuti Bersama Waisak', true),
    '2026-05-31': HariLibur('Idul Adha 1447 H', false),
    '2026-06-01': HariLibur('Hari Lahir Pancasila', false),
    '2026-06-16': HariLibur('Tahun Baru Islam 1448 H', false),
    '2026-08-17': HariLibur('HUT Kemerdekaan RI ke-81', false),
    '2026-08-25': HariLibur('Maulid Nabi Muhammad SAW', false),
    '2026-12-25': HariLibur('Hari Raya Natal', false),
    '2026-12-26': HariLibur('Cuti Bersama Natal', true),
  };

  /// Ambil data hari libur berdasarkan tanggal.
  /// Return null jika bukan hari libur / cuti bersama.
  static HariLibur? get(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return data[key];
  }
}
