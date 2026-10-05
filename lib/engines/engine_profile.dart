class EngineProfile {
  final String id;
  final String name;
  final String title;
  final String description;
  final String iconEmoji;
  final String author;
  final String version;

  const EngineProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.author,
    required this.version,
  });

  static const List<EngineProfile> availableEngines = [
    EngineProfile(
      id: 'stockfish',
      name: 'Stockfish',
      title: 'Động cơ cờ vua cổ điển',
      description: 'Engine mã nguồn mở mạnh mẽ hàng đầu thế giới, với 7 cấp độ Elo từ 600 đến 1800+.',
      iconEmoji: '♟️',
      author: 'Stockfish Community',
      version: '16.1 UCI',
    ),
    EngineProfile(
      id: 'mittens',
      name: 'Mittens',
      title: 'Đối thủ mèo bí ẩn',
      description: 'Chú mèo với chỉ số 1 Elo giả tạo, gieo rắc nỗi sợ hãi trên từng nước đi và bình luận tâm lý meow.',
      iconEmoji: '😺',
      author: 'Chess Master Personality Studio',
      version: '1.0 Cat-Engine',
    ),
  ];
}
