import '../models/board_position.dart';
import '../models/piece.dart';
import '../models/piece_color.dart';
import '../models/square.dart';

class FenService {
  static const String initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  /// Serialize a BoardPosition to FEN string
  static String toFen(BoardPosition pos) {
    final sb = StringBuffer();

    // 1. Piece placement: rank 7 (8) down to rank 0 (1)
    for (int rank = 7; rank >= 0; rank--) {
      int emptyCount = 0;
      for (int file = 0; file < 8; file++) {
        final piece = pos.getPieceAt(file, rank);
        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            sb.write(emptyCount);
            emptyCount = 0;
          }
          sb.write(piece.fenChar);
        }
      }
      if (emptyCount > 0) {
        sb.write(emptyCount);
      }
      if (rank > 0) {
        sb.write('/');
      }
    }

    // 2. Active color
    sb.write(' ');
    sb.write(pos.activeColor == PieceColor.white ? 'w' : 'b');

    // 3. Castling availability
    sb.write(' ');
    final castling = StringBuffer();
    if (pos.whiteCastleKingside) castling.write('K');
    if (pos.whiteCastleQueenside) castling.write('Q');
    if (pos.blackCastleKingside) castling.write('k');
    if (pos.blackCastleQueenside) castling.write('q');
    sb.write(castling.isEmpty ? '-' : castling.toString());

    // 4. En passant target square
    sb.write(' ');
    sb.write(pos.enPassantTarget?.name ?? '-');

    // 5. Halfmove clock
    sb.write(' ');
    sb.write(pos.halfmoveClock);

    // 6. Fullmove number
    sb.write(' ');
    sb.write(pos.fullmoveNumber);

    return sb.toString();
  }

  /// Parse a FEN string to BoardPosition
  static BoardPosition fromFen(String fen) {
    final parts = fen.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      throw const FormatException('Empty FEN string');
    }

    final rows = parts[0].split('/');
    if (rows.length != 8) {
      throw FormatException('FEN must have 8 ranks, got ${rows.length}');
    }

    final squares = List<Piece?>.filled(64, null);

    // Parse ranks from rank 7 (row 0 in FEN) down to rank 0 (row 7 in FEN)
    for (int r = 0; r < 8; r++) {
      final rankIndex = 7 - r;
      final row = rows[r];
      int fileIndex = 0;

      for (int i = 0; i < row.length; i++) {
        final char = row[i];
        final emptySpaces = int.tryParse(char);
        if (emptySpaces != null) {
          fileIndex += emptySpaces;
        } else {
          final piece = Piece.fromFenChar(char);
          if (piece == null) {
            throw FormatException('Invalid piece character in FEN: $char');
          }
          if (fileIndex >= 8) {
            throw FormatException('Too many pieces in rank $rankIndex');
          }
          squares[rankIndex * 8 + fileIndex] = piece;
          fileIndex++;
        }
      }
    }

    // Active color
    final activeColor = (parts.length > 1 && parts[1] == 'b') ? PieceColor.black : PieceColor.white;

    // Castling rights
    final castling = parts.length > 2 ? parts[2] : '-';
    final whiteCastleKingside = castling.contains('K');
    final whiteCastleQueenside = castling.contains('Q');
    final blackCastleKingside = castling.contains('k');
    final blackCastleQueenside = castling.contains('q');

    // En passant
    Square? enPassantTarget;
    if (parts.length > 3 && parts[3] != '-') {
      enPassantTarget = Square.tryParse(parts[3]);
    }

    // Halfmove & Fullmove
    final halfmoveClock = parts.length > 4 ? (int.tryParse(parts[4]) ?? 0) : 0;
    final fullmoveNumber = parts.length > 5 ? (int.tryParse(parts[5]) ?? 1) : 1;

    return BoardPosition(
      squares: squares,
      activeColor: activeColor,
      whiteCastleKingside: whiteCastleKingside,
      whiteCastleQueenside: whiteCastleQueenside,
      blackCastleKingside: blackCastleKingside,
      blackCastleQueenside: blackCastleQueenside,
      enPassantTarget: enPassantTarget,
      halfmoveClock: halfmoveClock,
      fullmoveNumber: fullmoveNumber,
    );
  }
}
