import '../chess/models/move.dart';

class EngineMove {
  final Move move;
  final int? scoreCp; // Centipawns score
  final int? depth;
  final String? dialogue;

  const EngineMove({
    required this.move,
    this.scoreCp,
    this.depth,
    this.dialogue,
  });

  @override
  String toString() => 'EngineMove(${move.uci}, score: $scoreCp, depth: $depth, dialogue: $dialogue)';
}
