import 'dart:async';
import '../bots/bot_profile.dart';
import 'chess_engine.dart';
import 'engine_move.dart';
import 'mittens/mittens_engine.dart';
import 'stockfish/stockfish_engine.dart';

class EngineManager {
  static final EngineManager _instance = EngineManager._internal();
  factory EngineManager() => _instance;
  EngineManager._internal();

  final Map<String, ChessEngine> _engines = {
    'stockfish': StockfishEngine(),
    'mittens': MittensEngine(),
  };

  ChessEngine? _currentEngine;
  BotProfile? _configuredBot;
  bool _isSearching = false;

  bool get isSearching => _isSearching;
  ChessEngine? get currentEngine => _currentEngine;
  BotProfile? get configuredBot => _configuredBot;

  Future<void> initialize() async {
    for (final engine in _engines.values) {
      await engine.initialize();
    }
    _currentEngine = _engines['stockfish'];
  }

  void selectEngine(String engineId) {
    if (_engines.containsKey(engineId)) {
      _currentEngine = _engines[engineId];
    } else {
      _currentEngine = _engines['stockfish'];
    }
  }

  void configureBot(BotProfile bot) {
    _configuredBot = bot;
    selectEngine(bot.engineId);
  }

  Future<void> setPosition(String fen, {List<String>? moves}) async {
    if (_currentEngine == null) await initialize();
    await _currentEngine?.setPosition(fen, moves: moves);
  }

  Future<EngineMove?> searchMove({BotProfile? overrideBot}) async {
    final bot = overrideBot ?? _configuredBot;
    if (_currentEngine == null) await initialize();

    _isSearching = true;
    try {
      final move = await _currentEngine!.getBestMove(
        depth: bot?.depth ?? 4,
        moveTimeMs: bot?.moveTimeMs ?? 800,
        skillLevel: bot?.skillLevel ?? 10,
        randomness: bot?.randomness ?? 0.0,
      );
      _isSearching = false;
      return move;
    } catch (e) {
      _isSearching = false;
      return null;
    }
  }

  Future<void> stopSearch() async {
    _isSearching = false;
    await _currentEngine?.stop();
  }

  Future<void> dispose() async {
    _isSearching = false;
    for (final engine in _engines.values) {
      await engine.dispose();
    }
  }
}
