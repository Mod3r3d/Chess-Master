enum PieceColor {
  white,
  black;

  PieceColor get opposite => this == white ? black : white;
  bool get isWhite => this == white;
  bool get isBlack => this == black;

  String get displayName => this == white ? 'Trắng' : 'Đen';
}
