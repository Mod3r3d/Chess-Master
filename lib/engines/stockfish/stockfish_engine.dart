import 'dart:isolate';
import '../../chess/fen/fen_service.dart';
import '../../chess/models/board_position.dart';
import '../../chess/models/move.dart';
import '../../chess/rules/chess_rules.dart';
import '../chess_engine.dart';
import '../engine_move.dart';
import 'stockfish_search.dart';

class StockfishEngine implements ChessEngine {
  @override
  String get id => 'stockfish';

  @override
  String get name => 'Stockfish';

  @override
  String get description => 'Động cơ cờ vua cổ điển mã nguồn mở, mạnh mẽ và ổn định.';

  BoardPosition _currentPosition = BoardPosition.initial();
  bool _isCancelled = false;

  @override
  Future<void> initialize() async {
    // Ready UCI
    _isCancelled = false;
  }

  @override
  Future<void> setPosition(String fen, {List<String>? moves}) async {
    _currentPosition = FenService.fromFen(fen);
    if (moves != null && moves.isNotEmpty) {
      for (final uci in moves) {
        final legals = ChessRules.generateLegalMoves(_currentPosition);
        final match = legals.where((m) => m.uci == uci).firstOrNull;
        if (match != null) {
          _currentPosition = ChessRules.applyMoveFast(_currentPosition, match);
        }
      }
    }
  }

  @override
  Future<EngineMove> getBestMove({
    int depth = 4,
    int moveTimeMs = 800,
    int skillLevel = 10,
    double randomness = 0.0,
  }) async {
    _isCancelled = false;

    Move? bestMove;
    try {
      final pos = _currentPosition;
      bestMove = await Isolate.run(() {
        return StockfishSearch.findBestMoveSync(
          pos,
          maxDepth: depth,
          timeLimitMs: moveTimeMs,
          randomness: randomness,
        );
      });
    } catch (_) {
      bestMove = await StockfishSearch.findBestMove(
        _currentPosition,
        maxDepth: depth,
        timeLimitMs: moveTimeMs,
        randomness: randomness,
        isCancelled: () => _isCancelled,
      );
    }

    if (bestMove == null) {
      final fallback = ChessRules.generateLegalMovesFast(_currentPosition).firstOrNull;
      if (fallback == null) {
        throw StateError('No legal moves available');
      }
      return EngineMove(move: fallback, depth: depth);
    }

    final score = StockfishSearch.evaluate(ChessRules.applyMoveFast(_currentPosition, bestMove));
    return EngineMove(
      move: bestMove,
      scoreCp: score,
      depth: depth,
    );
  }

  @override
  Future<void> stop() async {
    _isCancelled = true;
  }

  @override
  Future<void> dispose() async {
    _isCancelled = true;
  }
}
