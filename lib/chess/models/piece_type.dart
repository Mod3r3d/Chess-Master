enum PieceType {
  pawn(value: 100, letter: 'p', sanLetter: ''),
  knight(value: 320, letter: 'n', sanLetter: 'N'),
  bishop(value: 330, letter: 'b', sanLetter: 'B'),
  rook(value: 500, letter: 'r', sanLetter: 'R'),
  queen(value: 900, letter: 'q', sanLetter: 'Q'),
  king(value: 20000, letter: 'k', sanLetter: 'K');

  final int value;
  final String letter;
  final String sanLetter;

  const PieceType({
    required this.value,
    required this.letter,
    required this.sanLetter,
  });

  static PieceType? fromChar(String char) {
    switch (char.toLowerCase()) {
      case 'p':
        return PieceType.pawn;
      case 'n':
        return PieceType.knight;
      case 'b':
        return PieceType.bishop;
      case 'r':
        return PieceType.rook;
      case 'q':
        return PieceType.queen;
      case 'k':
        return PieceType.king;
      default:
        return null;
    }
  }
}
