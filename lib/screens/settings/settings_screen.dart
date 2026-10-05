import 'package:flutter/material.dart';
import '../../chess/models/piece.dart';
import '../../chess/models/piece_color.dart';
import '../../chess/models/piece_type.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/board_themes.dart';
import '../../core/utils/sound_service.dart';
import '../../storage/local_storage.dart';
import '../../widgets/chess_piece_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentThemeId = 'wood';
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _showLegalMoves = true;
  bool _showCoordinates = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await LocalStorage.getThemeId();
    final sound = await LocalStorage.getSoundEnabled();
    final haptic = await LocalStorage.getHapticEnabled();
    final moves = await LocalStorage.getShowLegalMoves();
    final coords = await LocalStorage.getShowCoordinates();

    if (mounted) {
      setState(() {
        _currentThemeId = theme;
        _soundEnabled = sound;
        _hapticEnabled = haptic;
        _showLegalMoves = moves;
        _showCoordinates = coords;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13151B),
      appBar: AppBar(
        title: const Text('Cài Đặt'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Board Section
            _SectionHeader(title: 'BÀN CỜ & HIỂN THỊ'),
            Card(
              child: Column(
                children: [
                  // Theme Picker
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giao diện bàn cờ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: BoardThemeData.allThemes.map((theme) {
                            final isSel = _currentThemeId == theme.id;
                            return InkWell(
                              onTap: () {
                                setState(() => _currentThemeId = theme.id);
                                LocalStorage.setThemeId(theme.id);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFFE5A93C) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // 2x2 miniature board preview with themed pieces
                                    Container(
                                      width: 48,
                                      height: 48,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    color: theme.lightSquare,
                                                    alignment: Alignment.center,
                                                    child: ChessPieceWidget(
                                                      piece: const Piece(PieceType.pawn, PieceColor.black),
                                                      size: 18,
                                                      theme: theme,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    color: theme.darkSquare,
                                                    alignment: Alignment.center,
                                                    child: ChessPieceWidget(
                                                      piece: const Piece(PieceType.knight, PieceColor.white),
                                                      size: 18,
                                                      theme: theme,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(child: Container(color: theme.darkSquare)),
                                                Expanded(child: Container(color: theme.lightSquare)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      theme.name.split(' ').first,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                        color: isSel ? const Color(0xFFE5A93C) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0x1AFFFFFF), height: 1),

                  SwitchListTile(
                    title: const Text('Gợi ý nước đi hợp lệ'),
                    subtitle: const Text('Hiển thị dấu chấm tại các ô có thể đi'),
                    value: _showLegalMoves,
                    activeThumbColor: const Color(0xFFE5A93C),
                    onChanged: (val) {
                      setState(() => _showLegalMoves = val);
                      LocalStorage.setShowLegalMoves(val);
                    },
                  ),
                  const Divider(color: Color(0x1AFFFFFF), height: 1),

                  SwitchListTile(
                    title: const Text('Hiển thị tọa độ ô cờ'),
                    subtitle: const Text('Các ký hiệu a-h và 1-8 trên viền bàn cờ'),
                    value: _showCoordinates,
                    activeThumbColor: const Color(0xFFE5A93C),
                    onChanged: (val) {
                      setState(() => _showCoordinates = val);
                      LocalStorage.setShowCoordinates(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sound & Haptic Section
            _SectionHeader(title: 'ÂM THANH & RUNG PHẢN HỒI'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Âm thanh nước đi'),
                    subtitle: const Text('Phát âm thanh khi đi quân, ăn quân hoặc chiếu tướng'),
                    value: _soundEnabled,
                    activeThumbColor: const Color(0xFFE5A93C),
                    onChanged: (val) {
                      setState(() => _soundEnabled = val);
                      LocalStorage.setSoundEnabled(val);
                      SoundService().soundEnabled = val;
                    },
                  ),
                  const Divider(color: Color(0x1AFFFFFF), height: 1),

                  SwitchListTile(
                    title: const Text('Rung phản hồi (Haptic)'),
                    subtitle: const Text('Rung nhẹ khi chạm và di chuyển quân cờ'),
                    value: _hapticEnabled,
                    activeThumbColor: const Color(0xFFE5A93C),
                    onChanged: (val) {
                      setState(() => _hapticEnabled = val);
                      LocalStorage.setHapticEnabled(val);
                      SoundService().hapticEnabled = val;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About & Licenses Section
            _SectionHeader(title: 'THÔNG TIN & BẢN QUYỀN MÃ NGUỒN MỞ'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Phiên bản ứng dụng'),
                    trailing: const Text(
                      AppConstants.appVersion,
                      style: TextStyle(color: Color(0xFFE5A93C), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(color: Color(0x1AFFFFFF), height: 1),
                  ListTile(
                    title: const Text('Giấy phép Stockfish (GPLv3)'),
                    subtitle: const Text('Xem điều khoản sử dụng động cơ Stockfish'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Stockfish Open Source License'),
                          content: const SingleChildScrollView(
                            child: SelectableText(
                              AppConstants.stockfishNotice,
                              style: TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('ĐÓNG'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color(0x1AFFFFFF), height: 1),
                  ListTile(
                    title: const Text('Bản quyền thư viện mã nguồn mở'),
                    subtitle: const Text('Flutter, Dart & các thành phần phụ thuộc'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
