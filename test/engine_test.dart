import 'package:flutter_test/flutter_test.dart';
import 'package:chess_master/bots/bot_catalog.dart';
import 'package:chess_master/chess/fen/fen_service.dart';
import 'package:chess_master/engines/engine_manager.dart';
import 'package:chess_master/engines/mittens/mittens_engine.dart';
import 'package:chess_master/engines/stockfish/stockfish_engine.dart';

void main() {
  group('Engine & Bot Tests', () {
    test('Stockfish engine finds legal move from startpos', () async {
      final engine = StockfishEngine();
      await engine.initialize();
      await engine.setPosition(FenService.initialFen);

      final result = await engine.getBestMove(depth: 2, moveTimeMs: 300);
      expect(result.move, isNotNull);
      expect(result.depth, 2);
    });

    test('Stockfish engine finds Mate-in-1 at depth 5 quickly', () async {
      final engine = StockfishEngine();
      await engine.initialize();
      // Position with Scholar's Mate: Qxf7# is winning immediately
      final fen = 'r1bqkb1r/pppp1ppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 0 4';
      await engine.setPosition(fen);

      final result = await engine.getBestMove(depth: 5, moveTimeMs: 1500);
      expect(result.move.uci, 'h5f7');
    });

    test('Stockfish engine captures hanging Queen immediately', () async {
      final engine = StockfishEngine();
      await engine.initialize();
      // Black blundered Queen to e4, White Knight on c3 can capture it: Nxe4 (c3e4)
      await engine.setPosition('rnb1kbnr/pppp1ppp/8/4p3/4q3/2N5/PPPP1PPP/R1BQKBNR w KQkq - 0 3');

      final result = await engine.getBestMove(depth: 4, moveTimeMs: 800);
      expect(result.move.uci, 'c3e4');
    });

    test('Stockfish engine executes Back-Rank Checkmate', () async {
      final engine = StockfishEngine();
      await engine.initialize();
      // Back rank mate: Re8#
      await engine.setPosition('6k1/5ppp/8/8/8/8/8/4R1K1 w - - 0 1');

      final result = await engine.getBestMove(depth: 3, moveTimeMs: 500);
      expect(result.move.uci, 'e1e8');
    });

    test('Master bot finds deep tactical defense / attack', () async {
      final masterBot = BotCatalog.getBotById('stockfish_master');
      final engine = StockfishEngine();
      await engine.initialize();
      await engine.setPosition('r1bqkb1r/pppp1ppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 0 4');

      final result = await engine.getBestMove(
        depth: masterBot.depth,
        moveTimeMs: masterBot.moveTimeMs,
        randomness: masterBot.randomness,
      );
      expect(result.move.uci, 'h5f7');
    });

    test('Mittens engine returns move and personality dialogue', () async {
      final mittens = MittensEngine();
      await mittens.initialize();
      await mittens.setPosition(FenService.initialFen);

      final result = await mittens.getBestMove(depth: 3, moveTimeMs: 400);
      expect(result.move, isNotNull);
      expect(result.dialogue, isNotNull);
      expect(result.dialogue!.isNotEmpty, isTrue);
    });

    test('EngineManager switches and configures bots', () async {
      final manager = EngineManager();
      await manager.initialize();

      // Configure beginner bot
      manager.configureBot(BotCatalog.stockfishBots[0]);
      expect(manager.currentEngine?.id, 'stockfish');
      expect(manager.configuredBot?.displayedElo, '~600');

      // Configure Mittens
      manager.configureBot(BotCatalog.mittensBot);
      expect(manager.currentEngine?.id, 'mittens');
      expect(manager.configuredBot?.isMittens, isTrue);
    });
  });
}
