import 'package:flutter/material.dart';
import '../chess/models/piece.dart';
import '../core/theme/board_themes.dart';
import 'pieces/vector_chess_pieces.dart';

class ChessPieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;
  final BoardThemeData? theme;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    this.size = 40.0,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: VectorChessPieceWidget(
        piece: piece,
        size: size * 0.88,
        theme: theme,
      ),
    );
  }
}
