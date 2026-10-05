import 'package:flutter/material.dart';
import '../chess/game/chess_game.dart';
import '../chess/models/move.dart';
import '../chess/models/piece.dart';
import '../chess/models/piece_color.dart';
import '../chess/models/piece_type.dart';
import '../chess/models/square.dart';
import '../core/theme/board_themes.dart';
import 'chess_piece_widget.dart';
import 'promotion_dialog.dart';

class ChessBoardWidget extends StatefulWidget {
  final ChessGame game;
  final BoardThemeData theme;
  final PieceColor playerColor;
  final Square? selectedSquare;
  final List<Move> legalMovesForSelected;
  final bool showCoordinates;
  final bool showLegalMoves;
  final bool isLocked;
  final void Function(Square square) onSquareTapped;
  final void Function(Move move) onMoveMade;

  const ChessBoardWidget({
    super.key,
    required this.game,
    required this.theme,
    required this.playerColor,
    required this.selectedSquare,
    required this.legalMovesForSelected,
    this.showCoordinates = true,
    this.showLegalMoves = true,
    this.isLocked = false,
    required this.onSquareTapped,
    required this.onMoveMade,
  });

  @override
  State<ChessBoardWidget> createState() => ChessBoardWidgetState();
}

class ChessBoardWidgetState extends State<ChessBoardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<double>? _slideAnimation;

  Move? _animatingMove;
  Piece? _animatingPiece;
  VoidCallback? _onAnimationCompleted;

  bool get isFlipped => widget.playerColor == PieceColor.black;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final cb = _onAnimationCompleted;
          setState(() {
            _animatingMove = null;
            _animatingPiece = null;
            _onAnimationCompleted = null;
          });
          cb?.call();
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Triggers smooth animated translation for a move
  void animateMove(Move move, Piece piece, VoidCallback onCompleted) {
    if (!mounted) {
      onCompleted();
      return;
    }

    setState(() {
      _animatingMove = move;
      _animatingPiece = piece;
      _onAnimationCompleted = onCompleted;
    });

    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.forward(from: 0.0);
  }

  Offset _squareToOffset(Square sq, double squareSize) {
    final col = isFlipped ? (7 - sq.file) : sq.file;
    final row = isFlipped ? sq.rank : (7 - sq.rank);
    return Offset(col * squareSize, row * squareSize);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final squareSize = boardSize / 8;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  offset: Offset(0, 10),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // 1. Board Background Layer (Tiles + Coordinates)
                RepaintBoundary(
                  child: _buildBackgroundTiles(boardSize, squareSize),
                ),

                // 2. Highlights Layer (Last move, Selected, Legal dots, Check)
                RepaintBoundary(
                  child: _buildHighlightsLayer(squareSize),
                ),

                // 3. Pieces Layer
                RepaintBoundary(
                  child: _buildPiecesLayer(squareSize),
                ),

                // 4. Animation Layer (Active sliding piece)
                if (_animatingMove != null && _animatingPiece != null && _slideAnimation != null)
                  AnimatedBuilder(
                    animation: _slideAnimation!,
                    builder: (context, child) {
                      final fromOffset = _squareToOffset(_animatingMove!.from, squareSize);
                      final toOffset = _squareToOffset(_animatingMove!.to, squareSize);
                      final currentOffset = Offset.lerp(fromOffset, toOffset, _slideAnimation!.value)!;

                      return Positioned(
                        left: currentOffset.dx,
                        top: currentOffset.dy,
                        width: squareSize,
                        height: squareSize,
                        child: ChessPieceWidget(
                          piece: _animatingPiece!,
                          size: squareSize,
                          theme: widget.theme,
                        ),
                      );
                    },
                  ),

                // 5. Interaction Layer (Touch handler grid)
                _buildInteractionLayer(squareSize),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundTiles(double boardSize, double squareSize) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final file = isFlipped ? (7 - col) : col;
        final rank = isFlipped ? row : (7 - row);
        final isLight = (file + rank) % 2 != 0;

        final squareColor = isLight ? widget.theme.lightSquare : widget.theme.darkSquare;

        return Container(
          color: squareColor,
          child: Stack(
            children: [
              if (widget.showCoordinates) ...[
                // File letter (a-h)
                if (row == 7)
                  Positioned(
                    right: 3,
                    bottom: 1,
                    child: Text(
                      String.fromCharCode('a'.codeUnitAt(0) + file),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isLight ? widget.theme.darkSquare : widget.theme.lightSquare,
                      ),
                    ),
                  ),
                // Rank number (1-8)
                if (col == 0)
                  Positioned(
                    left: 3,
                    top: 1,
                    child: Text(
                      '${rank + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isLight ? widget.theme.darkSquare : widget.theme.lightSquare,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightsLayer(double squareSize) {
    final highlights = <Widget>[];

    // Last move highlights
    final last = widget.game.lastMove;
    if (last != null) {
      for (final sq in [last.from, last.to]) {
        final offset = _squareToOffset(sq, squareSize);
        final color = sq.isLight ? widget.theme.lastMoveLight : widget.theme.lastMoveDark;
        highlights.add(
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: squareSize,
            height: squareSize,
            child: Container(color: color.withValues(alpha: 0.65)),
          ),
        );
      }
    }

    // Selected square highlight
    if (widget.selectedSquare != null) {
      final offset = _squareToOffset(widget.selectedSquare!, squareSize);
      highlights.add(
        Positioned(
          left: offset.dx,
          top: offset.dy,
          width: squareSize,
          height: squareSize,
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.selectedSquare,
              border: Border.all(color: const Color(0xFFE5A93C), width: 2.5),
            ),
          ),
        ),
      );
    }

    // King check indicator
    if (widget.game.inCheck && widget.game.checkSquare != null) {
      final offset = _squareToOffset(widget.game.checkSquare!, squareSize);
      highlights.add(
        Positioned(
          left: offset.dx,
          top: offset.dy,
          width: squareSize,
          height: squareSize,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: widget.theme.checkGlow, width: 3),
              gradient: RadialGradient(
                colors: [
                  widget.theme.checkGlow.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
        ),
      );
    }

    // Legal move hint indicators
    if (widget.showLegalMoves) {
      for (final move in widget.legalMovesForSelected) {
        final offset = _squareToOffset(move.to, squareSize);
        highlights.add(
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: squareSize,
            height: squareSize,
            child: Center(
              child: move.isCapture
                  ? Container(
                      width: squareSize * 0.82,
                      height: squareSize * 0.82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.theme.legalMoveDot.withValues(alpha: 0.7),
                          width: squareSize * 0.08,
                        ),
                      ),
                    )
                  : Container(
                      width: squareSize * 0.32,
                      height: squareSize * 0.32,
                      decoration: BoxDecoration(
                        color: widget.theme.legalMoveDot,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        );
      }
    }

    return Stack(children: highlights);
  }

  Widget _buildPiecesLayer(double squareSize) {
    final pieceWidgets = <Widget>[];

    for (int i = 0; i < 64; i++) {
      final sq = Square.fromIndex(i);
      final piece = widget.game.position.getPiece(sq);
      if (piece == null) continue;

      // If this piece is currently animating its move from this square, don't draw it at origin
      if (_animatingMove != null && _animatingMove!.from == sq) continue;

      final offset = _squareToOffset(sq, squareSize);
      pieceWidgets.add(
        Positioned(
          left: offset.dx,
          top: offset.dy,
          width: squareSize,
          height: squareSize,
          child: ChessPieceWidget(
            piece: piece,
            size: squareSize,
            theme: widget.theme,
          ),
        ),
      );
    }

    return Stack(children: pieceWidgets);
  }

  Widget _buildInteractionLayer(double squareSize) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final file = isFlipped ? (7 - col) : col;
        final rank = isFlipped ? row : (7 - row);
        final square = Square(file, rank);

        final legalMove = widget.legalMovesForSelected.where((m) => m.to == square).firstOrNull;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.isLocked || _animatingMove != null) return;
            _handleSquareTap(context, square, legalMove);
          },
          child: const SizedBox.expand(),
        );
      },
    );
  }

  Future<void> _handleSquareTap(BuildContext context, Square square, Move? legalMove) async {
    if (legalMove != null) {
      final movingPiece = widget.game.position.getPiece(legalMove.from);
      final isPromotion = movingPiece?.type == PieceType.pawn &&
          (legalMove.to.rank == 7 || legalMove.to.rank == 0);

      if (isPromotion) {
        final chosenType = await showDialog<PieceType>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => PromotionDialog(
            color: movingPiece!.color,
            theme: widget.theme,
          ),
        );

        if (chosenType != null) {
          widget.onMoveMade(legalMove.copyWith(promotion: chosenType));
        }
      } else {
        widget.onMoveMade(legalMove);
      }
    } else {
      widget.onSquareTapped(square);
    }
  }
}
