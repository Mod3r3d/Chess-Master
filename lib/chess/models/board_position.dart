import 'piece.dart';
import 'piece_color.dart';
import 'piece_type.dart';
import 'square.dart';

class BoardPosition {
  final List<Piece?> squares;
  final PieceColor activeColor;
  final bool whiteCastleKingside;
  final bool whiteCastleQueenside;
  final bool blackCastleKingside;
  final bool blackCastleQueenside;
  final Square? enPassantTarget;
  final int halfmoveClock;
  final int fullmoveNumber;

  const BoardPosition({
    required this.squares,
    required this.activeColor,
    required this.whiteCastleKingside,
    required this.whiteCastleQueenside,
    required this.blackCastleKingside,
    required this.blackCastleQueenside,
    this.enPassantTarget,
    this.halfmoveClock = 0,
    this.fullmoveNumber = 1,
  }) : assert(squares.length == 64);

  factory BoardPosition.initial() {
    final sq = List<Piece?>.filled(64, null);

    // White pieces (rank 0 and 1)
    sq[0] = const Piece.white(PieceType.rook);
    sq[1] = const Piece.white(PieceType.knight);
    sq[2] = const Piece.white(PieceType.bishop);
    sq[3] = const Piece.white(PieceType.queen);
    sq[4] = const Piece.white(PieceType.king);
    sq[5] = const Piece.white(PieceType.bishop);
    sq[6] = const Piece.white(PieceType.knight);
    sq[7] = const Piece.white(PieceType.rook);
    for (int f = 0; f < 8; f++) {
      sq[8 + f] = const Piece.white(PieceType.pawn);
    }

    // Black pieces (rank 6 and 7)
    for (int f = 0; f < 8; f++) {
      sq[48 + f] = const Piece.black(PieceType.pawn);
    }
    sq[56] = const Piece.black(PieceType.rook);
    sq[57] = const Piece.black(PieceType.knight);
    sq[58] = const Piece.black(PieceType.bishop);
    sq[59] = const Piece.black(PieceType.queen);
    sq[60] = const Piece.black(PieceType.king);
    sq[61] = const Piece.black(PieceType.bishop);
    sq[62] = const Piece.black(PieceType.knight);
    sq[63] = const Piece.black(PieceType.rook);

    return BoardPosition(
      squares: sq,
      activeColor: PieceColor.white,
      whiteCastleKingside: true,
      whiteCastleQueenside: true,
      blackCastleKingside: true,
      blackCastleQueenside: true,
      enPassantTarget: null,
      halfmoveClock: 0,
      fullmoveNumber: 1,
    );
  }

  Piece? getPiece(Square square) => squares[square.index];
  Piece? getPieceAt(int file, int rank) => squares[rank * 8 + file];
  Piece? getPieceAtIndex(int index) => squares[index];

  Square? findKing(PieceColor color) {
    for (int i = 0; i < 64; i++) {
      final p = squares[i];
      if (p != null && p.type == PieceType.king && p.color == color) {
        return Square.fromIndex(i);
      }
    }
    return null;
  }

  BoardPosition copyWith({
    List<Piece?>? squares,
    PieceColor? activeColor,
    bool? whiteCastleKingside,
    bool? whiteCastleQueenside,
    bool? blackCastleKingside,
    bool? blackCastleQueenside,
    Square? enPassantTarget,
    bool clearEnPassant = false,
    int? halfmoveClock,
    int? fullmoveNumber,
  }) {
    return BoardPosition(
      squares: squares != null ? List<Piece?>.from(squares) : List<Piece?>.from(this.squares),
      activeColor: activeColor ?? this.activeColor,
      whiteCastleKingside: whiteCastleKingside ?? this.whiteCastleKingside,
      whiteCastleQueenside: whiteCastleQueenside ?? this.whiteCastleQueenside,
      blackCastleKingside: blackCastleKingside ?? this.blackCastleKingside,
      blackCastleQueenside: blackCastleQueenside ?? this.blackCastleQueenside,
      enPassantTarget: clearEnPassant ? null : (enPassantTarget ?? this.enPassantTarget),
      halfmoveClock: halfmoveClock ?? this.halfmoveClock,
      fullmoveNumber: fullmoveNumber ?? this.fullmoveNumber,
    );
  }

  /// Structural key for threefold repetition detection (pieces, active color, castling rights, ep target)
  String get repetitionKey {
    final b = StringBuffer();
    for (int i = 0; i < 64; i++) {
      final p = squares[i];
      b.write(p != null ? p.fenChar : '.');
    }
    b.write(activeColor == PieceColor.white ? 'w' : 'b');
    if (whiteCastleKingside) b.write('K');
    if (whiteCastleQueenside) b.write('Q');
    if (blackCastleKingside) b.write('k');
    if (blackCastleQueenside) b.write('q');
    b.write(enPassantTarget?.name ?? '-');
    return b.toString();
  }
}
