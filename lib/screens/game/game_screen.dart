import 'dart:async';
import 'package:flutter/material.dart';
import '../../bots/bot_profile.dart';
import '../../chess/fen/fen_service.dart';
import '../../chess/game/chess_game.dart';
import '../../chess/game/game_phase.dart';
import '../../chess/models/move.dart';
import '../../chess/models/piece_color.dart';
import '../../chess/models/square.dart';
import '../../chess/pgn/pgn_service.dart';
import '../../core/theme/board_themes.dart';
import '../../core/utils/sound_service.dart';
import '../../engines/engine_manager.dart';
import '../../storage/local_storage.dart';
import '../../chess/models/piece.dart';
import '../../chess/models/piece_type.dart';
import '../../widgets/captured_pieces_bar.dart';
import '../../widgets/chess_board.dart';
import '../../widgets/chess_clock.dart';
import '../../widgets/chess_piece_widget.dart';
import '../result/game_result_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameMode gameMode;
  final BotProfile? bot;
  final PieceColor playerColor;
  final int timeControlMinutes; // 0 = unlimited
  final bool autoFlipPvp;

  const GameScreen({
    super.key,
    this.gameMode = GameMode.vsAi,
    this.bot,
    required this.playerColor,
    this.timeControlMinutes = 5,
    this.autoFlipPvp = true,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ChessBoardWidgetState> _boardKey = GlobalKey<ChessBoardWidgetState>();
  late ChessGame _game;
  final SoundService _sound = SoundService();
  final EngineManager _engineManager = EngineManager();

  // State Machine
  GamePhase _phase = GamePhase.setup;

  // Selection
  Square? _selectedSquare;
  List<Move> _legalMovesForSelected = [];

  // Theme & Display
  BoardThemeData _boardTheme = BoardThemeData.wood;
  bool _showCoordinates = true;
  bool _showLegalMoves = true;

  // Active perspective color (can auto-flip in local PvP)
  late PieceColor _perspectiveColor;

  // Bot state
  String? _botDialogue;

  // Clocks (Decoupled with ValueNotifier to avoid whole-board rebuilds!)
  late final ValueNotifier<int> _whiteTimeNotifier;
  late final ValueNotifier<int> _blackTimeNotifier;
  late final ValueNotifier<bool> _whiteActiveNotifier;
  late final ValueNotifier<bool> _blackActiveNotifier;
  Timer? _clockTimer;

  bool get isVsAi => widget.gameMode.isVsAi;
  bool get isLocalPvp => widget.gameMode.isLocalPvp;

  @override
  void initState() {
    super.initState();
    _game = ChessGame();
    _perspectiveColor = widget.playerColor;

    final totalSeconds = widget.timeControlMinutes * 60;
    _whiteTimeNotifier = ValueNotifier<int>(totalSeconds);
    _blackTimeNotifier = ValueNotifier<int>(totalSeconds);
    _whiteActiveNotifier = ValueNotifier<bool>(true);
    _blackActiveNotifier = ValueNotifier<bool>(false);

    _loadPreferences();

    // Only configure and lazy-init engine if playing vs AI
    if (isVsAi && widget.bot != null) {
      _engineManager.configureBot(widget.bot!);
    }

    _startClockTimer();

    // Initial phase
    if (isVsAi && widget.playerColor == PieceColor.black) {
      _phase = GamePhase.engineThinking;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerAiMove();
      });
    } else {
      _phase = GamePhase.playerTurn;
    }
  }

  Future<void> _loadPreferences() async {
    final themeId = await LocalStorage.getThemeId();
    final coords = await LocalStorage.getShowCoordinates();
    final hints = await LocalStorage.getShowLegalMoves();
    final sound = await LocalStorage.getSoundEnabled();
    final haptic = await LocalStorage.getHapticEnabled();

    if (mounted) {
      setState(() {
        _boardTheme = BoardThemeData.getById(themeId);
        _showCoordinates = coords;
        _showLegalMoves = hints;
        _sound.soundEnabled = sound;
        _sound.hapticEnabled = haptic;
      });
    }
  }

  void _startClockTimer() {
    if (widget.timeControlMinutes == 0) return; // Unlimited

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_game.isGameOver || _phase == GamePhase.gameOver || !mounted) return;

      if (_game.activeColor == PieceColor.white) {
        if (_whiteTimeNotifier.value > 0) {
          _whiteTimeNotifier.value--;
          if (_whiteTimeNotifier.value == 0) {
            _handleTimeout(PieceColor.white);
          }
        }
      } else {
        if (_blackTimeNotifier.value > 0) {
          _blackTimeNotifier.value--;
          if (_blackTimeNotifier.value == 0) {
            _handleTimeout(PieceColor.black);
          }
        }
      }
    });
  }

  void _updateActiveClockNotifier() {
    final isWhiteTurn = _game.activeColor == PieceColor.white;
    _whiteActiveNotifier.value = isWhiteTurn;
    _blackActiveNotifier.value = !isWhiteTurn;
  }

  void _handleTimeout(PieceColor losingColor) {
    _phase = GamePhase.gameOver;
    _game.timeout(losingColor);
    _sound.playGameEndSound(isWin: widget.playerColor != losingColor);
    _showGameOverDialog();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    if (isVsAi) {
      _engineManager.stopSearch();
    }
    _whiteTimeNotifier.dispose();
    _blackTimeNotifier.dispose();
    _whiteActiveNotifier.dispose();
    _blackActiveNotifier.dispose();
    super.dispose();
  }

  void _onSquareTapped(Square square) {
    if (!_phase.canReceiveInput || _game.isGameOver) return;

    // Check active player turn
    if (isVsAi && _game.activeColor != widget.playerColor) return;

    final piece = _game.position.getPiece(square);

    if (_selectedSquare == null) {
      if (piece != null && piece.color == _game.activeColor) {
        setState(() {
          _selectedSquare = square;
          _legalMovesForSelected = _game.legalMovesForSquare(square);
        });
      }
    } else {
      if (piece != null && piece.color == _game.activeColor) {
        // Change selected piece
        setState(() {
          _selectedSquare = square;
          _legalMovesForSelected = _game.legalMovesForSquare(square);
        });
      } else {
        // Deselect
        setState(() {
          _selectedSquare = null;
          _legalMovesForSelected = [];
        });
      }
    }
  }

  void _onMoveMade(Move move) {
    if (!_phase.canReceiveInput || _game.isGameOver) return;
    if (isVsAi && _game.activeColor != widget.playerColor) return;

    final movingPiece = _game.position.getPiece(move.from);
    if (movingPiece == null) return;

    // 1. Enter animating phase and lock input
    setState(() {
      _phase = GamePhase.animating;
      _selectedSquare = null;
      _legalMovesForSelected = [];
    });

    // 2. Play smooth piece translation animation
    _boardKey.currentState?.animateMove(move, movingPiece, () {
      if (!mounted) return;

      // 3. Commit move to game
      final success = _game.makeMove(move);
      if (!success) {
        setState(() => _phase = GamePhase.playerTurn);
        return;
      }

      _playSoundForMove(move);
      _updateActiveClockNotifier();

      if (_game.isGameOver) {
        setState(() => _phase = GamePhase.gameOver);
        _showGameOverDialog();
        return;
      }

      // Next turn
      if (isVsAi) {
        setState(() => _phase = GamePhase.engineThinking);
        _triggerAiMove();
      } else {
        // Local PvP turn switch
        setState(() {
          if (widget.autoFlipPvp) {
            _perspectiveColor = _game.activeColor;
          }
          _phase = GamePhase.playerTurn;
        });
      }
    });
  }

  Future<void> _triggerAiMove() async {
    if (_game.isGameOver || !mounted) return;

    final currentFen = FenService.toFen(_game.position);
    await _engineManager.setPosition(currentFen);

    final engineMove = await _engineManager.searchMove(overrideBot: widget.bot);

    if (!mounted || _game.isGameOver) return;

    if (engineMove != null) {
      final movingPiece = _game.position.getPiece(engineMove.move.from);

      if (movingPiece != null && _boardKey.currentState != null) {
        _boardKey.currentState!.animateMove(engineMove.move, movingPiece, () {
          if (!mounted) return;

          _game.makeMove(engineMove.move);
          _playSoundForMove(engineMove.move);
          _updateActiveClockNotifier();

          setState(() {
            if (engineMove.dialogue != null) {
              _botDialogue = engineMove.dialogue;
            }
            if (_game.isGameOver) {
              _phase = GamePhase.gameOver;
            } else {
              _phase = GamePhase.playerTurn;
            }
          });

          if (_game.isGameOver) {
            _showGameOverDialog();
          }
        });
      } else {
        _game.makeMove(engineMove.move);
        _playSoundForMove(engineMove.move);
        _updateActiveClockNotifier();
        setState(() {
          _phase = _game.isGameOver ? GamePhase.gameOver : GamePhase.playerTurn;
        });
        if (_game.isGameOver) _showGameOverDialog();
      }
    } else {
      setState(() => _phase = GamePhase.playerTurn);
    }
  }

  void _playSoundForMove(Move move) {
    if (_game.inCheck) {
      _sound.playCheckSound();
    } else if (move.isCapture) {
      _sound.playCaptureSound();
    } else {
      _sound.playMoveSound();
    }
  }

  void _handleUndo() {
    if (_phase == GamePhase.animating || _phase == GamePhase.engineThinking) return;

    final undone = _game.undoTurn(vsAi: isVsAi);
    if (undone) {
      setState(() {
        _selectedSquare = null;
        _legalMovesForSelected = [];
        _botDialogue = null;
        if (isLocalPvp && widget.autoFlipPvp) {
          _perspectiveColor = _game.activeColor;
        }
        _phase = GamePhase.playerTurn;
      });
      _updateActiveClockNotifier();
      _sound.playMoveSound();
    }
  }

  void _handleRestart() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bắt đầu lại?'),
        content: const Text('Bạn có chắc muốn chơi lại ván cờ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final total = widget.timeControlMinutes * 60;
              _whiteTimeNotifier.value = total;
              _blackTimeNotifier.value = total;
              _updateActiveClockNotifier();

              setState(() {
                _game.reset();
                _selectedSquare = null;
                _legalMovesForSelected = [];
                _botDialogue = null;
                _perspectiveColor = widget.playerColor;

                if (isVsAi && widget.playerColor == PieceColor.black) {
                  _phase = GamePhase.engineThinking;
                } else {
                  _phase = GamePhase.playerTurn;
                }
              });

              if (isVsAi && widget.playerColor == PieceColor.black) {
                _triggerAiMove();
              }
            },
            child: const Text('CHƠI LẠI'),
          ),
        ],
      ),
    );
  }

  void _handleResign() {
    if (_game.isGameOver) return;
    final activeName = isVsAi
        ? 'Bạn'
        : (_game.activeColor == widget.playerColor ? 'Người chơi 1' : 'Người chơi 2');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đầu hàng?'),
        content: Text('$activeName có chắc muốn nhận thua ván đấu này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('TIẾP TỤC CHƠI'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _game.resign(_game.activeColor);
                _phase = GamePhase.gameOver;
              });
              _sound.playGameEndSound(isWin: false);
              _showGameOverDialog();
            },
            child: const Text('ĐẦU HÀNG'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmExitGame() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x33FFFFFF), width: 1),
        ),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
            border: Border.all(color: const Color(0xFFEF4444), width: 2),
          ),
          child: const Icon(Icons.exit_to_app, color: Color(0xFFEF4444), size: 30),
        ),
        title: const Text(
          'Thoát ván đấu?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF1F5F9),
          ),
        ),
        content: const Text(
          'Ván cờ hiện tại đang diễn ra và chưa kết thúc. Bạn có chắc chắn muốn rời khỏi ván đấu không?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF94A3B8),
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ở lại chơi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFF1F5F9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Thoát',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showMoveListModal() {
    final pgn = _generatePgn();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E212B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh Sách Nước Đi (PGN)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  pgn,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generatePgn() {
    final whiteName = isVsAi
        ? (widget.playerColor == PieceColor.white ? 'Player' : (widget.bot?.name ?? 'Stockfish'))
        : (widget.playerColor == PieceColor.white ? 'Player 1' : 'Player 2');
    final blackName = isVsAi
        ? (widget.playerColor == PieceColor.black ? 'Player' : (widget.bot?.name ?? 'Stockfish'))
        : (widget.playerColor == PieceColor.black ? 'Player 1' : 'Player 2');

    return PgnService.exportPgn(
      moves: _game.moveHistory,
      white: whiteName,
      black: blackName,
      result: _game.result,
    );
  }

  void _showGameOverDialog() {
    final result = _game.result;
    if (result == null) return;

    final pgn = _generatePgn();
    final isWin = result.winner == widget.playerColor;

    // Save offline record
    LocalStorage.saveGame(SavedGameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      botName: isVsAi ? (widget.bot?.name ?? 'Stockfish') : 'Local PvP',
      botElo: isVsAi ? (widget.bot?.displayedElo ?? '') : '2 Players',
      resultText: result.reason.displayNameVi,
      pgn: pgn,
      isWin: isWin,
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameResultDialog(
        result: result,
        playerColor: widget.playerColor,
        bot: widget.bot,
        gameMode: widget.gameMode,
        pgn: pgn,
        onPlayAgain: () {
          final total = widget.timeControlMinutes * 60;
          _whiteTimeNotifier.value = total;
          _blackTimeNotifier.value = total;
          _updateActiveClockNotifier();

          setState(() {
            _game.reset();
            _selectedSquare = null;
            _legalMovesForSelected = [];
            _botDialogue = null;
            _perspectiveColor = widget.playerColor;

            if (isVsAi && widget.playerColor == PieceColor.black) {
              _phase = GamePhase.engineThinking;
            } else {
              _phase = GamePhase.playerTurn;
            }
          });

          if (isVsAi && widget.playerColor == PieceColor.black) {
            _triggerAiMove();
          }
        },
        onChangeOpponent: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWhitePerspective = _perspectiveColor == PieceColor.white;
    final isUnlimited = widget.timeControlMinutes == 0;

    // Top player info
    final topColor = _perspectiveColor.opposite;
    final topCaptured = topColor == PieceColor.white ? _game.capturedByWhite : _game.capturedByBlack;
    final topClockTime = topColor == PieceColor.white ? _whiteTimeNotifier : _blackTimeNotifier;
    final topClockActive = topColor == PieceColor.white ? _whiteActiveNotifier : _blackActiveNotifier;

    // Bottom player info
    final bottomColor = _perspectiveColor;
    final bottomCaptured = bottomColor == PieceColor.white ? _game.capturedByWhite : _game.capturedByBlack;
    final bottomClockTime = bottomColor == PieceColor.white ? _whiteTimeNotifier : _blackTimeNotifier;
    final bottomClockActive = bottomColor == PieceColor.white ? _whiteActiveNotifier : _blackActiveNotifier;

    // Material advantages
    final scoreAdvantage = isWhitePerspective ? _game.materialScore : -_game.materialScore;
    final bottomAdvantage = scoreAdvantage > 0 ? scoreAdvantage : 0;
    final topAdvantage = scoreAdvantage < 0 ? -scoreAdvantage : 0;

    // Names
    final topTitle = isVsAi
        ? (widget.bot?.name ?? 'Stockfish')
        : (topColor == widget.playerColor ? 'Người chơi 1' : 'Người chơi 2');
    final bottomTitle = isVsAi
        ? 'Bạn'
        : (bottomColor == widget.playerColor ? 'Người chơi 1' : 'Người chơi 2');

    final isInputLocked = !_phase.canReceiveInput;

    return PopScope(
      canPop: _game.isGameOver,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldExit = await _confirmExitGame();
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF13151B),
        appBar: AppBar(
          title: Text(
            isVsAi
                ? '${widget.bot?.name ?? "Stockfish"} (${widget.bot?.displayedElo ?? ""})'
                : '2 Người Chơi (PvP)',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_game.isGameOver) {
                Navigator.of(context).pop();
                return;
              }
              final shouldExit = await _confirmExitGame();
              if (shouldExit && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: 'Xem PGN',
              onPressed: _showMoveListModal,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Section (Opponent / Player 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E212B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _game.activeColor == topColor
                              ? const Color(0xFFE5A93C)
                              : const Color(0x1AFFFFFF),
                        ),
                      ),
                      child: Center(
                        child: isVsAi
                            ? Text(
                                widget.bot?.avatarEmoji ?? '♟️',
                                style: const TextStyle(fontSize: 24, color: Color(0xFFE5A93C)),
                              )
                            : ChessPieceWidget(
                                piece: Piece(PieceType.king, topColor),
                                size: 28,
                                theme: _boardTheme,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                topTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF1F5F9),
                                ),
                              ),
                              if (isVsAi && _phase == GamePhase.engineThinking) ...[
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE5A93C),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (widget.bot?.isMittens ?? false)
                                      ? 'Mittens đang meow... 🐾'
                                      : 'Suy nghĩ...',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFFE5A93C)),
                                ),
                              ],
                            ],
                          ),
                          CapturedPiecesBar(
                            capturedPieces: topCaptured,
                            scoreAdvantage: topAdvantage,
                            theme: _boardTheme,
                          ),
                        ],
                      ),
                    ),
                    ChessClockWidget(
                      timeListenable: topClockTime,
                      activeListenable: topClockActive,
                      isUnlimited: isUnlimited,
                    ),
                  ],
                ),
              ),

              // Mittens dialogue speech bubble
              if (isVsAi && _botDialogue != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (widget.bot?.isMittens ?? false)
                          ? const Color(0xFF4A154B)
                          : const Color(0xFF282C37),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (widget.bot?.isMittens ?? false)
                            ? const Color(0xFFE91E63)
                            : const Color(0x33FFFFFF),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text((widget.bot?.isMittens ?? false) ? '😺 ' : '💬 '),
                        Expanded(
                          child: Text(
                            _botDialogue!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Chess Board (Layered, smooth animation, isolated background)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChessBoardWidget(
                    key: _boardKey,
                    game: _game,
                    theme: _boardTheme,
                    playerColor: _perspectiveColor,
                    selectedSquare: _selectedSquare,
                    legalMovesForSelected: _legalMovesForSelected,
                    showCoordinates: _showCoordinates,
                    showLegalMoves: _showLegalMoves,
                    isLocked: isInputLocked,
                    onSquareTapped: _onSquareTapped,
                    onMoveMade: _onMoveMade,
                  ),
                ),
              ),

              // Bottom Section (Active Player / Player 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E212B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _game.activeColor == bottomColor
                              ? const Color(0xFFE5A93C)
                              : const Color(0x1AFFFFFF),
                        ),
                      ),
                      child: Center(
                        child: ChessPieceWidget(
                          piece: Piece(PieceType.king, bottomColor),
                          size: 28,
                          theme: _boardTheme,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$bottomTitle (${bottomColor.displayName})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          CapturedPiecesBar(
                            capturedPieces: bottomCaptured,
                            scoreAdvantage: bottomAdvantage,
                            theme: _boardTheme,
                          ),
                        ],
                      ),
                    ),
                    ChessClockWidget(
                      timeListenable: bottomClockTime,
                      activeListenable: bottomClockActive,
                      isUnlimited: isUnlimited,
                    ),
                  ],
                ),
              ),

              // Action Toolbar (Undo, Restart, Resign)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E212B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _GameActionButton(
                      icon: Icons.undo,
                      label: 'Đi lại',
                      onTap: _game.moveHistory.isNotEmpty && !isInputLocked ? _handleUndo : null,
                    ),
                    _GameActionButton(
                      icon: Icons.refresh,
                      label: 'Chơi lại',
                      onTap: _handleRestart,
                    ),
                    _GameActionButton(
                      icon: Icons.flag_outlined,
                      label: 'Đầu hàng',
                      color: const Color(0xFFEF4444),
                      onTap: !_game.isGameOver ? _handleResign : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _GameActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final itemColor = color ?? (isEnabled ? const Color(0xFFF1F5F9) : const Color(0xFF64748B));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: itemColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: itemColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
