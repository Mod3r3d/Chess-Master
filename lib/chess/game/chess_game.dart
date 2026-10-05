import '../fen/fen_service.dart';
import '../models/board_position.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../models/piece_color.dart';
import '../models/piece_type.dart';
import '../models/square.dart';
import '../rules/chess_rules.dart';

class ChessGame {
  BoardPosition _position;
  final List<BoardPosition> _positionHistory = [];
  final List<String> _repetitionHistory = [];
  final List<Move> _moveHistory = [];
  final List<Piece> _capturedPieces = [];
  GameResult? _result;

  ChessGame({String? initialFen}) : _position = initialFen != null ? FenService.fromFen(initialFen) : BoardPosition.initial() {
    _positionHistory.add(_position);
    _repetitionHistory.add(_position.repetitionKey);
  }

  BoardPosition get position => _position;
  List<Move> get moveHistory => List.unmodifiable(_moveHistory);
  List<Piece> get capturedPieces => List.unmodifiable(_capturedPieces);
  GameResult? get result => _result;
  bool get isGameOver => _result != null;
  PieceColor get activeColor => _position.activeColor;
  Move? get lastMove => _moveHistory.isNotEmpty ? _moveHistory.last : null;

  bool get inCheck => ChessRules.isInCheck(activeColor, _position);
  Square? get checkSquare => inCheck ? _position.findKing(activeColor) : null;

  List<Move> get allLegalMoves {
    if (isGameOver) return [];
    return ChessRules.generateLegalMoves(_position);
  }

  List<Move> legalMovesForSquare(Square square) {
    if (isGameOver) return [];
    final piece = _position.getPiece(square);
    if (piece == null || piece.color != activeColor) return [];
    return allLegalMoves.where((m) => m.from == square).toList();
  }

  /// Make a legal move
  bool makeMove(Move move) {
    if (isGameOver) return false;

    final legalMoves = allLegalMoves;
    Move? matchedMove;
    for (final m in legalMoves) {
      if (m.from == move.from && m.to == move.to) {
        if (move.promotion != null) {
          if (m.promotion == move.promotion) {
            matchedMove = m;
            break;
          }
        } else {
          matchedMove = m;
          break;
        }
      }
    }

    if (matchedMove == null) return false;

    // Track captured piece
    if (matchedMove.capturedPiece != null) {
      _capturedPieces.add(matchedMove.capturedPiece!);
    }

    _moveHistory.add(matchedMove);
    _position = ChessRules.applyMoveFast(_position, matchedMove);
    _positionHistory.add(_position);
    _repetitionHistory.add(_position.repetitionKey);

    // Evaluate game status
    _result = ChessRules.evaluateGameResult(
      _position,
      positionHistory: _repetitionHistory,
    );

    return true;
  }

  /// Undo one halfmove
  bool undoSingleMove() {
    if (_moveHistory.isEmpty || _positionHistory.length <= 1) return false;

    final last = _moveHistory.removeLast();
    if (last.capturedPiece != null && _capturedPieces.isNotEmpty) {
      _capturedPieces.removeLast();
    }

    _positionHistory.removeLast();
    _repetitionHistory.removeLast();
    _position = _positionHistory.last;
    _result = null;

    return true;
  }

  /// Undo a full turn (2 plies if playing AI, 1 ply if 1st move)
  bool undoTurn({bool vsAi = true}) {
    if (isGameOver && _moveHistory.isEmpty) return false;
    if (vsAi) {
      if (_moveHistory.length >= 2) {
        undoSingleMove();
        undoSingleMove();
        return true;
      } else if (_moveHistory.length == 1) {
        return undoSingleMove();
      }
      return false;
    } else {
      return undoSingleMove();
    }
  }

  /// Resign by player
  void resign(PieceColor color) {
    if (isGameOver) return;
    _result = GameResult(
      winner: color.opposite,
      reason: GameEndReason.resignation,
    );
  }

  /// Timeout
  void timeout(PieceColor losingColor) {
    if (isGameOver) return;
    _result = GameResult(
      winner: losingColor.opposite,
      reason: GameEndReason.timeout,
    );
  }

  /// Reset game
  void reset({String? initialFen}) {
    _position = initialFen != null ? FenService.fromFen(initialFen) : BoardPosition.initial();
    _positionHistory.clear();
    _positionHistory.add(_position);
    _repetitionHistory.clear();
    _repetitionHistory.add(_position.repetitionKey);
    _moveHistory.clear();
    _capturedPieces.clear();
    _result = null;
  }

  /// Material difference: positive means white is ahead, negative means black
  int get materialScore {
    int whiteScore = 0;
    int blackScore = 0;
    for (int i = 0; i < 64; i++) {
      final p = _position.squares[i];
      if (p == null || p.type == PieceType.king) continue;
      if (p.isWhite) {
        whiteScore += p.type.value;
      } else {
        blackScore += p.type.value;
      }
    }
    return whiteScore - blackScore;
  }

  List<Piece> get capturedByWhite =>
      _capturedPieces.where((p) => p.color == PieceColor.black).toList();

  List<Piece> get capturedByBlack =>
      _capturedPieces.where((p) => p.color == PieceColor.white).toList();
}
