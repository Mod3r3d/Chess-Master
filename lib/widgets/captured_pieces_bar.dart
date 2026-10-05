import 'package:flutter/material.dart';
import '../chess/models/piece.dart';
import '../core/theme/board_themes.dart';
import 'chess_piece_widget.dart';

class CapturedPiecesBar extends StatelessWidget {
  final List<Piece> capturedPieces;
  final int scoreAdvantage; // Material advantage if > 0
  final BoardThemeData? theme;

  const CapturedPiecesBar({
    super.key,
    required this.capturedPieces,
    this.scoreAdvantage = 0,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Sort captures by piece value
    final sorted = List<Piece>.from(capturedPieces)
      ..sort((a, b) => b.type.value.compareTo(a.type.value));

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sorted.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: ChessPieceWidget(
                    piece: p,
                    size: 19,
                    theme: theme,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (scoreAdvantage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x3310B981),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+$scoreAdvantage',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
      ],
    );
  }
}
