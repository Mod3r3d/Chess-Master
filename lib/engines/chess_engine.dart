import 'engine_move.dart';

abstract class ChessEngine {
  String get id;
  String get name;
  String get description;

  Future<void> initialize();

  Future<void> setPosition(String fen, {List<String>? moves});

  Future<EngineMove> getBestMove({
    int depth = 4,
    int moveTimeMs = 800,
    int skillLevel = 10,
    double randomness = 0.0,
  });

  Future<void> stop();

  Future<void> dispose();
}
