import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chess_master/chess/game/chess_game.dart';
import 'package:chess_master/chess/game/game_phase.dart';
import 'package:chess_master/chess/models/move.dart';
import 'package:chess_master/chess/models/piece.dart';
import 'package:chess_master/chess/models/piece_color.dart';
import 'package:chess_master/chess/models/piece_type.dart';
import 'package:chess_master/chess/models/square.dart';
import 'package:chess_master/core/theme/board_themes.dart';
import 'package:chess_master/screens/game/game_screen.dart';
import 'package:chess_master/widgets/pieces/vector_chess_pieces.dart';

void main() {
  group('Local PvP & v2 Architecture Tests', () {
    test('PvP undo turns reverts exactly 1 ply', () {
      final game = ChessGame();

      // P1 moves e4
      game.makeMove(Move(from: Square.parse('e2'), to: Square.parse('e4')));
      expect(game.moveHistory.length, 1);

      // P2 moves e5
      game.makeMove(Move(from: Square.parse('e7'), to: Square.parse('e5')));
      expect(game.moveHistory.length, 2);

      // In Local PvP, undoing reverts 1 move (P2's move) so P2 can rethink their move
      final undone = game.undoTurn(vsAi: false);
      expect(undone, isTrue);
      expect(game.moveHistory.length, 1);
      expect(game.lastMove?.to.name, 'e4');
    });

    test('GamePhase canReceiveInput respects states', () {
      expect(GamePhase.playerTurn.canReceiveInput, isTrue);
      expect(GamePhase.engineThinking.canReceiveInput, isFalse);
      expect(GamePhase.animating.canReceiveInput, isFalse);
      expect(GamePhase.gameOver.canReceiveInput, isFalse);
      expect(GamePhase.paused.canReceiveInput, isFalse);
      expect(GamePhase.setup.canReceiveInput, isFalse);
    });

    test('BoardThemeData defines distinct piece colors for each theme', () {
      for (final theme in BoardThemeData.allThemes) {
        expect(theme.whitePieceFill, isNotNull);
        expect(theme.whitePieceStroke, isNotNull);
        expect(theme.blackPieceFill, isNotNull);
        expect(theme.blackPieceStroke, isNotNull);
      }
      // Ensure Cyberpunk and Midnight have distinct custom piece palettes
      expect(BoardThemeData.cyberpunk.whitePieceFill, isNot(equals(BoardThemeData.wood.whitePieceFill)));
      expect(BoardThemeData.midnight.blackPieceFill, isNot(equals(BoardThemeData.wood.blackPieceFill)));
    });

    testWidgets('VectorChessPieceWidget renders with all board themes without errors', (WidgetTester tester) async {
      for (final theme in BoardThemeData.allThemes) {
        for (final type in PieceType.values) {
          await tester.pumpWidget(
            VectorChessPieceWidget(
              piece: Piece.white(type),
              size: 40,
              theme: theme,
            ),
          );
          expect(find.byType(VectorChessPieceWidget), findsOneWidget);

          await tester.pumpWidget(
            VectorChessPieceWidget(
              piece: Piece.black(type),
              size: 40,
              theme: theme,
            ),
          );
          expect(find.byType(VectorChessPieceWidget), findsOneWidget);
        }
      }
    });

    testWidgets('GameScreen shows exit confirmation popup and stays when dismissed', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(
            gameMode: GameMode.localPvp,
            playerColor: PieceColor.white,
            timeControlMinutes: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find AppBar back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Tap back button
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify exit confirmation dialog
      expect(find.text('Thoát ván đấu?'), findsOneWidget);
      expect(find.text('Ở lại chơi'), findsOneWidget);
      expect(find.text('Thoát'), findsOneWidget);

      // Tap 'Ở lại chơi'
      await tester.tap(find.text('Ở lại chơi'));
      await tester.pumpAndSettle();

      // Verify dialog is gone and GameScreen is still active
      expect(find.text('Thoát ván đấu?'), findsNothing);
      expect(find.byType(GameScreen), findsOneWidget);
    });
  });
}
