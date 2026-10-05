import '../models/game_result.dart';
import '../models/move.dart';

class PgnService {
  /// Generate PGN string from game metadata and move list
  static String exportPgn({
    required List<Move> moves,
    String white = 'Player',
    String black = 'Stockfish',
    String? event,
    String? site,
    DateTime? date,
    String? round,
    GameResult? result,
  }) {
    final now = date ?? DateTime.now();
    final dateStr = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    final resultStr = result?.pgnResult ?? '*';

    final sb = StringBuffer();
    sb.writeln('[Event "${event ?? 'Offline Chess Match'}"]');
    sb.writeln('[Site "${site ?? 'Chess Master Offline'}"]');
    sb.writeln('[Date "$dateStr"]');
    sb.writeln('[Round "${round ?? '1'}"]');
    sb.writeln('[White "$white"]');
    sb.writeln('[Black "$black"]');
    sb.writeln('[Result "$resultStr"]');
    sb.writeln();

    // Format moves
    int moveNumber = 1;
    for (int i = 0; i < moves.length; i++) {
      if (i % 2 == 0) {
        sb.write('$moveNumber. ');
      }
      final move = moves[i];
      sb.write(move.san ?? move.uci);
      sb.write(' ');

      if (i % 2 != 0) {
        moveNumber++;
      }
    }

    sb.write(resultStr);
    return sb.toString();
  }
}
