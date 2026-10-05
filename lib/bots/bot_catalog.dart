import 'bot_personality.dart';
import 'bot_profile.dart';
import 'difficulty.dart';

class BotCatalog {
  static const List<BotProfile> stockfishBots = [
    BotProfile(
      id: 'stockfish_beginner',
      name: 'Beginner',
      engineId: 'stockfish',
      displayedElo: '~600',
      eloValue: 600,
      avatarEmoji: '🐣',
      subtitle: 'Người mới học chơi cờ',
      description: 'Chơi các nước đi đơn giản, thỉnh thoảng mắc sơ hở và bỏ quân.',
      difficulty: Difficulty.beginner,
      personality: BotPersonality.playful,
      depth: 1,
      moveTimeMs: 400,
      randomness: 0.35,
      skillLevel: 1,
      cpuUsage: 'Rất thấp',
    ),
    BotProfile(
      id: 'stockfish_novice',
      name: 'Novice',
      engineId: 'stockfish',
      displayedElo: '~800',
      eloValue: 800,
      avatarEmoji: '🙂',
      subtitle: 'Tập sự cơ bản',
      description: 'Biết bảo vệ quân tốt hơn, nhưng dễ bị bẫy chiến thuật.',
      difficulty: Difficulty.novice,
      personality: BotPersonality.cautious,
      depth: 2,
      moveTimeMs: 500,
      randomness: 0.22,
      skillLevel: 4,
      cpuUsage: 'Thấp',
    ),
    BotProfile(
      id: 'stockfish_casual',
      name: 'Casual',
      engineId: 'stockfish',
      displayedElo: '~1000',
      eloValue: 1000,
      avatarEmoji: '♟️',
      subtitle: 'Người chơi nghiệp dư',
      description: 'Nắm được các khai cuộc cơ bản, bắt đầu tìm kiếm đòn chiến thuật 1 nước.',
      difficulty: Difficulty.casual,
      personality: BotPersonality.balanced,
      depth: 3,
      moveTimeMs: 650,
      randomness: 0.12,
      skillLevel: 8,
      cpuUsage: 'Thấp',
    ),
    BotProfile(
      id: 'stockfish_intermediate',
      name: 'Intermediate',
      engineId: 'stockfish',
      displayedElo: '~1200',
      eloValue: 1200,
      avatarEmoji: '♞',
      subtitle: 'Kỳ thủ trung bình',
      description: 'Lối chơi chắc chắn, tận dụng sai lầm đối phương và nhìn xa 2-3 nước.',
      difficulty: Difficulty.intermediate,
      personality: BotPersonality.balanced,
      depth: 4,
      moveTimeMs: 800,
      randomness: 0.05,
      skillLevel: 12,
      cpuUsage: 'Trung bình',
    ),
    BotProfile(
      id: 'stockfish_advanced',
      name: 'Advanced',
      engineId: 'stockfish',
      displayedElo: '~1400',
      eloValue: 1400,
      avatarEmoji: '♜',
      subtitle: 'Kỳ thủ khá',
      description: 'Tính toán đòn phối hợp chính xác, kiểm soát trung tâm và cấu trúc tốt.',
      difficulty: Difficulty.advanced,
      personality: BotPersonality.tactical,
      depth: 5,
      moveTimeMs: 1000,
      randomness: 0.0,
      skillLevel: 15,
      cpuUsage: 'Trung bình',
    ),
    BotProfile(
      id: 'stockfish_expert',
      name: 'Expert',
      engineId: 'stockfish',
      displayedElo: '~1600',
      eloValue: 1600,
      avatarEmoji: '♛',
      subtitle: 'Chuyên gia cờ vua',
      description: 'Khai cuộc sâu rộng, tàn cuộc chuẩn xác, hầu như không mắc sai sót sơ đẳng.',
      difficulty: Difficulty.expert,
      personality: BotPersonality.aggressive,
      depth: 6,
      moveTimeMs: 1200,
      randomness: 0.0,
      skillLevel: 18,
      cpuUsage: 'Cao',
    ),
    BotProfile(
      id: 'stockfish_master',
      name: 'Master',
      engineId: 'stockfish',
      displayedElo: '~1800',
      eloValue: 1800,
      avatarEmoji: '👑',
      subtitle: 'Kiện tướng offline',
      description: 'Độ chính xác tột đỉnh, tính toán nhiều biến sâu sắc, cực kỳ thử thách.',
      difficulty: Difficulty.master,
      personality: BotPersonality.ruthless,
      depth: 7,
      moveTimeMs: 1500,
      randomness: 0.0,
      skillLevel: 20,
      cpuUsage: 'Cao',
    ),
  ];

  static const BotProfile mittensBot = BotProfile(
    id: 'mittens',
    name: 'Mittens',
    engineId: 'mittens',
    displayedElo: '1 (?)',
    eloValue: 2000,
    avatarEmoji: '😺',
    subtitle: 'Chú mèo bí ẩn',
    description: 'Bên ngoài ngây thơ vô số tội với 1 Elo, nhưng ẩn giấu sức mạnh hủy diệt và những lời thì thầm meow rùng rợn!',
    difficulty: Difficulty.legendary,
    personality: BotPersonality.playful,
    depth: 6,
    moveTimeMs: 1100,
    randomness: 0.0,
    skillLevel: 20,
    cpuUsage: 'Cao',
  );

  static List<BotProfile> getAllBots() {
    return [...stockfishBots, mittensBot];
  }

  static BotProfile getBotById(String id) {
    if (id == 'mittens') return mittensBot;
    return stockfishBots.firstWhere(
      (b) => b.id == id,
      orElse: () => stockfishBots[3], // Default Intermediate
    );
  }

  static List<BotProfile> getBotsForEngine(String engineId) {
    if (engineId == 'mittens') {
      return [mittensBot];
    }
    return stockfishBots;
  }
}
