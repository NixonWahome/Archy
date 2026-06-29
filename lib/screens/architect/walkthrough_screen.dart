import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';

import '../../core/data/demo_data.dart';
import '../../core/models/project_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/session_service.dart';
import '../shared/chat_panel.dart';

/// Live collaborative walkthrough: everyone in the session sees the same 3D
/// model and the same finish selections in real time, with presence and chat.
class WalkthroughScreen extends StatefulWidget {
  final String projectId;
  final bool isDarkMode;

  const WalkthroughScreen({
    super.key,
    required this.projectId,
    required this.isDarkMode,
  });

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  String? _uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _join());
  }

  Future<void> _join() async {
    final auth = context.read<AuthService>();
    final session = context.read<SessionService>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    _uid = uid;
    final user = await auth.getUserData(uid);
    await session.join(
      widget.projectId,
      uid: uid,
      name: user?.name ?? auth.currentUser?.email ?? 'Guest',
      role: user?.role ?? 'guest',
    );
  }

  @override
  void dispose() {
    // Best-effort leave (fire and forget; context may be gone).
    final uid = _uid;
    if (uid != null) {
      SessionService().leave(widget.projectId, uid);
    }
    super.dispose();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ChatPanel(
          projectId: widget.projectId,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();
    final session = context.read<SessionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Walkthrough'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _openChat,
            tooltip: 'Chat',
          ),
        ],
      ),
      body: StreamBuilder<SessionState>(
        stream: session.sessionStream(widget.projectId),
        builder: (context, sessionSnap) {
          final state = sessionSnap.data ?? SessionState();
          final isHost = state.hostUid == _uid;

          return StreamBuilder<ProjectModel?>(
            stream: db.projectStream(widget.projectId),
            builder: (context, projectSnap) {
              final modelUrl = projectSnap.data?.model3dUrl;
              return Column(
                children: [
                  // Presence bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withValues(alpha: 0.05),
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.participants.isEmpty
                                ? 'Connecting…'
                                : '${state.participants.length} in session: '
                                    '${state.participants.map((p) => p.name).join(', ')}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isHost)
                          const Chip(
                            label: Text('Host'),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  // Shared 3D model
                  Expanded(
                    child: ModelViewer(
                      src: modelUrl != null && modelUrl.isNotEmpty
                          ? modelUrl
                          : 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                      ar: true,
                      autoRotate: false,
                      cameraControls: true,
                    ),
                  ),
                  // Synced finish selectors (host drives; everyone sees live)
                  _FinishBar(
                    isHost: isHost,
                    state: state,
                    onFloor: (v) =>
                        session.updateFinishes(widget.projectId, floor: v),
                    onWall: (v) =>
                        session.updateFinishes(widget.projectId, wall: v),
                    onRoof: (v) =>
                        session.updateFinishes(widget.projectId, roof: v),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FinishBar extends StatelessWidget {
  final bool isHost;
  final SessionState state;
  final ValueChanged<String> onFloor;
  final ValueChanged<String> onWall;
  final ValueChanged<String> onRoof;

  const _FinishBar({
    required this.isHost,
    required this.state,
    required this.onFloor,
    required this.onWall,
    required this.onRoof,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isHost)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'The host is driving the selections',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ),
          _row('Floor', DemoData.floorOptions.keys.toList(), state.selectedFloor,
              isHost ? onFloor : null),
          _row('Wall', DemoData.wallOptions.keys.toList(), state.selectedWall,
              isHost ? onWall : null),
          _row('Roof', DemoData.roofOptions.keys.toList(), state.selectedRoof,
              isHost ? onRoof : null),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    List<String> options,
    String selected,
    ValueChanged<String>? onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(label)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final o in options)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(o),
                        selected: selected == o,
                        onSelected:
                            onSelect == null ? null : (_) => onSelect(o),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
