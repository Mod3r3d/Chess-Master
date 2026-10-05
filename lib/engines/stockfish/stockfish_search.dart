import 'dart:math';
import '../../chess/models/board_position.dart';
import '../../chess/models/move.dart';
import '../../chess/models/piece_color.dart';
import '../../chess/models/piece_type.dart';
import '../../chess/models/square.dart';
import '../../chess/rules/chess_rules.dart';
import 'opening_book.dart';

class StockfishSearch {
  static const int infinity = 9999999;
  static const int checkmateValue = 100000;

  // Piece-Square Tables (Tomasz Michniewski / PeSTO simplified evaluation)
  // Indices 0..7 = Rank 8 (black side), indices 56..63 = Rank 1 (white side)
  static const List<int> pawnPst = [
     0,   0,   0,   0,   0,   0,   0,   0, // Rank 8 (Promoted)
    50,  50,  50,  50,  50,  50,  50,  50, // Rank 7
    10,  10,  20,  30,  30,  20,  10,  10, // Rank 6
     5,   5,  10,  25,  25,  10,   5,   5, // Rank 5
     0,   0,   0,  20,  20,   0,   0,   0, // Rank 4
     5,  -5, -10,   0,   0, -10,  -5,   5, // Rank 3
     5,  10,  10, -20, -20,  10,  10,   5, // Rank 2
     0,   0,   0,   0,   0,   0,   0,   0  // Rank 1
  ];

  static const List<int> knightPst = [
    -50, -40, -30, -30, -30, -30, -40, -50,
    -40, -20,   0,   0,   0,   0, -20, -40,
    -30,   0,  10,  15,  15,  10,   0, -30,
    -30,   5,  15,  20,  20,  15,   5, -30,
    -30,   0,  15,  20,  20,  15,   0, -30,
    -30,   5,  10,  15,  15,  10,   5, -30,
    -40, -20,   0,   5,   5,   0, -20, -40,
    -50, -40, -30, -30, -30, -30, -40, -50
  ];

  static const List<int> bishopPst = [
    -20, -10, -10, -10, -10, -10, -10, -20,
    -10,   0,   0,   0,   0,   0,   0, -10,
    -10,   0,   5,  10,  10,   5,   0, -10,
    -10,   5,   5,  10,  10,   5,   5, -10,
    -10,   0,  10,  10,  10,  10,   0, -10,
    -10,  10,  10,  10,  10,  10,  10, -10,
    -10,   5,   0,   0,   0,   0,   5, -10,
    -20, -10, -10, -10, -10, -10, -10, -20
  ];

  static const List<int> rookPst = [
     0,   0,   0,   0,   0,   0,   0,   0,
     5,  10,  10,  10,  10,  10,  10,   5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
    -5,   0,   0,   0,   0,   0,   0,  -5,
     0,   0,   0,   5,   5,   0,   0,   0
  ];

  static const List<int> queenPst = [
    -20, -10, -10,  -5,  -5, -10, -10, -20,
    -10,   0,   0,   0,   0,   0,   0, -10,
    -10,   0,   5,   5,   5,   5,   0, -10,
     -5,   0,   5,   5,   5,   5,   0,  -5,
      0,   0,   5,   5,   5,   5,   0,  -5,
    -10,   5,   5,   5,   5,   5,   0, -10,
    -10,   0,   5,   0,   0,   0,   0, -10,
    -20, -10, -10,  -5,  -5, -10, -10, -20
  ];

  static const List<int> kingMiddlePst = [
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -20, -30, -30, -40, -40, -30, -30, -20,
    -10, -20, -20, -20, -20, -20, -20, -10,
     20,  20,   0,   0,   0,   0,  20,  20,
     20,  30,  10,   0,   0,  10,  30,  20
  ];

  static const List<int> kingEndgamePst = [
    -50, -40, -30, -20, -20, -30, -40, -50,
    -30, -20, -10,   0,   0, -10, -20, -30,
    -30, -10,  20,  30,  30,  20, -10, -30,
    -30, -10,  30,  40,  40,  30, -10, -30,
    -30, -10,  30,  40,  40,  30, -10, -30,
    -30, -10,  20,  30,  30,  20, -10, -30,
    -30, -30,   0,   0,   0,   0, -30, -30,
    -50, -30, -30, -30, -30, -30, -30, -50
  ];

  /// Static Evaluation from perspective of active player
  static int evaluate(BoardPosition pos) {
    int whiteMaterial = 0;
    int blackMaterial = 0;
    int whitePst = 0;
    int blackPst = 0;

    int whiteBishops = 0;
    int blackBishops = 0;

    final whitePawnFiles = List<int>.filled(8, 0);
    final blackPawnFiles = List<int>.filled(8, 0);

    for (int i = 0; i < 64; i++) {
      final piece = pos.squares[i];
      if (piece == null) continue;

      final sq = Square.fromIndex(i);
      final isWhite = piece.isWhite;

      if (isWhite) {
        whiteMaterial += piece.type.value;
        if (piece.type == PieceType.bishop) whiteBishops++;
        if (piece.type == PieceType.pawn) whitePawnFiles[sq.file]++;
      } else {
        blackMaterial += piece.type.value;
        if (piece.type == PieceType.bishop) blackBishops++;
        if (piece.type == PieceType.pawn) blackPawnFiles[sq.file]++;
      }
    }

    // Determine if endgame: Non-pawn material < 1400 each side
    final isEndgame = (whiteMaterial - whitePawnFiles.fold(0, (a, b) => a + b) * 100) < 1400 &&
        (blackMaterial - blackPawnFiles.fold(0, (a, b) => a + b) * 100) < 1400;

    // Piece-Square table evaluation
    for (int i = 0; i < 64; i++) {
      final piece = pos.squares[i];
      if (piece == null) continue;

      final isWhite = piece.isWhite;
      final sq = Square.fromIndex(i);

      // White: Rank 0 maps to row 7 (index 56..63); Rank 7 maps to row 0 (index 0..7)
      // Black: Rank 7 maps to row 7 (index 56..63); Rank 0 maps to row 0 (index 0..7)
      final pstIndex = isWhite ? ((7 - sq.rank) * 8 + sq.file) : (sq.rank * 8 + sq.file);

      int posValue = 0;
      switch (piece.type) {
        case PieceType.pawn:
          posValue = pawnPst[pstIndex];
          // Passed pawn bonus
          if (isWhite && blackPawnFiles[sq.file] == 0) {
            posValue += 20 + sq.rank * 10;
          } else if (!isWhite && whitePawnFiles[sq.file] == 0) {
            posValue += 20 + (7 - sq.rank) * 10;
          }
          break;
        case PieceType.knight:
          posValue = knightPst[pstIndex];
          break;
        case PieceType.bishop:
          posValue = bishopPst[pstIndex];
          break;
        case PieceType.rook:
          posValue = rookPst[pstIndex];
          // Rook on open file (+25) or semi-open file (+15)
          final myPawnsOnFile = isWhite ? whitePawnFiles[sq.file] : blackPawnFiles[sq.file];
          final enemyPawnsOnFile = isWhite ? blackPawnFiles[sq.file] : whitePawnFiles[sq.file];
          if (myPawnsOnFile == 0 && enemyPawnsOnFile == 0) {
            posValue += 25;
          } else if (myPawnsOnFile == 0) {
            posValue += 15;
          }
          break;
        case PieceType.queen:
          posValue = queenPst[pstIndex];
          break;
        case PieceType.king:
          posValue = isEndgame ? kingEndgamePst[pstIndex] : kingMiddlePst[pstIndex];
          break;
      }

      if (isWhite) {
        whitePst += posValue;
      } else {
        blackPst += posValue;
      }
    }

    int whiteBonus = 0;
    int blackBonus = 0;

    // Bishop pair bonus
    if (whiteBishops >= 2) whiteBonus += 35;
    if (blackBishops >= 2) blackBonus += 35;

    // Doubled pawns penalty
    for (int f = 0; f < 8; f++) {
      if (whitePawnFiles[f] > 1) whiteBonus -= (whitePawnFiles[f] - 1) * 15;
      if (blackPawnFiles[f] > 1) blackBonus -= (blackPawnFiles[f] - 1) * 15;
    }

    final totalWhite = whiteMaterial + whitePst + whiteBonus;
    final totalBlack = blackMaterial + blackPst + blackBonus;

    final score = totalWhite - totalBlack;
    return pos.activeColor == PieceColor.white ? score : -score;
  }

  /// Score moves for alpha-beta ordering
  static int _scoreMove(BoardPosition pos, Move move, {Move? pvMove}) {
    // 1. PV move from previous iteration gets absolute highest priority
    if (pvMove != null && move == pvMove) {
      return 1000000;
    }

    int score = 0;

    // 2. Captures scored by MVV-LVA (Most Valuable Victim - Least Valuable Attacker)
    if (move.capturedPiece != null) {
      final victimVal = move.capturedPiece!.type.value;
      final attacker = pos.getPiece(move.from);
      final attackerVal = attacker?.type.value ?? 0;
      score += 100000 + (victimVal * 10 - attackerVal);
    }

    // 3. Promotions
    if (move.promotion != null) {
      score += 90000 + move.promotion!.value;
    }

    // 4. Castling
    if (move.isCastling) {
      score += 5000;
    }

    // 5. Piece advancement / center control
    final piece = pos.getPiece(move.from);
    if (piece != null && !move.isCapture) {
      // Bonus for center squares (d4, e4, d5, e5)
      if ((move.to.file == 3 || move.to.file == 4) &&
          (move.to.rank == 3 || move.to.rank == 4)) {
        score += 300;
      }
    }

    return score;
  }

  /// Synchronous search method with Iterative Deepening for background Isolates
  static Move? findBestMoveSync(
    BoardPosition pos, {
    required int maxDepth,
    required int timeLimitMs,
    double randomness = 0.0,
    bool Function()? isCancelled,
  }) {
    final legalMoves = ChessRules.generateLegalMovesFast(pos);
    if (legalMoves.isEmpty) return null;
    if (legalMoves.length == 1) return legalMoves.first;

    // 1. Opening Book Lookup
    if (randomness < 0.25) {
      final bookMove = OpeningBook.lookup(pos);
      if (bookMove != null) {
        return bookMove;
      }
    }

    final startTime = DateTime.now().millisecondsSinceEpoch;
    final random = Random();

    Move? bestMoveSoFar = legalMoves.first;
    int bestScoreSoFar = -infinity;

    // Initial move ordering
    legalMoves.sort((a, b) => _scoreMove(pos, b).compareTo(_scoreMove(pos, a)));

    // 2. Iterative Deepening from depth 1 to maxDepth
    for (int currentDepth = 1; currentDepth <= maxDepth; currentDepth++) {
      if (isCancelled != null && isCancelled()) break;

      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      if (elapsed > timeLimitMs) break;

      // If more than 60% of time used and depth >= 3, don't start next iteration
      if (currentDepth > 2 && elapsed > (timeLimitMs * 0.60)) break;

      // Move ordering: put best move from previous depth at the front (PV Move)
      if (bestMoveSoFar != null) {
        legalMoves.removeWhere((m) => m == bestMoveSoFar);
        legalMoves.insert(0, bestMoveSoFar);
      }

      int alpha = -infinity;
      const beta = infinity;

      Move? currentDepthBestMove;
      int currentDepthBestScore = -infinity;
      bool completedCleanly = true;

      for (int i = 0; i < legalMoves.length; i++) {
        if (isCancelled != null && isCancelled()) {
          completedCleanly = false;
          break;
        }

        final moveElapsed = DateTime.now().millisecondsSinceEpoch - startTime;
        if (moveElapsed > timeLimitMs) {
          completedCleanly = false;
          break;
        }

        final move = legalMoves[i];
        final nextPos = ChessRules.applyMoveFast(pos, move);

        final score = -_negamax(
          nextPos,
          currentDepth - 1,
          -beta,
          -alpha,
          startTime,
          timeLimitMs,
          isCancelled,
        );

        // If time ran out during negamax, discard this result
        final postElapsed = DateTime.now().millisecondsSinceEpoch - startTime;
        if (postElapsed > timeLimitMs || (isCancelled != null && isCancelled())) {
          completedCleanly = false;
          break;
        }

        if (score > currentDepthBestScore) {
          currentDepthBestScore = score;
          currentDepthBestMove = move;
        }

        if (score > alpha) {
          alpha = score;
        }

        // Checkmate found: stop search at this depth immediately
        if (score >= checkmateValue - 100) {
          break;
        }
      }

      // Only adopt this depth's findings if it completed without timing out
      if (completedCleanly && currentDepthBestMove != null) {
        bestMoveSoFar = currentDepthBestMove;
        bestScoreSoFar = currentDepthBestScore;

        // If checkmate is found, no need to search deeper!
        if (bestScoreSoFar >= checkmateValue - 100) {
          break;
        }
      }
    }

    // 3. Lower Elo randomness (Beginner / Novice only)
    if (randomness > 0.08 && legalMoves.length > 1) {
      if (random.nextDouble() < randomness) {
        // Pick one of the top 3 alternative legal moves
        final candidateCount = min(3, legalMoves.length);
        final pickIndex = random.nextInt(candidateCount);
        return legalMoves[pickIndex];
      }
    }

    return bestMoveSoFar ?? legalMoves.first;
  }

  /// Find best move using Negamax with Alpha-Beta pruning
  static Future<Move?> findBestMove(
    BoardPosition pos, {
    required int maxDepth,
    required int timeLimitMs,
    double randomness = 0.0,
    bool Function()? isCancelled,
  }) async {
    return findBestMoveSync(
      pos,
      maxDepth: maxDepth,
      timeLimitMs: timeLimitMs,
      randomness: randomness,
      isCancelled: isCancelled,
    );
  }

  static int _negamax(
    BoardPosition pos,
    int depth,
    int alpha,
    int beta,
    int startTime,
    int timeLimitMs,
    bool Function()? isCancelled,
  ) {
    if (isCancelled != null && isCancelled()) return 0;
    if ((DateTime.now().millisecondsSinceEpoch - startTime) > timeLimitMs) {
      return 0; // Return immediately; caller will detect timeout and abort iteration
    }

    if (depth <= 0) {
      return _quiescence(pos, alpha, beta, 2);
    }

    final moves = ChessRules.generateLegalMovesFast(pos);
    if (moves.isEmpty) {
      if (ChessRules.isInCheck(pos.activeColor, pos)) {
        return -checkmateValue - depth; // Prefer quicker checkmates
      }
      return 0; // Stalemate
    }

    // Move ordering
    moves.sort((a, b) => _scoreMove(pos, b).compareTo(_scoreMove(pos, a)));

    for (final move in moves) {
      final nextPos = ChessRules.applyMoveFast(pos, move);
      final score = -_negamax(
        nextPos,
        depth - 1,
        -beta,
        -alpha,
        startTime,
        timeLimitMs,
        isCancelled,
      );

      // Check timeout
      if ((DateTime.now().millisecondsSinceEpoch - startTime) > timeLimitMs ||
          (isCancelled != null && isCancelled())) {
        return 0;
      }

      if (score >= beta) {
        return beta; // Beta cutoff
      }
      if (score > alpha) {
        alpha = score;
      }
    }

    return alpha;
  }

  /// Quiescence search to stabilize evaluations against tactical blunders
  static int _quiescence(BoardPosition pos, int alpha, int beta, int maxQDepth) {
    final standPat = evaluate(pos);
    if (maxQDepth <= 0) return standPat;

    if (standPat >= beta) return beta;
    if (alpha < standPat) alpha = standPat;

    final moves = ChessRules.generatePseudoLegalMoves(pos)
        .where((m) => m.isCapture && ChessRules.isMoveLegal(pos, m))
        .toList();

    if (moves.isEmpty) return standPat;

    moves.sort((a, b) => _scoreMove(pos, b).compareTo(_scoreMove(pos, a)));

    for (final move in moves) {
      // Delta pruning: if standPat + victim value + 200 < alpha, skip hopelessly losing capture
      final victimVal = move.capturedPiece?.type.value ?? 100;
      if (standPat + victimVal + 200 < alpha) continue;

      final nextPos = ChessRules.applyMoveFast(pos, move);
      final score = -_quiescence(nextPos, -beta, -alpha, maxQDepth - 1);

      if (score >= beta) return beta;
      if (score > alpha) alpha = score;
    }

    return alpha;
  }
}
