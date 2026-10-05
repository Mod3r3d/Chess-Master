import 'package:flutter/material.dart';
import '../../engines/engine_profile.dart';
import '../../storage/local_storage.dart';
import '../../widgets/engine_card.dart';
import '../bot_selection/bot_selection_screen.dart';

class EngineSelectionScreen extends StatefulWidget {
  const EngineSelectionScreen({super.key});

  @override
  State<EngineSelectionScreen> createState() => _EngineSelectionScreenState();
}

class _EngineSelectionScreenState extends State<EngineSelectionScreen> {
  String _selectedEngineId = 'stockfish';

  @override
  void initState() {
    super.initState();
    _loadSelectedEngine();
  }

  Future<void> _loadSelectedEngine() async {
    final engineId = await LocalStorage.getSelectedEngineId();
    if (mounted) {
      setState(() {
        _selectedEngineId = engineId;
      });
    }
  }

  void _onChooseEngine(EngineProfile engine) {
    setState(() {
      _selectedEngineId = engine.id;
    });
    LocalStorage.setSelectedEngineId(engine.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BotSelectionScreen(engineId: engine.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13151B),
      appBar: AppBar(
        title: const Text('Chọn Động Cơ (Engine)'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'CHỌN ĐỐI THỦ CHESS ENGINE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            ...EngineProfile.availableEngines.map((engine) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EngineCard(
                  engine: engine,
                  isSelected: _selectedEngineId == engine.id,
                  onSelect: () => _onChooseEngine(engine),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
