import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/message_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';

/// Reusable live chat panel for a project thread. Used by both the architect
/// project detail and the diaspora messages tab so the chat stays in sync.
class ChatPanel extends StatefulWidget {
  final String projectId;
  final bool isDarkMode;

  const ChatPanel({
    super.key,
    required this.projectId,
    required this.isDarkMode,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(DatabaseService db, AuthService auth) async {
    final text = _controller.text.trim();
    final uid = auth.currentUser?.uid;
    if (text.isEmpty || uid == null) return;
    _controller.clear();
    final user = await auth.getUserData(uid);
    await db.sendMessage(
      widget.projectId,
      text,
      uid,
      user?.name ?? auth.currentUser?.email ?? 'User',
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final myUid = auth.currentUser?.uid;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Message>>(
            stream: db.chatStream(widget.projectId),
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) {
                return const Center(child: Text('No messages yet. Say hello!'));
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final mine = m.senderId == myUid;
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: mine
                            ? Colors.blue
                            : (widget.isDarkMode
                                ? Colors.white10
                                : Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.senderName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: mine ? Colors.white70 : null,
                            ),
                          ),
                          Text(
                            m.text,
                            style: TextStyle(color: mine ? Colors.white : null),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _send(db, auth),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
