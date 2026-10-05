import 'piece.dart';
import 'piece_type.dart';
import 'square.dart';

class Move {
  final Square from;
  final Square to;
  final PieceType? promotion;
  final Piece? capturedPiece;
  final bool isCastling;
  final bool isEnPassant;
  final String? san;

  const Move({
    required this.from,
    required this.to,
    this.promotion,
    this.capturedPiece,
    this.isCastling = false,
    this.isEnPassant = false,
    this.san,
  });

  bool get isCapture => capturedPiece != null || isEnPassant;

  String get uci {
    final promo = promotion != null ? promotion!.letter.toLowerCase() : '';
    return '${from.name}${to.name}$promo';
  }

  Move copyWith({
    Square? from,
    Square? to,
    PieceType? promotion,
    Piece? capturedPiece,
    bool? isCastling,
    bool? isEnPassant,
    String? san,
  }) {
    return Move(
      from: from ?? this.from,
      to: to ?? this.to,
      promotion: promotion ?? this.promotion,
      capturedPiece: capturedPiece ?? this.capturedPiece,
      isCastling: isCastling ?? this.isCastling,
      isEnPassant: isEnPassant ?? this.isEnPassant,
      san: san ?? this.san,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Move &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          promotion == other.promotion;

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ (promotion?.hashCode ?? 0);

  @override
  String toString() => san ?? uci;
}
