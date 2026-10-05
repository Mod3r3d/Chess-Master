import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../bot_selection/bot_selection_screen.dart';
import '../engine_selection/engine_selection_screen.dart';
import '../history/history_screen.dart';
import '../local_pvp_setup/local_pvp_setup_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13151B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Hero Brand Emblem
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3BA2F), Color(0xFFE5A93C), Color(0xFF8A5A00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE5A93C).withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '♔',
                    style: TextStyle(
                      fontSize: 60,
                      color: Color(0xFF13151B),
                      height: 1.05,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // App Title & Tagline
              const Text(
                'CHESS MASTER',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'OFFLINE-FIRST • 100% MIỄN PHÍ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Mode 1: VS COMPUTER (Chơi với AI)
              _HomeMenuButton(
                icon: Icons.smart_toy_rounded,
                title: 'VS COMPUTER',
                subtitle: 'Đấu với Stockfish (600 - 1800+ Elo)',
                isPrimary: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const BotSelectionScreen(engineId: 'stockfish'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Mode 2: LOCAL PVP (2 người / 1 máy)
              _HomeMenuButton(
                icon: Icons.people_alt_rounded,
                title: 'LOCAL 2 PLAYERS',
                subtitle: 'Hai người chơi thi đấu trên cùng thiết bị',
                isPrimary: false,
                accentColor: const Color(0xFF38BDF8),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const LocalPvpSetupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Quick Actions Row 1: Mittens & Engine selection
              Row(
                children: [
                  Expanded(
                    child: _SmallMenuButton(
                      icon: Icons.pets_rounded,
                      title: 'MITTENS',
                      accentColor: const Color(0xFFE91E63),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const BotSelectionScreen(engineId: 'mittens'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SmallMenuButton(
                      icon: Icons.memory_rounded,
                      title: 'ĐỘNG CƠ',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const EngineSelectionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quick Actions Row 2: History & Settings
              Row(
                children: [
                  Expanded(
                    child: _SmallMenuButton(
                      icon: Icons.history_rounded,
                      title: 'LỊCH SỬ',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SmallMenuButton(
                      icon: Icons.settings_rounded,
                      title: 'CÀI ĐẶT',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Footer version
              const Text(
                '${AppConstants.appName} v2.0 • Offline Edition',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final Color? accentColor;
  final VoidCallback onTap;

  const _HomeMenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isPrimary = false,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? const Color(0xFFE5A93C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? effectiveAccent : const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrimary ? effectiveAccent : const Color(0x26FFFFFF),
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: effectiveAccent.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary ? const Color(0x33000000) : const Color(0xFF13151B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.black : effectiveAccent,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: isPrimary ? Colors.black : const Color(0xFFF1F5F9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPrimary ? const Color(0xCC000000) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isPrimary ? Colors.black : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? accentColor;
  final VoidCallback onTap;

  const _SmallMenuButton({
    required this.icon,
    required this.title,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x26FFFFFF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: effectiveColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: accentColor ?? const Color(0xFFF1F5F9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
