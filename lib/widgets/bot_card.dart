import 'package:flutter/material.dart';
import '../bots/bot_profile.dart';

class BotCard extends StatelessWidget {
  final BotProfile bot;
  final bool isSelected;
  final VoidCallback onTap;

  const BotCard({
    super.key,
    required this.bot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final diffColor = Color(bot.difficulty.colorHex);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF282C37) : const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5A93C) : const Color(0x1AFFFFFF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x33E5A93C),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: bot.isMittens ? const Color(0xFF4A154B) : const Color(0xFF13151B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: bot.isMittens ? const Color(0xFFE91E63) : const Color(0x26FFFFFF),
                ),
              ),
              child: Center(
                child: Text(
                  bot.avatarEmoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bot.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: diffColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          bot.difficulty.nameVi,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: diffColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: Text(
                          'CPU: ${bot.cpuUsage}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bot.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bot.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Elo display badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF13151B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x33E5A93C)),
              ),
              child: Column(
                children: [
                  Text(
                    bot.displayedElo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE5A93C),
                    ),
                  ),
                  const Text(
                    'Elo ước tính',
                    style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
