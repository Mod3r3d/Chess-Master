import 'dart:math';
import 'package:flutter/material.dart';
import '../../bots/bot_catalog.dart';
import '../../bots/bot_profile.dart';
import '../../chess/models/piece_color.dart';
import '../../storage/local_storage.dart';
import '../../widgets/bot_card.dart';
import '../game/game_screen.dart';

class BotSelectionScreen extends StatefulWidget {
  final String engineId;

  const BotSelectionScreen({
    super.key,
    this.engineId = 'stockfish',
  });

  @override
  State<BotSelectionScreen> createState() => _BotSelectionScreenState();
}

class _BotSelectionScreenState extends State<BotSelectionScreen> {
  late List<BotProfile> _bots;
  late BotProfile _selectedBot;
  PieceColor? _chosenColor = PieceColor.white; // null = random
  int _selectedTimeMinutes = 5;

  static const List<int> timeOptions = [0, 3, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    _bots = BotCatalog.getBotsForEngine(widget.engineId);
    _selectedBot = _bots.isNotEmpty ? _bots.first : BotCatalog.stockfishBots[3];
    _loadSavedBot();
  }

  Future<void> _loadSavedBot() async {
    final savedId = await LocalStorage.getSelectedBotId();
    if (widget.engineId == 'stockfish') {
      final match = _bots.where((b) => b.id == savedId).firstOrNull;
      if (match != null && mounted) {
        setState(() {
          _selectedBot = match;
        });
      }
    }
  }

  void _startGame() {
    PieceColor finalColor;
    if (_chosenColor == null) {
      finalColor = Random().nextBool() ? PieceColor.white : PieceColor.black;
    } else {
      finalColor = _chosenColor!;
    }

    LocalStorage.setSelectedBotId(_selectedBot.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GameScreen(
          bot: _selectedBot,
          playerColor: finalColor,
          timeControlMinutes: _selectedTimeMinutes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13151B),
      appBar: AppBar(
        title: Text(widget.engineId == 'mittens' ? 'Đấu với Mittens' : 'Chọn Cấp Độ Đối Thủ'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Options: Color & Time Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E212B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                child: Column(
                  children: [
                    // Color selection
                    Row(
                      children: [
                        const Text(
                          'Chọn màu quân:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                        const Spacer(),
                        _ColorOptionButton(
                          label: 'Trắng',
                          icon: '♔',
                          isSelected: _chosenColor == PieceColor.white,
                          onTap: () => setState(() => _chosenColor = PieceColor.white),
                        ),
                        const SizedBox(width: 8),
                        _ColorOptionButton(
                          label: 'Ngẫu nhiên',
                          icon: '🎲',
                          isSelected: _chosenColor == null,
                          onTap: () => setState(() => _chosenColor = null),
                        ),
                        const SizedBox(width: 8),
                        _ColorOptionButton(
                          label: 'Đen',
                          icon: '♚',
                          isSelected: _chosenColor == PieceColor.black,
                          onTap: () => setState(() => _chosenColor = PieceColor.black),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0x1AFFFFFF), height: 24),

                    // Time control
                    Row(
                      children: [
                        const Text(
                          'Thời gian:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 6,
                          children: timeOptions.map((t) {
                            final label = t == 0 ? 'Vô hạn' : '$t phút';
                            final isSel = _selectedTimeMinutes == t;
                            return InkWell(
                              onTap: () => setState(() => _selectedTimeMinutes = t),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFFE5A93C) : const Color(0xFF13151B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFFE5A93C) : const Color(0x26FFFFFF),
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
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
                  ],
                ),
              ),
            ),

            // Bot List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _bots.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final bot = _bots[i];
                  return BotCard(
                    bot: bot,
                    isSelected: _selectedBot.id == bot.id,
                    onTap: () {
                      setState(() {
                        _selectedBot = bot;
                      });
                    },
                  );
                },
              ),
            ),

            // Bottom Start Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text('BẮT ĐẦU VÁN ĐẤU (${_selectedBot.name})'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOptionButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOptionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5A93C) : const Color(0xFF13151B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5A93C) : const Color(0x26FFFFFF),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : const Color(0xFFF1F5F9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
