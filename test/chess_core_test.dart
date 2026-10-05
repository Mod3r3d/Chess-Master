import 'package:flutter_test/flutter_test.dart';
import 'package:chess_master/chess/fen/fen_service.dart';
import 'package:chess_master/chess/game/chess_game.dart';
import 'package:chess_master/chess/models/board_position.dart';
import 'package:chess_master/chess/models/game_result.dart';
import 'package:chess_master/chess/models/move.dart';
import 'package:chess_master/chess/models/piece.dart';
import 'package:chess_master/chess/models/piece_color.dart';
import 'package:chess_master/chess/models/piece_type.dart';
import 'package:chess_master/chess/models/square.dart';
import 'package:chess_master/chess/rules/chess_rules.dart';

void main() {
  group('Chess Core Tests', () {
    test('Initial board setup and FEN', () {
      final pos = BoardPosition.initial();
      expect(pos.activeColor, PieceColor.white);
      expect(pos.getPiece(const Square(4, 0))?.type, PieceType.king);
      expect(pos.getPiece(const Square(4, 7))?.type, PieceType.king);
      expect(FenService.toFen(pos), FenService.initialFen);

      final parsed = FenService.fromFen(FenService.initialFen);
      expect(FenService.toFen(parsed), FenService.initialFen);
    });

    test('Initial legal moves count should be 20 for White', () {
      final pos = BoardPosition.initial();
      final moves = ChessRules.generateLegalMoves(pos);
      // 16 pawn moves (8 pawns x 2) + 4 knight moves (2 knights x 2) = 20
      expect(moves.length, 20);
    });

    test('Pawn two-square advance and en passant', () {
      final game = ChessGame();

      // 1. e4
      final e2 = Square.parse('e2');
      final e4 = Square.parse('e4');
      expect(game.makeMove(Move(from: e2, to: e4)), isTrue);
      expect(game.position.enPassantTarget?.name, 'e3');

      // 1... a6
      expect(game.makeMove(Move(from: Square.parse('a7'), to: Square.parse('a6'))), isTrue);

      // 2. e5
      expect(game.makeMove(Move(from: e4, to: Square.parse('e5'))), isTrue);

      // 2... d5 (black double push)
      expect(game.makeMove(Move(from: Square.parse('d7'), to: Square.parse('d5'))), isTrue);
      expect(game.position.enPassantTarget?.name, 'd6');

      // 3. exd6 (en passant capture)
      final epMove = Move(from: Square.parse('e5'), to: Square.parse('d6'), isEnPassant: true);
      expect(game.makeMove(epMove), isTrue);
      expect(game.position.getPiece(Square.parse('d5')), isNull); // Captured black pawn removed
      expect(game.capturedPieces.length, 1);
      expect(game.capturedPieces.first.type, PieceType.pawn);
    });

    test('Pawn promotion', () {
      // Board with white pawn on e7 ready to promote on e8
      const fen = '8/4P3/8/8/8/8/8/4K2k w - - 0 1';
      final pos = FenService.fromFen(fen);
      final legalMoves = ChessRules.generateLegalMoves(pos);

      final promoMoves = legalMoves.where((m) => m.from == Square.parse('e7')).toList();
      // Should have 4 promotions: Q, R, B, N
      expect(promoMoves.length, 4);

      final game = ChessGame(initialFen: fen);
      final queenPromo = Move(
        from: Square.parse('e7'),
        to: Square.parse('e8'),
        promotion: PieceType.queen,
      );
      expect(game.makeMove(queenPromo), isTrue);
      expect(game.position.getPiece(Square.parse('e8'))?.type, PieceType.queen);
    });

    test('Castling kingside and queenside', () {
      // Setup where white can castle kingside
      const fen = 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1';
      final pos = FenService.fromFen(fen);
      final moves = ChessRules.generateLegalMoves(pos);

      final castlingMoves = moves.where((m) => m.isCastling).toList();
      expect(castlingMoves.length, 2); // O-O and O-O-O

      final game = ChessGame(initialFen: fen);
      final castleKingside = Move(from: Square.parse('e1'), to: Square.parse('g1'), isCastling: true);
      expect(game.makeMove(castleKingside), isTrue);

      // King at g1, Rook at f1
      expect(game.position.getPiece(Square.parse('g1'))?.type, PieceType.king);
      expect(game.position.getPiece(Square.parse('f1'))?.type, PieceType.rook);
      expect(game.position.getPiece(Square.parse('h1')), isNull);
    });

    test('Scholar\'s Mate (Checkmate)', () {
      final game = ChessGame();

      // 1. e4 e5
      game.makeMove(Move(from: Square.parse('e2'), to: Square.parse('e4')));
      game.makeMove(Move(from: Square.parse('e7'), to: Square.parse('e5')));

      // 2. Bc4 Nc6
      game.makeMove(Move(from: Square.parse('f1'), to: Square.parse('c4')));
      game.makeMove(Move(from: Square.parse('b8'), to: Square.parse('c6')));

      // 3. Qh5 Nf6
      game.makeMove(Move(from: Square.parse('d1'), to: Square.parse('h5')));
      game.makeMove(Move(from: Square.parse('g8'), to: Square.parse('f6')));

      // 4. Qxf7#
      final mateMove = Move(
        from: Square.parse('h5'),
        to: Square.parse('f7'),
        capturedPiece: const Piece.black(PieceType.pawn),
      );
      game.makeMove(mateMove);

      expect(game.isGameOver, isTrue);
      expect(game.result?.winner, PieceColor.white);
      expect(game.result?.reason, GameEndReason.checkmate);
    });

    test('Stalemate detection', () {
      // Famous stalemate: White Ka6, Qc7, Black Ka8 (if White to move Kh1... or Black Ka8, White Qf7, Black to move)
      // Fen where Black king on a8, White king on c6, White queen on c7: Black has 0 moves and not in check
      const fen = 'k7/2Q5/2K5/8/8/8/8/8 b - - 0 1';
      final pos = FenService.fromFen(fen);
      final result = ChessRules.evaluateGameResult(pos);

      expect(result, isNotNull);
      expect(result?.winner, isNull);
      expect(result?.reason, GameEndReason.stalemate);
    });

    test('Undo turn works correctly', () {
      final game = ChessGame();
      // White plays e4, Black plays e5
      game.makeMove(Move(from: Square.parse('e2'), to: Square.parse('e4')));
      game.makeMove(Move(from: Square.parse('e7'), to: Square.parse('e5')));
      expect(game.moveHistory.length, 2);

      // Undo turn vs AI (undoes 2 plies)
      game.undoTurn(vsAi: true);
      expect(game.moveHistory.length, 0);
      expect(game.position.activeColor, PieceColor.white);
    });
  });
}
