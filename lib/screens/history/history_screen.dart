import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../storage/local_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SavedGameRecord> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await LocalStorage.getGameHistory();
    if (mounted) {
      setState(() {
        _games = list;
        _isLoading = false;
      });
    }
  }

  void _showPgnModal(SavedGameRecord record) {
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
            Row(
              children: [
                Text(
                  'Chi Tiết Ván Đấu (${record.botName})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20, color: Color(0xFFE5A93C)),
                  tooltip: 'Sao chép PGN',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: record.pgn));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép PGN!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  record.pgn,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13151B),
      appBar: AppBar(
        title: const Text('Lịch Sử Ván Đấu'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE5A93C)))
            : _games.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history_toggle_off, size: 64, color: Color(0xFF64748B)),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có ván đấu nào được lưu',
                          style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Hãy chơi một ván với AI để xem lại tại đây!',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _games.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final g = _games[i];
                      final dateStr =
                          '${g.date.day.toString().padLeft(2, '0')}/${g.date.month.toString().padLeft(2, '0')}/${g.date.year} ${g.date.hour.toString().padLeft(2, '0')}:${g.date.minute.toString().padLeft(2, '0')}';

                      final badgeColor = g.isWin
                          ? const Color(0xFF10B981)
                          : (g.resultText.contains('Hòa')
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFFEF4444));

                      return InkWell(
                        onTap: () => _showPgnModal(g),
                        borderRadius: BorderRadius.circular(14),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: badgeColor),
                                  ),
                                  child: Icon(
                                    g.isWin
                                        ? Icons.emoji_events
                                        : (g.resultText.contains('Hòa')
                                            ? Icons.handshake
                                            : Icons.close),
                                    color: badgeColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'vs ${g.botName} (${g.botElo})',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF1F5F9),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${g.resultText} • $dateStr',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
