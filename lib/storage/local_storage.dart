import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedGameRecord {
  final String id;
  final DateTime date;
  final String botName;
  final String botElo;
  final String resultText;
  final String pgn;
  final bool isWin;

  const SavedGameRecord({
    required this.id,
    required this.date,
    required this.botName,
    required this.botElo,
    required this.resultText,
    required this.pgn,
    required this.isWin,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'botName': botName,
    'botElo': botElo,
    'resultText': resultText,
    'pgn': pgn,
    'isWin': isWin,
  };

  factory SavedGameRecord.fromJson(Map<String, dynamic> json) => SavedGameRecord(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    botName: json['botName'] as String,
    botElo: json['botElo'] as String,
    resultText: json['resultText'] as String,
    pgn: json['pgn'] as String,
    isWin: json['isWin'] as bool? ?? false,
  );
}

class LocalStorage {
  static const _keyTheme = 'pref_board_theme';
  static const _keySound = 'pref_sound_enabled';
  static const _keyHaptic = 'pref_haptic_enabled';
  static const _keyLegalMoves = 'pref_show_legal_moves';
  static const _keyCoordinates = 'pref_show_coordinates';
  static const _keySelectedBot = 'pref_selected_bot';
  static const _keySelectedEngine = 'pref_selected_engine';
  static const _keyTimeControl = 'pref_time_control_index';
  static const _keyGames = 'saved_games_history';

  static Future<String> getThemeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme) ?? 'wood';
  }

  static Future<void> setThemeId(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, themeId);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySound) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, enabled);
  }

  static Future<bool> getHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHaptic) ?? true;
  }

  static Future<void> setHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptic, enabled);
  }

  static Future<bool> getShowLegalMoves() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLegalMoves) ?? true;
  }

  static Future<void> setShowLegalMoves(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLegalMoves, value);
  }

  static Future<bool> getShowCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCoordinates) ?? true;
  }

  static Future<void> setShowCoordinates(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCoordinates, value);
  }

  static Future<String> getSelectedBotId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedBot) ?? 'stockfish_intermediate';
  }

  static Future<void> setSelectedBotId(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedBot, botId);
  }

  static Future<String> getSelectedEngineId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedEngine) ?? 'stockfish';
  }

  static Future<void> setSelectedEngineId(String engineId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedEngine, engineId);
  }

  static Future<int> getTimeControlIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTimeControl) ?? 2; // Default 5+0
  }

  static Future<void> setTimeControlIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTimeControl, index);
  }

  static Future<List<SavedGameRecord>> getGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyGames) ?? [];
    return jsonList.map((item) => SavedGameRecord.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> saveGame(SavedGameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getGameHistory();
    list.insert(0, record);
    // Keep max 50 recent games
    if (list.length > 50) {
      list.removeRange(50, list.length);
    }
    final encoded = list.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyGames, encoded);
  }
}
