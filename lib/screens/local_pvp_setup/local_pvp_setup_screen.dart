import 'package:flutter/material.dart';
import '../../chess/game/game_phase.dart';
import '../../chess/models/piece_color.dart';
import '../game/game_screen.dart';

class LocalPvpSetupScreen extends StatefulWidget {
  const LocalPvpSetupScreen({super.key});

  @override
  State<LocalPvpSetupScreen> createState() => _LocalPvpSetupScreenState();
}

class _LocalPvpSetupScreenState extends State<LocalPvpSetupScreen> {
  PieceColor _p1Color = PieceColor.white;
  int _selectedTimeMinutes = 10;
  bool _autoFlipBoard = true;

  static const List<int> timeOptions = [0, 3, 5, 10, 15];

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GameScreen(
          gameMode: GameMode.localPvp,
          playerColor: _p1Color,
          timeControlMinutes: _selectedTimeMinutes,
          autoFlipPvp: _autoFlipBoard,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p2Color = _p1Color.opposite;

    return Scaffold(
      backgroundColor: const Color(0xFF13151B),
      appBar: AppBar(
        title: const Text('2 Người Chơi (Offline PvP)'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'THIẾT LẬP VÁN ĐẤU 2 NGƯỜI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),

              // Player 1 & Player 2 cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      // Player 1
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF13151B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x33E5A93C)),
                            ),
                            child: Center(
                              child: Text(
                                _p1Color == PieceColor.white ? '♔' : '♚',
                                style: const TextStyle(fontSize: 28, color: Color(0xFFE5A93C)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Người chơi 1',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                ),
                                Text(
                                  'Cầm quân ${_p1Color.displayName}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_vert_rounded, color: Color(0xFFE5A93C), size: 26),
                            tooltip: 'Đổi màu quân',
                            onPressed: () {
                              setState(() {
                                _p1Color = _p1Color.opposite;
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(color: Color(0x1AFFFFFF), height: 24),

                      // Player 2
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF13151B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x33E5A93C)),
                            ),
                            child: Center(
                              child: Text(
                                p2Color == PieceColor.white ? '♔' : '♚',
                                style: const TextStyle(fontSize: 28, color: Color(0xFFE5A93C)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Người chơi 2',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                ),
                                Text(
                                  'Cầm quân ${p2Color.displayName}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time control options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thời gian mỗi người:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: timeOptions.map((t) {
                          final label = t == 0 ? 'Vô hạn' : '$t p';
                          final isSel = _selectedTimeMinutes == t;
                          return InkWell(
                            onTap: () => setState(() => _selectedTimeMinutes = t),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFE5A93C) : const Color(0xFF13151B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? const Color(0xFFE5A93C) : const Color(0x26FFFFFF),
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? Colors.black : const Color(0xFFF1F5F9),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Auto-flip board option
              Card(
                child: SwitchListTile(
                  title: const Text('Tự động lật bàn cờ theo lượt'),
                  subtitle: const Text('Thuận tiện khi hai người ngồi đối diện nhau quanh một màn hình'),
                  value: _autoFlipBoard,
                  activeThumbColor: const Color(0xFFE5A93C),
                  onChanged: (val) => setState(() => _autoFlipBoard = val),
                ),
              ),

              const Spacer(),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text('BẮT ĐẦU VÁN ĐẤU 2 NGƯỜI'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
