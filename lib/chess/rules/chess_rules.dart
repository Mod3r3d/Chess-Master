import '../models/board_position.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../models/piece_color.dart';
import '../models/piece_type.dart';
import '../models/square.dart';

class ChessRules {
  /// Generate all pseudo-legal moves for the active color
  static List<Move> generatePseudoLegalMoves(BoardPosition pos) {
    final moves = <Move>[];
    final color = pos.activeColor;

    for (int i = 0; i < 64; i++) {
      final piece = pos.squares[i];
      if (piece == null || piece.color != color) continue;

      final from = Square.fromIndex(i);
      switch (piece.type) {
        case PieceType.pawn:
          _generatePawnMoves(pos, from, piece, moves);
          break;
        case PieceType.knight:
          _generateKnightMoves(pos, from, piece, moves);
          break;
        case PieceType.bishop:
          _generateSlidingMoves(pos, from, piece, moves, const [
            [1, 1], [1, -1], [-1, 1], [-1, -1]
          ]);
          break;
        case PieceType.rook:
          _generateSlidingMoves(pos, from, piece, moves, const [
            [1, 0], [-1, 0], [0, 1], [0, -1]
          ]);
          break;
        case PieceType.queen:
          _generateSlidingMoves(pos, from, piece, moves, const [
            [1, 1], [1, -1], [-1, 1], [-1, -1],
            [1, 0], [-1, 0], [0, 1], [0, -1]
          ]);
          break;
        case PieceType.king:
          _generateKingMoves(pos, from, piece, moves);
          break;
      }
    }

    return moves;
  }

  /// Generate all strictly legal moves for the active color
  static List<Move> generateLegalMoves(BoardPosition pos) {
    final pseudoMoves = generatePseudoLegalMoves(pos);
    final legalMoves = <Move>[];

    for (final move in pseudoMoves) {
      if (isMoveLegal(pos, move)) {
        // Compute SAN for legal move
        legalMoves.add(move);
      }
    }

    // Enrich with SAN
    return enrichWithSan(pos, legalMoves);
  }

  /// Fast legal move generation without SAN string generation (essential for engine search)
  static List<Move> generateLegalMovesFast(BoardPosition pos) {
    final pseudoMoves = generatePseudoLegalMoves(pos);
    final legalMoves = <Move>[];

    for (final move in pseudoMoves) {
      if (isMoveLegal(pos, move)) {
        legalMoves.add(move);
      }
    }

    return legalMoves;
  }

  /// Check if a pseudo-legal move is strictly legal (does not leave king in check)
  static bool isMoveLegal(BoardPosition pos, Move move) {
    // If castling, verify king does not pass through or land in check, nor is in check
    if (move.isCastling) {
      final color = pos.activeColor;
      if (isInCheck(color, pos)) return false;

      final rank = color == PieceColor.white ? 0 : 7;
      final isKingside = move.to.file == 6;

      if (isKingside) {
        // e1(4) -> f1(5) -> g1(6)
        final passSquare = Square(5, rank);
        if (isSquareAttacked(passSquare, color.opposite, pos)) return false;
      } else {
        // e1(4) -> d1(3) -> c1(2)
        final passSquare = Square(3, rank);
        if (isSquareAttacked(passSquare, color.opposite, pos)) return false;
      }
    }

    final newPos = applyMoveFast(pos, move);
    return !isInCheck(pos.activeColor, newPos);
  }

  /// Check if the king of given color is in check
  static bool isInCheck(PieceColor color, BoardPosition pos) {
    final kingSquare = pos.findKing(color);
    if (kingSquare == null) return false;
    return isSquareAttacked(kingSquare, color.opposite, pos);
  }

  /// Check if a square is attacked by pieces of `byColor`
  static bool isSquareAttacked(Square sq, PieceColor byColor, BoardPosition pos) {
    // 1. Attacked by pawns
    final pawnRankDelta = byColor == PieceColor.white ? -1 : 1;
    for (final df in [-1, 1]) {
      final pawnSq = sq.offset(df, pawnRankDelta);
      if (pawnSq != null) {
        final p = pos.getPiece(pawnSq);
        if (p != null && p.color == byColor && p.type == PieceType.pawn) {
          return true;
        }
      }
    }

    // 2. Attacked by knights
    const knightOffsets = [
      [1, 2], [2, 1], [-1, 2], [-2, 1],
      [1, -2], [2, -1], [-1, -2], [-2, -1]
    ];
    for (final off in knightOffsets) {
      final kSq = sq.offset(off[0], off[1]);
      if (kSq != null) {
        final p = pos.getPiece(kSq);
        if (p != null && p.color == byColor && p.type == PieceType.knight) {
          return true;
        }
      }
    }

    // 3. Attacked by King
    for (int df = -1; df <= 1; df++) {
      for (int dr = -1; dr <= 1; dr++) {
        if (df == 0 && dr == 0) continue;
        final kSq = sq.offset(df, dr);
        if (kSq != null) {
          final p = pos.getPiece(kSq);
          if (p != null && p.color == byColor && p.type == PieceType.king) {
            return true;
          }
        }
      }
    }

    // 4. Attacked by orthogonal sliders (Rook / Queen)
    const orthoDirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    for (final d in orthoDirs) {
      var curr = sq.offset(d[0], d[1]);
      while (curr != null) {
        final p = pos.getPiece(curr);
        if (p != null) {
          if (p.color == byColor && (p.type == PieceType.rook || p.type == PieceType.queen)) {
            return true;
          }
          break; // Blocked
        }
        curr = curr.offset(d[0], d[1]);
      }
    }

    // 5. Attacked by diagonal sliders (Bishop / Queen)
    const diagDirs = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
    for (final d in diagDirs) {
      var curr = sq.offset(d[0], d[1]);
      while (curr != null) {
        final p = pos.getPiece(curr);
        if (p != null) {
          if (p.color == byColor && (p.type == PieceType.bishop || p.type == PieceType.queen)) {
            return true;
          }
          break; // Blocked
        }
        curr = curr.offset(d[0], d[1]);
      }
    }

    return false;
  }

  // --- Move Generators ---

  static void _generatePawnMoves(BoardPosition pos, Square from, Piece piece, List<Move> moves) {
    final isWhite = piece.isWhite;
    final dir = isWhite ? 1 : -1;
    final startRank = isWhite ? 1 : 6;
    final promoRank = isWhite ? 7 : 0;

    // 1 square forward
    final oneForward = from.offset(0, dir);
    if (oneForward != null && pos.getPiece(oneForward) == null) {
      if (oneForward.rank == promoRank) {
        // Promotions
        for (final promo in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
          moves.add(Move(from: from, to: oneForward, promotion: promo));
        }
      } else {
        moves.add(Move(from: from, to: oneForward));

        // 2 squares forward
        if (from.rank == startRank) {
          final twoForward = from.offset(0, dir * 2);
          if (twoForward != null && pos.getPiece(twoForward) == null) {
            moves.add(Move(from: from, to: twoForward));
          }
        }
      }
    }

    // Captures
    for (final df in [-1, 1]) {
      final capSq = from.offset(df, dir);
      if (capSq != null) {
        final targetPiece = pos.getPiece(capSq);
        if (targetPiece != null && targetPiece.color != piece.color) {
          if (capSq.rank == promoRank) {
            for (final promo in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
              moves.add(Move(from: from, to: capSq, promotion: promo, capturedPiece: targetPiece));
            }
          } else {
            moves.add(Move(from: from, to: capSq, capturedPiece: targetPiece));
          }
        } else if (targetPiece == null && pos.enPassantTarget == capSq) {
          // En passant capture
          final epPawnSq = Square(capSq.file, from.rank);
          final epPawn = pos.getPiece(epPawnSq);
          if (epPawn != null && epPawn.color != piece.color && epPawn.type == PieceType.pawn) {
            moves.add(Move(from: from, to: capSq, isEnPassant: true, capturedPiece: epPawn));
          }
        }
      }
    }
  }

  static void _generateKnightMoves(BoardPosition pos, Square from, Piece piece, List<Move> moves) {
    const offsets = [
      [1, 2], [2, 1], [-1, 2], [-2, 1],
      [1, -2], [2, -1], [-1, -2], [-2, -1]
    ];
    for (final off in offsets) {
      final to = from.offset(off[0], off[1]);
      if (to != null) {
        final destPiece = pos.getPiece(to);
        if (destPiece == null) {
          moves.add(Move(from: from, to: to));
        } else if (destPiece.color != piece.color) {
          moves.add(Move(from: from, to: to, capturedPiece: destPiece));
        }
      }
    }
  }

  static void _generateSlidingMoves(
    BoardPosition pos,
    Square from,
    Piece piece,
    List<Move> moves,
    List<List<int>> directions,
  ) {
    for (final d in directions) {
      var curr = from.offset(d[0], d[1]);
      while (curr != null) {
        final destPiece = pos.getPiece(curr);
        if (destPiece == null) {
          moves.add(Move(from: from, to: curr));
        } else {
          if (destPiece.color != piece.color) {
            moves.add(Move(from: from, to: curr, capturedPiece: destPiece));
          }
          break; // Cannot move further in this direction
        }
        curr = curr.offset(d[0], d[1]);
      }
    }
  }

  static void _generateKingMoves(BoardPosition pos, Square from, Piece piece, List<Move> moves) {
    for (int df = -1; df <= 1; df++) {
      for (int dr = -1; dr <= 1; dr++) {
        if (df == 0 && dr == 0) continue;
        final to = from.offset(df, dr);
        if (to != null) {
          final destPiece = pos.getPiece(to);
          if (destPiece == null) {
            moves.add(Move(from: from, to: to));
          } else if (destPiece.color != piece.color) {
            moves.add(Move(from: from, to: to, capturedPiece: destPiece));
          }
        }
      }
    }

    // Castling
    final isWhite = piece.isWhite;
    final rank = isWhite ? 0 : 7;
    final kingSquare = Square(4, rank);

    if (from == kingSquare) {
      // Kingside
      final canCastleKingside = isWhite ? pos.whiteCastleKingside : pos.blackCastleKingside;
      if (canCastleKingside) {
        final fSquare = Square(5, rank);
        final gSquare = Square(6, rank);
        final rookSquare = Square(7, rank);
        final rook = pos.getPiece(rookSquare);

        if (pos.getPiece(fSquare) == null &&
            pos.getPiece(gSquare) == null &&
            rook != null &&
            rook.type == PieceType.rook &&
            rook.color == piece.color) {
          moves.add(Move(from: from, to: gSquare, isCastling: true));
        }
      }

      // Queenside
      final canCastleQueenside = isWhite ? pos.whiteCastleQueenside : pos.blackCastleQueenside;
      if (canCastleQueenside) {
        final bSquare = Square(1, rank);
        final cSquare = Square(2, rank);
        final dSquare = Square(3, rank);
        final rookSquare = Square(0, rank);
        final rook = pos.getPiece(rookSquare);

        if (pos.getPiece(bSquare) == null &&
            pos.getPiece(cSquare) == null &&
            pos.getPiece(dSquare) == null &&
            rook != null &&
            rook.type == PieceType.rook &&
            rook.color == piece.color) {
          moves.add(Move(from: from, to: cSquare, isCastling: true));
        }
      }
    }
  }

  /// Apply move quickly without validation (returns new BoardPosition)
  static BoardPosition applyMoveFast(BoardPosition pos, Move move) {
    final newSquares = List<Piece?>.from(pos.squares);
    final movingPiece = newSquares[move.from.index];
    if (movingPiece == null) return pos;

    newSquares[move.from.index] = null;

    // Handle En Passant
    if (move.isEnPassant) {
      final epPawnIndex = move.from.rank * 8 + move.to.file;
      newSquares[epPawnIndex] = null;
    }

    // Handle Castling Rook move
    if (move.isCastling) {
      final rank = move.from.rank;
      if (move.to.file == 6) {
        // Kingside: rook h(7) -> f(5)
        final rook = newSquares[rank * 8 + 7];
        newSquares[rank * 8 + 7] = null;
        newSquares[rank * 8 + 5] = rook;
      } else if (move.to.file == 2) {
        // Queenside: rook a(0) -> d(3)
        final rook = newSquares[rank * 8 + 0];
        newSquares[rank * 8 + 0] = null;
        newSquares[rank * 8 + 3] = rook;
      }
    }

    // Place piece at destination (with promotion if applicable)
    if (move.promotion != null) {
      newSquares[move.to.index] = Piece(move.promotion!, movingPiece.color);
    } else {
      newSquares[move.to.index] = movingPiece;
    }

    // Update Castling rights
    var wK = pos.whiteCastleKingside;
    var wQ = pos.whiteCastleQueenside;
    var bK = pos.blackCastleKingside;
    var bQ = pos.blackCastleQueenside;

    if (movingPiece.type == PieceType.king) {
      if (movingPiece.isWhite) {
        wK = false;
        wQ = false;
      } else {
        bK = false;
        bQ = false;
      }
    } else if (movingPiece.type == PieceType.rook) {
      if (move.from == const Square(0, 0)) wQ = false;
      if (move.from == const Square(7, 0)) wK = false;
      if (move.from == const Square(0, 7)) bQ = false;
      if (move.from == const Square(7, 7)) bK = false;
    }

    // If opponent rook is captured in corner
    if (move.to == const Square(0, 0)) wQ = false;
    if (move.to == const Square(7, 0)) wK = false;
    if (move.to == const Square(0, 7)) bQ = false;
    if (move.to == const Square(7, 7)) bK = false;

    // En Passant target
    Square? newEpTarget;
    if (movingPiece.type == PieceType.pawn && (move.to.rank - move.from.rank).abs() == 2) {
      newEpTarget = Square(move.from.file, (move.from.rank + move.to.rank) ~/ 2);
    }

    // Halfmove clock (reset on pawn move or capture)
    final isPawnMove = movingPiece.type == PieceType.pawn;
    final isCapture = move.isCapture || move.isEnPassant;
    final newHalfmove = (isPawnMove || isCapture) ? 0 : pos.halfmoveClock + 1;

    // Fullmove number
    final newFullmove = pos.activeColor == PieceColor.black ? pos.fullmoveNumber + 1 : pos.fullmoveNumber;

    return BoardPosition(
      squares: newSquares,
      activeColor: pos.activeColor.opposite,
      whiteCastleKingside: wK,
      whiteCastleQueenside: wQ,
      blackCastleKingside: bK,
      blackCastleQueenside: bQ,
      enPassantTarget: newEpTarget,
      halfmoveClock: newHalfmove,
      fullmoveNumber: newFullmove,
    );
  }

  /// Check game status (returns GameResult if ended, null if ongoing)
  static GameResult? evaluateGameResult(
    BoardPosition pos, {
    List<String> positionHistory = const [],
  }) {
    final legalMoves = generateLegalMoves(pos);
    final inCheck = isInCheck(pos.activeColor, pos);

    // 1. Checkmate or Stalemate
    if (legalMoves.isEmpty) {
      if (inCheck) {
        return GameResult(
          winner: pos.activeColor.opposite,
          reason: GameEndReason.checkmate,
        );
      } else {
        return const GameResult(
          winner: null,
          reason: GameEndReason.stalemate,
        );
      }
    }

    // 2. 50-move rule
    if (pos.halfmoveClock >= 100) {
      return const GameResult(
        winner: null,
        reason: GameEndReason.fiftyMoves,
      );
    }

    // 3. Threefold repetition
    if (positionHistory.isNotEmpty) {
      final currentKey = pos.repetitionKey;
      int count = 1; // current position
      for (final key in positionHistory) {
        if (key == currentKey) {
          count++;
          if (count >= 3) {
            return const GameResult(
              winner: null,
              reason: GameEndReason.threefoldRepetition,
            );
          }
        }
      }
    }

    // 4. Insufficient Material
    if (isInsufficientMaterial(pos)) {
      return const GameResult(
        winner: null,
        reason: GameEndReason.insufficientMaterial,
      );
    }

    return null;
  }

  /// Detect insufficient material according to FIDE rules
  static bool isInsufficientMaterial(BoardPosition pos) {
    int whitePieces = 0;
    int blackPieces = 0;
    PieceType? whiteMinorType;
    PieceType? blackMinorType;
    Square? whiteBishopSquare;
    Square? blackBishopSquare;

    for (int i = 0; i < 64; i++) {
      final piece = pos.squares[i];
      if (piece == null) continue;

      if (piece.type == PieceType.king) continue;

      // Any pawn, rook, queen means sufficient material
      if (piece.type == PieceType.pawn || piece.type == PieceType.rook || piece.type == PieceType.queen) {
        return false;
      }

      if (piece.isWhite) {
        whitePieces++;
        whiteMinorType = piece.type;
        if (piece.type == PieceType.bishop) whiteBishopSquare = Square.fromIndex(i);
      } else {
        blackPieces++;
        blackMinorType = piece.type;
        if (piece.type == PieceType.bishop) blackBishopSquare = Square.fromIndex(i);
      }
    }

    // K vs K
    if (whitePieces == 0 && blackPieces == 0) return true;

    // K+B vs K or K+N vs K
    if ((whitePieces == 1 && blackPieces == 0) || (whitePieces == 0 && blackPieces == 1)) {
      return true;
    }

    // K+B vs K+B with same color bishops
    if (whitePieces == 1 &&
        blackPieces == 1 &&
        whiteMinorType == PieceType.bishop &&
        blackMinorType == PieceType.bishop &&
        whiteBishopSquare != null &&
        blackBishopSquare != null) {
      if (whiteBishopSquare.isLight == blackBishopSquare.isLight) {
        return true;
      }
    }

    return false;
  }

  /// Compute standard algebraic notation (SAN) for moves
  static List<Move> enrichWithSan(BoardPosition pos, List<Move> legalMoves) {
    final result = <Move>[];
    for (final move in legalMoves) {
      final san = computeSan(pos, move, legalMoves);
      result.add(move.copyWith(san: san));
    }
    return result;
  }

  static String computeSan(BoardPosition pos, Move move, List<Move> allLegalMoves) {
    if (move.isCastling) {
      return move.to.file == 6 ? 'O-O' : 'O-O-O';
    }

    final piece = pos.getPiece(move.from);
    if (piece == null) return move.uci;

    final sb = StringBuffer();

    if (piece.type != PieceType.pawn) {
      sb.write(piece.type.sanLetter);

      // Disambiguation
      final candidates = allLegalMoves.where((m) {
        if (m == move) return false;
        if (m.to != move.to) return false;
        final p = pos.getPiece(m.from);
        return p != null && p.type == piece.type && p.color == piece.color;
      }).toList();

      if (candidates.isNotEmpty) {
        final sameFile = candidates.any((m) => m.from.file == move.from.file);
        final sameRank = candidates.any((m) => m.from.rank == move.from.rank);

        if (!sameFile) {
          sb.write(move.from.fileChar);
        } else if (!sameRank) {
          sb.write(move.from.rankChar);
        } else {
          sb.write(move.from.name);
        }
      }
    }

    if (move.isCapture) {
      if (piece.type == PieceType.pawn) {
        sb.write(move.from.fileChar);
      }
      sb.write('x');
    }

    sb.write(move.to.name);

    if (move.promotion != null) {
      sb.write('=${move.promotion!.sanLetter}');
    }

    // Check / Checkmate suffix
    final nextPos = applyMoveFast(pos, move);
    final opponentColor = pos.activeColor.opposite;
    if (isInCheck(opponentColor, nextPos)) {
      final nextLegalMoves = generateLegalMoves(nextPos);
      if (nextLegalMoves.isEmpty) {
        sb.write('#');
      } else {
        sb.write('+');
      }
    }

    return sb.toString();
  }
}
