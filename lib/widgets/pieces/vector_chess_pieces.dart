import 'package:flutter/material.dart';
import '../../chess/models/piece.dart';
import '../../chess/models/piece_color.dart';
import '../../chess/models/piece_type.dart';
import '../../core/theme/board_themes.dart';

/// Renders a unified, geometrically balanced Staunton vector chess piece.
/// Dynamically styled according to the selected BoardThemeData.
class VectorChessPieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;
  final BoardThemeData? theme;

  const VectorChessPieceWidget({
    super.key,
    required this.piece,
    this.size = 45.0,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StauntonPiecePainter(
          type: piece.type,
          color: piece.color,
          theme: theme,
        ),
      ),
    );
  }
}

class _StauntonPiecePainter extends CustomPainter {
  final PieceType type;
  final PieceColor color;
  final BoardThemeData? theme;

  _StauntonPiecePainter({
    required this.type,
    required this.color,
    this.theme,
  });

  bool get isWhite => color == PieceColor.white;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Use theme-specific colors
    final t = theme ?? BoardThemeData.wood;
    final fillColor = isWhite ? t.whitePieceFill : t.blackPieceFill;
    final strokeColor = isWhite ? t.whitePieceStroke : t.blackPieceStroke;
    final accentDetailColor = isWhite ? t.whitePieceDetail : t.blackPieceDetail;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final detailPaint = Paint()
      ..color = accentDetailColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    // Draw subtle uniform drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x3D000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.save();
    canvas.translate(0, h * 0.02);

    switch (type) {
      case PieceType.pawn:
        _drawPawn(canvas, w, h, shadowPaint, fillPaint, strokePaint);
        break;
      case PieceType.knight:
        _drawKnight(canvas, w, h, shadowPaint, fillPaint, strokePaint, detailPaint);
        break;
      case PieceType.bishop:
        _drawBishop(canvas, w, h, shadowPaint, fillPaint, strokePaint, detailPaint);
        break;
      case PieceType.rook:
        _drawRook(canvas, w, h, shadowPaint, fillPaint, strokePaint, detailPaint);
        break;
      case PieceType.queen:
        _drawQueen(canvas, w, h, shadowPaint, fillPaint, strokePaint, detailPaint);
        break;
      case PieceType.king:
        _drawKing(canvas, w, h, shadowPaint, fillPaint, strokePaint, detailPaint);
        break;
    }

    canvas.restore();
  }

  void _drawBase(Canvas canvas, double w, double h, Paint fill, Paint stroke) {
    final basePath = Path()
      ..moveTo(w * 0.22, h * 0.88)
      ..lineTo(w * 0.78, h * 0.88)
      ..quadraticBezierTo(w * 0.82, h * 0.92, w * 0.80, h * 0.94)
      ..lineTo(w * 0.20, h * 0.94)
      ..quadraticBezierTo(w * 0.18, h * 0.92, w * 0.22, h * 0.88)
      ..close();
    canvas.drawPath(basePath, fill);
    canvas.drawPath(basePath, stroke);
  }

  void _drawPawn(Canvas canvas, double w, double h, Paint shadow, Paint fill, Paint stroke) {
    final path = Path();
    // Head sphere
    path.addOval(Rect.fromCircle(center: Offset(w * 0.50, h * 0.32), radius: w * 0.17));

    // Body
    path.moveTo(w * 0.38, h * 0.46);
    path.quadraticBezierTo(w * 0.36, h * 0.65, w * 0.28, h * 0.86);
    path.lineTo(w * 0.72, h * 0.86);
    path.quadraticBezierTo(w * 0.64, h * 0.65, w * 0.62, h * 0.46);
    path.close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    _drawBase(canvas, w, h, fill, stroke);
  }

  void _drawKnight(Canvas canvas, double w, double h, Paint shadow, Paint fill, Paint stroke, Paint detail) {
    final path = Path()
      // Base attachment
      ..moveTo(w * 0.26, h * 0.86)
      // Chest
      ..quadraticBezierTo(w * 0.22, h * 0.65, w * 0.30, h * 0.52)
      // Muzzle / mouth
      ..lineTo(w * 0.20, h * 0.45)
      ..lineTo(w * 0.26, h * 0.38)
      ..lineTo(w * 0.35, h * 0.40)
      // Forehead
      ..lineTo(w * 0.38, h * 0.28)
      // Ear
      ..lineTo(w * 0.44, h * 0.15)
      ..lineTo(w * 0.50, h * 0.25)
      // Mane back
      ..quadraticBezierTo(w * 0.74, h * 0.35, w * 0.72, h * 0.86)
      ..close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Eye detail
    canvas.drawCircle(Offset(w * 0.38, h * 0.35), w * 0.028, detail);
    // Mane line
    final mane = Path()
      ..moveTo(w * 0.55, h * 0.32)
      ..quadraticBezierTo(w * 0.65, h * 0.48, w * 0.64, h * 0.70);
    canvas.drawPath(mane, detail);

    _drawBase(canvas, w, h, fill, stroke);
  }

  void _drawBishop(Canvas canvas, double w, double h, Paint shadow, Paint fill, Paint stroke, Paint detail) {
    final path = Path();
    // Top finial ball
    path.addOval(Rect.fromCircle(center: Offset(w * 0.50, h * 0.14), radius: w * 0.04));

    // Mitre head
    path.moveTo(w * 0.50, h * 0.18);
    path.quadraticBezierTo(w * 0.72, h * 0.32, w * 0.64, h * 0.52);
    path.quadraticBezierTo(w * 0.62, h * 0.72, w * 0.70, h * 0.86);
    path.lineTo(w * 0.30, h * 0.86);
    path.quadraticBezierTo(w * 0.38, h * 0.72, w * 0.36, h * 0.52);
    path.quadraticBezierTo(w * 0.28, h * 0.32, w * 0.50, h * 0.18);
    path.close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Mitre diagonal cut slit
    canvas.drawLine(Offset(w * 0.54, h * 0.28), Offset(w * 0.42, h * 0.42), detail);
    // Collar ring
    canvas.drawLine(Offset(w * 0.35, h * 0.56), Offset(w * 0.65, h * 0.56), detail);

    _drawBase(canvas, w, h, fill, stroke);
  }

  void _drawRook(Canvas canvas, double w, double h, Paint shadow, Paint fill, Paint stroke, Paint detail) {
    final path = Path()
      // Left crenellation
      ..moveTo(w * 0.28, h * 0.22)
      ..lineTo(w * 0.38, h * 0.22)
      ..lineTo(w * 0.38, h * 0.28)
      // Center gap
      ..lineTo(w * 0.44, h * 0.28)
      ..lineTo(w * 0.44, h * 0.22)
      ..lineTo(w * 0.56, h * 0.22)
      ..lineTo(w * 0.56, h * 0.28)
      // Right crenellation
      ..lineTo(w * 0.62, h * 0.28)
      ..lineTo(w * 0.62, h * 0.22)
      ..lineTo(w * 0.72, h * 0.22)
      // Right tower body
      ..lineTo(w * 0.70, h * 0.36)
      ..quadraticBezierTo(w * 0.66, h * 0.60, w * 0.70, h * 0.86)
      ..lineTo(w * 0.30, h * 0.86)
      ..quadraticBezierTo(w * 0.34, h * 0.60, w * 0.30, h * 0.36)
      ..close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Tower rim line
    canvas.drawLine(Offset(w * 0.30, h * 0.36), Offset(w * 0.70, h * 0.36), detail);

    _drawBase(canvas, w, h, fill, stroke);
  }

  void _drawQueen(Canvas canvas, double w, double h, Paint shadow, Paint fill, Paint stroke, Paint detail) {
    // 3 Coronet balls
    canvas.drawCircle(Offset(w * 0.28, h * 0.22), w * 0.038, fill);
    canvas.drawCircle(Offset(w * 0.28, h * 0.22), w * 0.038, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.16), w * 0.042, fill);
    canvas.drawCircle(Offset(w * 0.50, h * 0.16), w * 0.042, stroke);
    canvas.drawCircle(Offset(w * 0.72, h * 0.22), w * 0.038, fill);
    canvas.drawCircle(Offset(w * 0.72, h * 0.22), w * 0.038, stroke);

    final path = Path()
      // Coronet tips
      ..moveTo(w * 0.28, h * 0.25)
      ..lineTo(w * 0.38, h * 0.38)
      ..lineTo(w * 0.50, h * 0.20)
      ..lineTo(w * 0.62, h * 0.38)
      ..lineTo(w * 0.72, h * 0.25)
      // Body
      ..quadraticBezierTo(w * 0.64, h * 0.60, w * 0.72, h * 0.86)
      ..lineTo(w * 0.28, h * 0.86)
      ..quadraticBezierTo(w * 0.36, h * 0.60, w * 0.28, h * 0.25)
      ..close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Waist band
    canvas.drawLine(Offset(w * 0.34, h * 0.58), Offset(w * 0.66, h * 0.58), detail);

    _drawBase(canvas, w, h, fill, stroke);
  }

  void _drawKing(Canvas canvas, double w, double h, Paint shadow, Paint fill, Paint stroke, Paint detail) {
    // Cross on top
    canvas.drawLine(Offset(w * 0.50, h * 0.08), Offset(w * 0.50, h * 0.22), stroke);
    canvas.drawLine(Offset(w * 0.42, h * 0.13), Offset(w * 0.58, h * 0.13), stroke);

    final path = Path()
      // Dome
      ..moveTo(w * 0.50, h * 0.22)
      ..quadraticBezierTo(w * 0.74, h * 0.30, w * 0.68, h * 0.50)
      ..quadraticBezierTo(w * 0.64, h * 0.68, w * 0.72, h * 0.86)
      ..lineTo(w * 0.28, h * 0.86)
      ..quadraticBezierTo(w * 0.36, h * 0.68, w * 0.32, h * 0.50)
      ..quadraticBezierTo(w * 0.26, h * 0.30, w * 0.50, h * 0.22)
      ..close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Cross detail and collar
    canvas.drawLine(Offset(w * 0.32, h * 0.50), Offset(w * 0.68, h * 0.50), detail);

    _drawBase(canvas, w, h, fill, stroke);
  }

  @override
  bool shouldRepaint(covariant _StauntonPiecePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.theme?.id != theme?.id;
  }
}
