import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChessClockWidget extends StatelessWidget {
  final ValueListenable<int>? timeListenable;
  final ValueListenable<bool>? activeListenable;
  final int remainingSeconds;
  final bool isActive;
  final bool isUnlimited;
  final String label;

  const ChessClockWidget({
    super.key,
    this.timeListenable,
    this.activeListenable,
    this.remainingSeconds = 300,
    this.isActive = false,
    this.isUnlimited = false,
    this.label = '',
  });

  String _formatTime(int sec) {
    if (isUnlimited) return '∞';
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (timeListenable != null && activeListenable != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: activeListenable!,
        builder: (context, active, _) {
          return ValueListenableBuilder<int>(
            valueListenable: timeListenable!,
            builder: (context, sec, _) {
              return _buildClockBox(sec, active);
            },
          );
        },
      );
    }

    if (timeListenable != null) {
      return ValueListenableBuilder<int>(
        valueListenable: timeListenable!,
        builder: (context, sec, _) {
          return _buildClockBox(sec, isActive);
        },
      );
    }

    return _buildClockBox(remainingSeconds, isActive);
  }

  Widget _buildClockBox(int sec, bool active) {
    final isLowTime = !isUnlimited && sec <= 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF282C37) : const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? (isLowTime ? const Color(0xFFEF4444) : const Color(0xFFE5A93C))
              : const Color(0x1AFFFFFF),
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: isLowTime
                      ? const Color(0x33EF4444)
                      : const Color(0x33E5A93C),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: active
                ? (isLowTime ? const Color(0xFFEF4444) : const Color(0xFFE5A93C))
                : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(sec),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: isLowTime
                  ? const Color(0xFFEF4444)
                  : (active ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8)),
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }
}
