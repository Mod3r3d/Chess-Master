enum Difficulty {
  beginner(nameVi: 'Người mới', colorHex: 0xFF4CAF50),
  novice(nameVi: 'Mới chơi', colorHex: 0xFF8BC34A),
  casual(nameVi: 'Cơ bản', colorHex: 0xFFCDDC39),
  intermediate(nameVi: 'Trung bình', colorHex: 0xFFFFC107),
  advanced(nameVi: 'Khá', colorHex: 0xFFFF9800),
  expert(nameVi: 'Khó', colorHex: 0xFFFF5722),
  master(nameVi: 'Rất khó', colorHex: 0xFFE91E63),
  legendary(nameVi: 'Huyền thoại', colorHex: 0xFF9C27B0);

  final String nameVi;
  final int colorHex;

  const Difficulty({required this.nameVi, required this.colorHex});
}
