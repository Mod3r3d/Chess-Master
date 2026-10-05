import 'package:flutter/material.dart';
import '../engines/engine_profile.dart';

class EngineCard extends StatelessWidget {
  final EngineProfile engine;
  final bool isSelected;
  final VoidCallback onSelect;

  const EngineCard({
    super.key,
    required this.engine,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFFE5A93C) : const Color(0x1AFFFFFF),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF13151B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      engine.iconEmoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        engine.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      Text(
                        engine.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1AE5A93C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    engine.version,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFE5A93C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              engine.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? const Color(0xFFE5A93C) : const Color(0xFF282C37),
                  foregroundColor: isSelected ? Colors.black : const Color(0xFFF1F5F9),
                ),
                child: Text(isSelected ? 'Đang chọn ✓' : 'Chọn Engine này'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
