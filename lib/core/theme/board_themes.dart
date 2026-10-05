import 'package:flutter/material.dart';

class BoardThemeData {
  final String id;
  final String name;
  final Color lightSquare;
  final Color darkSquare;
  final Color selectedSquare;
  final Color lastMoveLight;
  final Color lastMoveDark;
  final Color legalMoveDot;
  final Color checkGlow;

  // Themed Piece Colors
  final Color whitePieceFill;
  final Color whitePieceStroke;
  final Color whitePieceDetail;
  final Color blackPieceFill;
  final Color blackPieceStroke;
  final Color blackPieceDetail;

  const BoardThemeData({
    required this.id,
    required this.name,
    required this.lightSquare,
    required this.darkSquare,
    required this.selectedSquare,
    required this.lastMoveLight,
    required this.lastMoveDark,
    required this.legalMoveDot,
    required this.checkGlow,
    required this.whitePieceFill,
    required this.whitePieceStroke,
    required this.whitePieceDetail,
    required this.blackPieceFill,
    required this.blackPieceStroke,
    required this.blackPieceDetail,
  });

  static const wood = BoardThemeData(
    id: 'wood',
    name: 'Gỗ cổ điển',
    lightSquare: Color(0xFFF0D9B5),
    darkSquare: Color(0xFFB58863),
    selectedSquare: Color(0x80F6E05E),
    lastMoveLight: Color(0xFFCED26B),
    lastMoveDark: Color(0xFFAAA23A),
    legalMoveDot: Color(0x66000000),
    checkGlow: Color(0xCCEF4444),
    // Warm Wood Carved Pieces
    whitePieceFill: Color(0xFFFFFBEB),
    whitePieceStroke: Color(0xFF5C3826),
    whitePieceDetail: Color(0xFF8B5A36),
    blackPieceFill: Color(0xFF382216),
    blackPieceStroke: Color(0xFFB58863),
    blackPieceDetail: Color(0xFFD4A373),
  );

  static const tournament = BoardThemeData(
    id: 'tournament',
    name: 'Xanh thi đấu (Lichess)',
    lightSquare: Color(0xFFEEEED2),
    darkSquare: Color(0xFF769656),
    selectedSquare: Color(0x80BBDEFB),
    lastMoveLight: Color(0xFFF7F782),
    lastMoveDark: Color(0xFFBACA44),
    legalMoveDot: Color(0x55000000),
    checkGlow: Color(0xCCE11D48),
    // Tournament Standard Staunton
    whitePieceFill: Color(0xFFFFFFFE),
    whitePieceStroke: Color(0xFF1E293B),
    whitePieceDetail: Color(0xFF475569),
    blackPieceFill: Color(0xFF1E222A),
    blackPieceStroke: Color(0xFF94A3B8),
    blackPieceDetail: Color(0xFFE2E8F0),
  );

  static const cyberpunk = BoardThemeData(
    id: 'cyberpunk',
    name: 'Cyberpunk Neon',
    lightSquare: Color(0xFF2E3440),
    darkSquare: Color(0xFF1E222A),
    selectedSquare: Color(0x8000ADB5),
    lastMoveLight: Color(0xFF3B4252),
    lastMoveDark: Color(0xFF282C34),
    legalMoveDot: Color(0x8800ADB5),
    checkGlow: Color(0xCCFF007F),
    // Electric Cyberpunk Neon Pieces
    whitePieceFill: Color(0xFF00F0FF),
    whitePieceStroke: Color(0xFF003844),
    whitePieceDetail: Color(0xFFE0FFFF),
    blackPieceFill: Color(0xFF1B0B2E),
    blackPieceStroke: Color(0xFFFF007F),
    blackPieceDetail: Color(0xFFF472B6),
  );

  static const midnight = BoardThemeData(
    id: 'midnight',
    name: 'Midnight Navy',
    lightSquare: Color(0xFFD6E4E5),
    darkSquare: Color(0xFF497174),
    selectedSquare: Color(0x80EB6440),
    lastMoveLight: Color(0xFFE2EBEB),
    lastMoveDark: Color(0xFF3E6063),
    legalMoveDot: Color(0x552B3A55),
    checkGlow: Color(0xCCEA580C),
    // Arctic Frosted Midnight Pieces
    whitePieceFill: Color(0xFFE0F2FE),
    whitePieceStroke: Color(0xFF0369A1),
    whitePieceDetail: Color(0xFF38BDF8),
    blackPieceFill: Color(0xFF0F172A),
    blackPieceStroke: Color(0xFF7DD3FC),
    blackPieceDetail: Color(0xFFBAE6FD),
  );

  static const List<BoardThemeData> allThemes = [
    wood,
    tournament,
    cyberpunk,
    midnight,
  ];

  static BoardThemeData getById(String id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => wood,
    );
  }
}
