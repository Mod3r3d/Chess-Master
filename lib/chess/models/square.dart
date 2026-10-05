class Square {
  final int file; // 0 (a) to 7 (h)
  final int rank; // 0 (1) to 7 (8)

  const Square(this.file, this.rank)
      : assert(file >= 0 && file < 8),
        assert(rank >= 0 && rank < 8);

  const Square.fromIndex(int index)
      : file = index % 8,
        rank = index ~/ 8;

  int get index => rank * 8 + file;

  String get fileChar => String.fromCharCode('a'.codeUnitAt(0) + file);
  String get rankChar => (rank + 1).toString();
  String get name => '$fileChar$rankChar';

  bool get isLight => (file + rank) % 2 != 0;
  bool get isDark => !isLight;

  static Square? tryParse(String str) {
    if (str.length != 2) return null;
    final f = str.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
    final r = str.codeUnitAt(1) - '1'.codeUnitAt(0);
    if (f < 0 || f > 7 || r < 0 || r > 7) return null;
    return Square(f, r);
  }

  static Square parse(String str) {
    final sq = tryParse(str);
    if (sq == null) throw FormatException('Invalid square notation: $str');
    return sq;
  }

  static final List<Square> _cachedSquares = List.generate(64, (i) => Square.fromIndex(i));

  static Square fromCoords(int file, int rank) {
    assert(isValid(file, rank));
    return _cachedSquares[rank * 8 + file];
  }

  static bool isValid(int file, int rank) {
    return file >= 0 && file < 8 && rank >= 0 && rank < 8;
  }

  Square? offset(int df, int dr) {
    final nf = file + df;
    final nr = rank + dr;
    if (isValid(nf, nr)) {
      return _cachedSquares[nr * 8 + nf];
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Square && runtimeType == other.runtimeType && file == other.file && rank == other.rank;

  @override
  int get hashCode => file.hashCode ^ rank.hashCode;

  @override
  String toString() => name;
}
