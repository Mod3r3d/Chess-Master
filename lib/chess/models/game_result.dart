import 'piece_color.dart';

enum GameEndReason {
  checkmate,
  stalemate,
  insufficientMaterial,
  fiftyMoves,
  threefoldRepetition,
  resignation,
  timeout;

  String get displayNameVi {
    switch (this) {
      case GameEndReason.checkmate:
        return 'Chiếu hết';
      case GameEndReason.stalemate:
        return 'Hết nước đi (Hòa)';
      case GameEndReason.insufficientMaterial:
        return 'Không đủ lực lượng chiếu hết (Hòa)';
      case GameEndReason.fiftyMoves:
        return 'Quy tắc 50 nước (Hòa)';
      case GameEndReason.threefoldRepetition:
        return 'Lặp lại thế cờ 3 lần (Hòa)';
      case GameEndReason.resignation:
        return 'Đầu hàng';
      case GameEndReason.timeout:
        return 'Hết giờ';
    }
  }

  String get displayNameEn {
    switch (this) {
      case GameEndReason.checkmate:
        return 'Checkmate';
      case GameEndReason.stalemate:
        return 'Stalemate';
      case GameEndReason.insufficientMaterial:
        return 'Insufficient material';
      case GameEndReason.fiftyMoves:
        return '50-move rule';
      case GameEndReason.threefoldRepetition:
        return 'Threefold repetition';
      case GameEndReason.resignation:
        return 'Resignation';
      case GameEndReason.timeout:
        return 'Time out';
    }
  }
}

class GameResult {
  final PieceColor? winner; // null if draw
  final GameEndReason reason;

  const GameResult({
    required this.winner,
    required this.reason,
  });

  bool get isDraw => winner == null;
  bool isWinner(PieceColor color) => winner == color;

  String get pgnResult {
    if (isDraw) return '1/2-1/2';
    return winner == PieceColor.white ? '1-0' : '0-1';
  }

  String headerText(PieceColor playerColor) {
    if (isDraw) return 'HÒA CỜ';
    return winner == playerColor ? 'CHIẾN THẮNG!' : 'THẤT BẠI';
  }

  @override
  String toString() => 'GameResult(winner: $winner, reason: $reason)';
}
