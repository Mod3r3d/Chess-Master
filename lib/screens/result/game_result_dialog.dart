import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../bots/bot_profile.dart';
import '../../chess/game/game_phase.dart';
import '../../chess/models/game_result.dart';
import '../../chess/models/piece_color.dart';

class GameResultDialog extends StatelessWidget {
  final GameResult result;
  final PieceColor playerColor;
  final BotProfile? bot;
  final GameMode gameMode;
  final String pgn;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeOpponent;

  const GameResultDialog({
    super.key,
    required this.result,
    required this.playerColor,
    this.bot,
    this.gameMode = GameMode.vsAi,
    required this.pgn,
    required this.onPlayAgain,
    required this.onChangeOpponent,
  });

  @override
  Widget build(BuildContext context) {
    final isDraw = result.isDraw;
    final isVsAi = gameMode.isVsAi;

    final String title;
    final Color badgeColor;
    final IconData icon;

    if (isDraw) {
      title = 'HÒA CỜ';
      badgeColor = const Color(0xFF94A3B8);
      icon = Icons.handshake_outlined;
    } else if (isVsAi) {
      final isWin = result.winner == playerColor;
      if (isWin) {
        title = 'BẠN CHIẾN THẮNG!';
        badgeColor = const Color(0xFF10B981);
        icon = Icons.emoji_events;
      } else {
        title = 'BẠN ĐÃ THUA';
        badgeColor = const Color(0xFFEF4444);
        icon = Icons.sentiment_dissatisfied;
      }
    } else {
      // Local PvP
      final isP1Win = result.winner == playerColor;
      title = isP1Win ? 'NGƯỜI CHƠI 1 THẮNG!' : 'NGƯỜI CHƠI 2 THẮNG!';
      badgeColor = const Color(0xFFE5A93C);
      icon = Icons.emoji_events;
    }

    return Dialog(
      backgroundColor: const Color(0xFF1E212B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: badgeColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor.withValues(alpha: 0.15),
                border: Border.all(color: badgeColor, width: 2),
              ),
              child: Icon(icon, color: badgeColor, size: 40),
            ),
            const SizedBox(height: 16),

            // Result Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Reason
            Text(
              result.reason.displayNameVi,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),

            // Opponent detail (AI vs PvP)
            if (isVsAi && bot != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF13151B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(bot!.avatarEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'đấu với ${bot!.name} (${bot!.displayedElo})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFF1F5F9),
                      ),
                    ),
                  ],
                ),
              )
            else if (!isVsAi)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF13151B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Ván cờ 2 người chơi trên cùng thiết bị',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPlayAgain();
                },
                icon: const Icon(Icons.replay),
                label: const Text('CHƠI LẠI'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onChangeOpponent();
                },
                icon: Icon(isVsAi ? Icons.people_alt_outlined : Icons.home_outlined),
                label: Text(isVsAi ? 'ĐỔI ĐỐI THỦ' : 'VỀ MENU CHÍNH'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: pgn));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép PGN vào bộ nhớ tạm!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16, color: Color(0xFF94A3B8)),
              label: const Text(
                'Sao chép PGN ván đấu',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
