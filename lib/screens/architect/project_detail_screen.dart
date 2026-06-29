import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neomorphic_widgets.dart';
import '../../core/services/database_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/project_model.dart';
import '../../core/models/message_model.dart';
import 'walkthrough_screen.dart';
import 'budget_simulator_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  final bool isDarkMode;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.isDarkMode,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isUploading = false;
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();

  Future<void> _uploadARModel() async {
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb', 'gltf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final dbService = Provider.of<DatabaseService>(context, listen: false);
        await dbService.uploadARModel(widget.projectId, file);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('3D model uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, DatabaseService>(
      builder: (context, authService, dbService, child) {
        return Scaffold(
          backgroundColor:
              widget.isDarkMode
                  ? AppTheme.darkBackground
                  : AppTheme.lightBackground,
          appBar: AppBar(
            backgroundColor:
                widget.isDarkMode
                    ? AppTheme.darkSurface
                    : AppTheme.lightSurface,
            title: StreamBuilder<ProjectModel?>(
              stream: dbService.projectStream(widget.projectId),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data?.title ?? 'Project Detail',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                );
              },
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor:
                  widget.isDarkMode ? Colors.white38 : Colors.black38,
              indicatorColor: AppTheme.primaryBlue,
              tabs: const [
                Tab(icon: Icon(Icons.threed_rotation), text: '3D'),
                Tab(icon: Icon(Icons.attach_money), text: 'Budget'),
                Tab(icon: Icon(Icons.comment), text: 'Comments'),
                Tab(icon: Icon(Icons.publish), text: 'Publish'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _build3DTab(),
              _buildBudgetTab(),
              _buildCommentsTab(),
              _buildPublishTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live 3D model preview (shown once a model has been uploaded).
          StreamBuilder<ProjectModel?>(
            stream: Provider.of<DatabaseService>(
              context,
              listen: false,
            ).projectStream(widget.projectId),
            builder: (context, snap) {
              final url = snap.data?.model3dUrl;
              if (url == null || url.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 280,
                    child: ModelViewer(
                      src: url,
                      ar: true,
                      autoRotate: true,
                      cameraControls: true,
                    ),
                  ),
                ),
              );
            },
          ),
          // 3D Walkthrough Card
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => WalkthroughScreen(
                        projectId: widget.projectId,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
            child: NeomorphicContainer(
              isDarkMode: widget.isDarkMode,
              height: 250,
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.3),
                          AppTheme.primaryBlue.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.threed_rotation,
                          size: 80,
                          color: AppTheme.primaryBlue.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text('Start 3D Walkthrough'),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          NeomorphicButton(
            isDarkMode: widget.isDarkMode,
            onPressed: _isUploading ? null : _uploadARModel,
            child:
                _isUploading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_upload),
                        SizedBox(width: 8),
                        Text('Upload 3D Model'),
                      ],
                    ),
          ),
          const SizedBox(height: 16),
          Text(
            'Live Project Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<ProjectModel?>(
            stream: Provider.of<DatabaseService>(
              context,
            ).projectStream(widget.projectId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final project = snapshot.data!;
              final completed =
                  project.milestones
                      .where((m) => m.status == 'approved')
                      .length;
              final progress =
                  project.milestones.isNotEmpty
                      ? (completed / project.milestones.length) * 100
                      : 0.0;
              return NeomorphicContainer(
                isDarkMode: widget.isDarkMode,
                child: Column(
                  children: [
                    _DetailRow(
                      isDarkMode: widget.isDarkMode,
                      label: 'Total Budget',
                      value:
                          'KES ${(project.budget / 1000000).toStringAsFixed(1)}M',
                    ),
                    _DetailRow(
                      isDarkMode: widget.isDarkMode,
                      label: 'Milestones',
                      value: '${completed}/${project.milestones.length}',
                    ),
                    _DetailRow(
                      isDarkMode: widget.isDarkMode,
                      label: 'Progress',
                      value: '${progress.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab() {
    return BudgetSimulatorScreen(
      projectId: widget.projectId,
      isDarkMode: widget.isDarkMode,
    );
  }

  Widget _buildCommentsTab() {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
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
              final myUid = auth.currentUser?.uid;
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
                            ? AppTheme.primaryBlue
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
                            style: TextStyle(
                              color: mine ? Colors.white : null,
                            ),
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
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendChat(db, auth),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendChat(DatabaseService db, AuthService auth) async {
    final text = _chatController.text.trim();
    final uid = auth.currentUser?.uid;
    if (text.isEmpty || uid == null) return;
    _chatController.clear();
    final user = await auth.getUserData(uid);
    await db.sendMessage(
      widget.projectId,
      text,
      uid,
      user?.name ?? auth.currentUser?.email ?? 'User',
    );
  }

  Widget _buildPublishTab() {
    final db = Provider.of<DatabaseService>(context, listen: false);
    return StreamBuilder<ProjectModel?>(
      stream: db.projectStream(widget.projectId),
      builder: (context, snapshot) {
        final project = snapshot.data;
        if (project == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              project.diasporaName == null
                  ? 'No client assigned yet'
                  : 'Assigned to ${project.diasporaName}',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Assign client by email'),
              onPressed: () => _assignClientDialog(db),
            ),
            const Divider(height: 32),
            const Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in const [
                  'planning',
                  'in_progress',
                  'on_hold',
                  'completed',
                ])
                  ChoiceChip(
                    label: Text(s.replaceAll('_', ' ')),
                    selected: project.status == s,
                    onSelected: (_) => db.updateProjectStatus(project.id, s),
                  ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Milestones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: () => _addMilestoneDialog(db, project),
                ),
              ],
            ),
            if (project.milestones.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No milestones yet'),
              ),
            ...project.milestones.map(
              (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(m.title),
                subtitle: Text('KES ${m.amount.toStringAsFixed(0)} • ${m.status}'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignClientDialog(DatabaseService db) async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign client'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Client email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty) return;
    final user = await db.findUserByEmail(email);
    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No account found with that email')),
      );
      return;
    }
    await db.assignClientToProject(widget.projectId, user.id, user.name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigned ${user.name} to this project')),
    );
  }

  Future<void> _addMilestoneDialog(
    DatabaseService db,
    ProjectModel project,
  ) async {
    final titleC = TextEditingController();
    final amountC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add milestone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (KES)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final title = titleC.text.trim();
    if (title.isEmpty) return;
    final milestone = MilestoneModel(
      id: db.newDocId(),
      title: title,
      description: '',
      amount: double.tryParse(amountC.text.trim()) ?? 0,
      status: 'pending',
      order: project.milestones.length,
    );
    await db.addMilestone(widget.projectId, milestone);
  }
}

class _DetailRow extends StatelessWidget {
  final bool isDarkMode;
  final String label;
  final String value;

  const _DetailRow({
    required this.isDarkMode,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : Colors.black45,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
