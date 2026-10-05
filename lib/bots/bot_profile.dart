import 'bot_personality.dart';
import 'difficulty.dart';

class BotProfile {
  final String id;
  final String name;
  final String engineId;
  final String displayedElo;
  final int eloValue;
  final String avatarEmoji;
  final String subtitle;
  final String description;
  final Difficulty difficulty;
  final BotPersonality personality;
  final int depth;
  final int moveTimeMs;
  final double randomness;
  final int skillLevel;
  final String cpuUsage;

  const BotProfile({
    required this.id,
    required this.name,
    required this.engineId,
    required this.displayedElo,
    required this.eloValue,
    required this.avatarEmoji,
    required this.subtitle,
    required this.description,
    required this.difficulty,
    required this.personality,
    required this.depth,
    required this.moveTimeMs,
    required this.randomness,
    required this.skillLevel,
    this.cpuUsage = 'Thấp',
  });

  bool get isMittens => id == 'mittens';
}
