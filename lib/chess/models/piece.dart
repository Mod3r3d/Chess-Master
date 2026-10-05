import 'piece_color.dart';
import 'piece_type.dart';

class Piece {
  final PieceType type;
  final PieceColor color;

  const Piece(this.type, this.color);

  const Piece.white(this.type) : color = PieceColor.white;
  const Piece.black(this.type) : color = PieceColor.black;

  bool get isWhite => color.isWhite;
  bool get isBlack => color.isBlack;

  String get fenChar {
    final letter = type.letter;
    return isWhite ? letter.toUpperCase() : letter.toLowerCase();
  }

  static Piece? fromFenChar(String char) {
    final type = PieceType.fromChar(char);
    if (type == null) return null;
    final isUpper = char == char.toUpperCase();
    return Piece(type, isUpper ? PieceColor.white : PieceColor.black);
  }

  String get unicodeSymbol {
    switch (type) {
      case PieceType.king:
        return isWhite ? '♔' : '♚';
      case PieceType.queen:
        return isWhite ? '♕' : '♛';
      case PieceType.rook:
        return isWhite ? '♖' : '♜';
      case PieceType.bishop:
        return isWhite ? '♗' : '♝';
      case PieceType.knight:
        return isWhite ? '♘' : '♞';
      case PieceType.pawn:
        return isWhite ? '♙' : '♟';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Piece && runtimeType == other.runtimeType && type == other.type && color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;

  @override
  String toString() => '$color ${type.name} ($fenChar)';
}
