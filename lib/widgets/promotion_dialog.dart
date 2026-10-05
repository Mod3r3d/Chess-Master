import 'package:flutter/material.dart';
import '../chess/models/piece.dart';
import '../chess/models/piece_color.dart';
import '../chess/models/piece_type.dart';
import '../core/theme/board_themes.dart';
import 'chess_piece_widget.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;
  final BoardThemeData? theme;

  const PromotionDialog({
    super.key,
    required this.color,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    const promoTypes = [
      PieceType.queen,
      PieceType.rook,
      PieceType.bishop,
      PieceType.knight,
    ];

    return Dialog(
      backgroundColor: const Color(0xFF1E212B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Phong Cấp Quân Tốt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn quân cờ bạn muốn nâng cấp:',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: promoTypes.map((type) {
                return InkWell(
                  onTap: () => Navigator.of(context).pop(type),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF282C37),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Center(
                      child: ChessPieceWidget(
                        piece: Piece(type, color),
                        size: 40,
                        theme: theme,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
