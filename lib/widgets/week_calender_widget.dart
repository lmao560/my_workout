// ============================================================
//  FILE: lib/widgets/week_calendar_widget.dart
//
//  Cara pakai di halaman manapun:
//
//  import 'package:YOUR_PACKAGE_NAME/widgets/week_calendar_widget.dart';
//
//  // Taruh di mana saja dalam widget tree:
//  WeekCalendarWidget()
//
//  // Dengan callback saat tanggal dipilih:
//  WeekCalendarWidget(
//    onDateSelected: (date) {
//      print('Tanggal dipilih: $date');
//    },
//  )
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workout_app/helpers/hari_libur_indonesia.dart';

class WeekCalendarWidget extends StatefulWidget {
  /// Callback opsional — dipanggil setiap kali user memilih tanggal
  final void Function(DateTime selectedDate)? onDateSelected;

  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showInfoCard;

  const WeekCalendarWidget({
    super.key,
    this.onDateSelected,
    this.height,
    this.padding,
    this.margin,
    this.showInfoCard = true,
  });

  @override
  State<WeekCalendarWidget> createState() => _WeekCalendarWidgetState();
}

class _WeekCalendarWidgetState extends State<WeekCalendarWidget> {
  late DateTime _weekStart;
  DateTime? _selectedDate;

  static const List<String> _bulanIndo = [
    'JANUARI',
    'FEBRUARI',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
    'AGUSTUS',
    'SEPTEMBER',
    'OKTOBER',
    'NOVEMBER',
    'DESEMBER',
  ];

  static const List<String> _bulanIndoPanjang = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _hariNames = [
    'MIN',
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB'
  ];

  static const List<String> _hariPanjang = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Otomatis dimulai dari hari Minggu di minggu berjalan (real-time)
    _weekStart = now.subtract(Duration(days: now.weekday % 7));
    _selectedDate = now;
  }

  // ── Navigasi Minggu ───────────────────────────────────────
  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));

  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  // ── Label bulan di header ─────────────────────────────────
  String _getMonthLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    if (_weekStart.month == end.month) {
      return '${_bulanIndo[_weekStart.month - 1]} ${_weekStart.year}';
    }
    // Lintas bulan
    return '${_bulanIndo[_weekStart.month - 1]} / '
        '${_bulanIndo[end.month - 1]} ${end.year}';
  }

  // ── Helper ────────────────────────────────────────────────
  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isSelected(DateTime d) =>
      _selectedDate != null &&
      d.year == _selectedDate!.year &&
      d.month == _selectedDate!.month &&
      d.day == _selectedDate!.day;

  void _onTapDate(DateTime date) {
    setState(() => _selectedDate = date);
    widget.onDateSelected?.call(date);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCalendarCard(),
        const SizedBox(height: 14),
        if (widget.showInfoCard && _selectedDate != null)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _InfoCard(
              date: _selectedDate!,
              bulanPanjang: _bulanIndoPanjang,
              hariPanjang: _hariPanjang,
              margin: widget.margin,
              padding: widget.padding,
              key: ValueKey(_selectedDate),
            ),
          ),
      ],
    );
  }

  // ── Card Kalender ─────────────────────────────────────────
  Widget _buildCalendarCard() {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 20),
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1AF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF000000), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Nama Bulan ──────────────────────────────────
          Text(
            _getMonthLabel(),
            style: GoogleFonts.russoOne(
              color: Color(0xFFCC0000),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),

          // ── Header: < | Nama Hari | > ───────────────────
          Row(
            children: [
              _NavButton(icon: '<', onTap: _prevWeek),
              Expanded(
                child: Row(
                  children: List.generate(
                      7,
                      (i) => Expanded(
                            child: Text(
                              _hariNames[i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.russoOne(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: i == 0
                                    ? const Color(0xFFCC0000) // Minggu merah
                                    : i == 5
                                        ? const Color(0xFF006600) // Jumat hijau
                                        : i == 6
                                            ? const Color(
                                                0xFF0055CC) // Sabtu biru
                                            : const Color(0xFF555555),
                              ),
                            ),
                          )),
                ),
              ),
              _NavButton(icon: '>', onTap: _nextWeek),
            ],
          ),
          const SizedBox(height: 6),

          // ── Baris Tanggal ───────────────────────────────
          Row(
            children: [
              const SizedBox(width: 32), // spacer kiri
              Expanded(child: _buildDateRow()),
              const SizedBox(width: 32), // spacer kanan
            ],
          ),

          const Divider(color: Color(0xFF000000), height: 16, thickness: 1),

          // ── Legend ──────────────────────────────────────
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Color(0xFFCC0000), label: 'Libur Nasional'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFFF8800), label: 'Cuti Bersama'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Row tanggal Masehi ────────────────────────────────────
  Widget _buildDateRow() {
    return Row(
      children: List.generate(7, (i) {
        final date = _weekStart.add(Duration(days: i));
        final today = _isToday(date);
        final selected = _isSelected(date);
        final libur = HariLiburIndonesia.get(date);
        final isLibur = libur != null && !libur.isCutiBersama;
        final isCuti = libur != null && libur.isCutiBersama;

        // Warna angka tanggal
        Color textColor;
        if (selected) {
          textColor = Colors.white;
        } else if (isLibur || i == 0) {
          textColor = const Color(0xFFCC0000);
        } else if (isCuti) {
          textColor = const Color(0xFFFF8800);
        } else if (i == 5) {
          textColor = const Color(0xFF006600);
        } else if (i == 6) {
          textColor = const Color(0xFF0055CC);
        } else {
          textColor = const Color(0xFF333333);
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => _onTapDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE62727)
                    : today
                        ? const Color(0xFFFDFCFC)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: selected
                    ? Border.all(color: Colors.black, width: 2)
                    : today
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                boxShadow: selected
                    ? [
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(2, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : today
                        ? [
                            const BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 3),
                              blurRadius: 0,
                            ),
                          ]
                        : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: GoogleFonts.russoOne(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  if (libur != null && !selected)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: isLibur
                            ? const Color(0xFFB22222)
                            : const Color(0xFFD97706),
                        border: Border.all(color: Colors.black, width: 1),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// =============================================================
//  INFO CARD — Detail tanggal yang dipilih
// =============================================================
class _InfoCard extends StatelessWidget {
  final DateTime date;
  final List<String> bulanPanjang;
  final List<String> hariPanjang;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const _InfoCard({
    required this.date,
    required this.bulanPanjang,
    required this.hariPanjang,
    this.padding,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final libur = HariLiburIndonesia.get(date);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 100),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1AF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF000000), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal Masehi
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: Color(0xFFCC0000)),
              const SizedBox(width: 8),
              Text(
                '${hariPanjang[date.weekday % 7]}, '
                '${date.day} ${bulanPanjang[date.month - 1]} ${date.year}',
                style: GoogleFonts.russoOne(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),

          // Badge hari libur (jika ada)
          if (libur != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: libur.isCutiBersama
                    ? const Color(0xFFF8C471)
                    : const Color(0xFFE6B0AA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 2,
                  color: libur.isCutiBersama
                      ? const Color(0xFF000000)
                      : const Color(0xFF000000),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    libur.isCutiBersama
                        ? Icons.event_available
                        : Icons.flag_rounded,
                    size: 14,
                    color: libur.isCutiBersama
                        ? const Color(0xFFD97706)
                        : const Color(0xFFB22222),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    libur.nama,
                    style: GoogleFonts.russoOne(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: libur.isCutiBersama
                          ? const Color(0xFF3E2723)
                          : const Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
//  NAV BUTTON  ( < dan > )
// =============================================================
class _NavButton extends StatefulWidget {
  final String icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFFE0C68F) // warna saat ditekan
              : const Color(0xFFFDE7B3), // warna utama (yang kamu mau)

          borderRadius: BorderRadius.circular(6),

          border: Border.all(
            color: Colors.black, // 🔥 border hitam pekat
            width: 2,
          ),

          boxShadow: _pressed
              ? []
              : [
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 2), // arah bayangan
                    blurRadius: 0, // biar tajam (retro)
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.icon,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
//  LEGEND DOT
// =============================================================
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.russoOne(
            fontSize: 9,
            color: color,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
