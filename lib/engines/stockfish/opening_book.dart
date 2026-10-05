import 'dart:math';
import '../../chess/fen/fen_service.dart';
import '../../chess/models/board_position.dart';
import '../../chess/models/move.dart';
import '../../chess/rules/chess_rules.dart';

class OpeningBook {
  static final Random _random = Random();

  /// Canonical opening database: map from FEN prefix (pieces, color, castling, ep) to candidate UCI moves
  static const Map<String, List<String>> _book = {
    // 0. Startpos
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -': [
      'e2e4', // King's Pawn (most common)
      'd2d4', // Queen's Pawn
      'c2c4', // English Opening
      'g1f3', // Reti Opening
    ],

    // 1. e4 responses
    'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3': [
      'e7e5', // Open Game
      'c7c5', // Sicilian Defense
      'e7e6', // French Defense
      'c7c6', // Caro-Kann Defense
      'd7d5', // Scandinavian Defense
      'g8f6', // Alekhine Defense
    ],

    // 1. d4 responses
    'rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq d3': [
      'd7d5', // Closed Game
      'g8f6', // Indian Defenses
      'e7e6', // Queen's Pawn Defense
      'c7c5', // Benoni Defense
      'f7f5', // Dutch Defense
    ],

    // 1. c4 responses (English)
    'rnbqkbnr/pppppppp/8/8/2P5/8/PP1PPPPP/RNBQKBNR b KQkq c3': [
      'e7e5',
      'c7c5',
      'g8f6',
      'e7e6',
    ],

    // 1. Nf3 responses (Reti)
    'rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq -': [
      'd7d5',
      'g8f6',
      'c7c5',
    ],

    // 1. e4 e5 (Open Game)
    'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6': [
      'g1f3', // King's Knight (standard)
      'f1c4', // Bishop's Opening
      'b1c3', // Vienna Game
      'd2d4', // Center Game
    ],

    // 1. e4 e5 2. Nf3
    'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq -': [
      'b8c6', // Main line
      'g8f6', // Petrov Defense
      'd7d6', // Philidor Defense
    ],

    // 1. e4 e5 2. Nf3 Nc6
    'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq -': [
      'f1c4', // Italian Game
      'f1b5', // Ruy Lopez
      'd2d4', // Scotch Game
      'b1c3', // Four Knights Game
    ],

    // 1. e4 e5 2. Nf3 Nc6 3. Bc4 (Italian Game)
    'r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq -': [
      'f8c5', // Giuoco Piano
      'g8f6', // Two Knights Defense
      'f8e7', // Hungarian Defense
    ],

    // 1. e4 e5 2. Nf3 Nc6 3. Bb5 (Ruy Lopez)
    'r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq -': [
      'a7a6', // Morphy Defense
      'g8f6', // Berlin Defense
      'd7d6', // Steinitz Defense
    ],

    // 1. e4 e5 2. Nf3 Nc6 3. d4 (Scotch Game)
    'r1bqkbnr/pppp1ppp/2n5/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R b KQkq d3': [
      'e5d4',
    ],

    // 1. e4 c5 (Sicilian Defense)
    'rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6': [
      'g1f3', // Open Sicilian
      'b1c3', // Closed Sicilian
      'c2c3', // Alapin Sicilian
    ],

    // 1. e4 c5 2. Nf3
    'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq -': [
      'd7d6', // Classical
      'b8c6', // Old Sicilian
      'e7e6', // French Sicilian
      'g7g6', // Accelerated Dragon
    ],

    // 1. e4 c5 2. Nf3 d6 3. d4
    'rnbqkbnr/pp2pppp/3p4/2p5/3PP3/5N2/PPP2PPP/RNBQKB1R b KQkq d3': [
      'c5d4',
    ],

    // 1. e4 e6 (French Defense)
    'rnbqkbnr/pppp1ppp/4p3/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq -': [
      'd2d4',
      'd2d3',
      'g1f3',
    ],

    // 1. e4 e6 2. d4 d5
    'rnbqkbnr/ppp2ppp/4p3/3p4/3PP3/8/PPP2PPP/RNBQKBNR w KQkq d6': [
      'b1c3', // Paulsen
      'b1d2', // Tarrasch
      'e4e5', // Advance
      'e4d5', // Exchange
    ],

    // 1. e4 c6 (Caro-Kann)
    'rnbqkbnr/pp1ppppp/2p5/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq -': [
      'd2d4',
      'g1f3',
      'b1c3',
    ],

    // 1. e4 c6 2. d4 d5
    'rnbqkbnr/pp2pppp/2p5/3p4/3PP3/8/PPP2PPP/RNBQKBNR w KQkq d6': [
      'b1c3', // Classical
      'e4e5', // Advance
      'e4d5', // Exchange
    ],

    // 1. d4 d5 (Closed Game)
    'rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq d6': [
      'c2c4', // Queen's Gambit
      'g1f3',
      'c1f4', // London System
    ],

    // 1. d4 d5 2. c4 (Queen's Gambit)
    'rnbqkbnr/ppp1pppp/8/3p4/2PP4/8/PP2PPPP/RNBQKBNR b KQkq c3': [
      'e7e6', // QGD Declined
      'c7c6', // Slav Defense
      'd5c4', // QGD Accepted
    ],

    // 1. d4 Nf6 (Indian Defenses)
    'rnbqkb1r/pppppppp/5n2/8/3P4/8/PPP1PPPP/RNBQKBNR w KQkq -': [
      'c2c4',
      'g1f3',
      'c1f4',
    ],

    // 1. d4 Nf6 2. c4
    'rnbqkb1r/pppppppp/5n2/8/2PP4/8/PP2PPPP/RNBQKBNR b KQkq c3': [
      'e7e6', // Nimzo/Bogo/Queen's Indian
      'g7g6', // King's Indian / Grunfeld
      'c7c5', // Benoni
    ],

    // Defending Scholar's Mate early attempts
    // 1. e4 e5 2. Qh5
    'rnbqkbnr/pppp1ppp/8/4p2Q/4P3/8/PPPP1PPP/RNB1KBNR b KQkq -': [
      'b8c6', // Defend e5 pawn
      'g8f6', // Attack queen
    ],

    // 1. e4 e5 2. Qh5 Nc6 3. Bc4 (Scholar's Mate threat)
    'r1bqkbnr/pppp1ppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq -': [
      'g7g6', // Blocks Qxf7#
      'd8e7', // Defends f7
    ],

    // 1. e4 e5 2. Bc4
    'rnbqkbnr/pppp1ppp/8/4p3/2B1P3/8/PPPP1PPP/RNBQK1NR b KQkq -': [
      'g8f6',
      'b8c6',
      'f8c5',
    ],
  };

  /// Check if the current position is in the opening book
  static Move? lookup(BoardPosition pos) {
    final key = FenService.toFen(pos).split(' ').take(4).join(' ');
    final moves = _book[key];
    if (moves == null || moves.isEmpty) return null;

    final legals = ChessRules.generateLegalMovesFast(pos);
    final validBookMoves = <Move>[];

    for (final uci in moves) {
      final match = legals.where((m) => m.uci == uci).firstOrNull;
      if (match != null) {
        validBookMoves.add(match);
      }
    }

    if (validBookMoves.isEmpty) return null;
    return validBookMoves[_random.nextInt(validBookMoves.length)];
  }
}
