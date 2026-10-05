import 'dart:isolate';
import 'dart:math';
import '../../chess/fen/fen_service.dart';
import '../../chess/models/board_position.dart';
import '../../chess/models/move.dart';
import '../../chess/rules/chess_rules.dart';
import '../chess_engine.dart';
import '../engine_move.dart';
import '../stockfish/stockfish_search.dart';

class MittensEngine implements ChessEngine {
  @override
  String get id => 'mittens';

  @override
  String get name => 'Mittens';

  @override
  String get description => 'Mèo Mittens bí ẩn - vẻ ngoài ngây thơ nhưng sức mạnh cờ vua bất bại!';

  BoardPosition _currentPosition = BoardPosition.initial();
  bool _isCancelled = false;
  final Random _random = Random();

  static const List<String> normalQuotes = [
    'Meow. *chớp mắt ngây thơ*',
    'Tất cả tốt rồi cũng sẽ tan biến... meow.',
    'Ngươi có nghe thấy tiếng cào cửa không? *purr*',
    'Ta là định mệnh. Meow.',
    'Một nước đi đáng yêu đấy, nhưng vô ích thôi...',
    '*liếm bàn chân một cách thờ ơ*',
    'Bàn cờ này thuộc về loài mèo. Meow.',
    'Ngươi sắp hết thời gian rồi đó... meow.',
  ];

  static const List<String> captureQuotes = [
    'Quân cờ ngon tuyệt! Meow! 🐾',
    'Một bữa ăn nhẹ trước khi chiếu hết. *purr*',
    'Ngươi để quên quân này sao? Meow!',
    'Món quà này ta nhận nhé! Meow!',
  ];

  static const List<String> checkQuotes = [
    'Chiếu vua! Chạy đi đâu được nữa? Meow!',
    'Vua của ngươi trông thật hoảng loạn... *purrs*',
    'Không lối thoát đâu! Meow meow!',
  ];

  @override
  Future<void> initialize() async {
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
    int depth = 5,
    int moveTimeMs = 1000,
    int skillLevel = 20,
    double randomness = 0.0,
  }) async {
    _isCancelled = false;

    // Mittens plays sharply with depth 5-6
    final searchDepth = max(depth, 5);
    Move? bestMove;
    try {
      final pos = _currentPosition;
      bestMove = await Isolate.run(() {
        return StockfishSearch.findBestMoveSync(
          pos,
          maxDepth: searchDepth,
          timeLimitMs: moveTimeMs,
          randomness: 0.0,
        );
      });
    } catch (_) {
      bestMove = await StockfishSearch.findBestMove(
        _currentPosition,
        maxDepth: searchDepth,
        timeLimitMs: moveTimeMs,
        randomness: 0.0,
        isCancelled: () => _isCancelled,
      );
    }

    if (bestMove == null) {
      final fallback = ChessRules.generateLegalMovesFast(_currentPosition).first;
      return EngineMove(move: fallback, dialogue: 'Meow...?');
    }

    // Pick dialogue based on move context
    String dialogue;
    final nextPos = ChessRules.applyMoveFast(_currentPosition, bestMove);
    final isChecking = ChessRules.isInCheck(_currentPosition.activeColor.opposite, nextPos);

    if (isChecking) {
      dialogue = checkQuotes[_random.nextInt(checkQuotes.length)];
    } else if (bestMove.isCapture) {
      dialogue = captureQuotes[_random.nextInt(captureQuotes.length)];
    } else {
      dialogue = normalQuotes[_random.nextInt(normalQuotes.length)];
    }

    final score = StockfishSearch.evaluate(nextPos);
    return EngineMove(
      move: bestMove,
      scoreCp: score,
      depth: searchDepth,
      dialogue: dialogue,
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
