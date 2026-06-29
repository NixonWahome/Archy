import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/design/archy_scaffold.dart';
import '../../core/design/archy_context.dart';
import '../../core/design/archy_theme.dart';
import '../../core/design/archy_tokens.dart';
import '../../core/design/archy_widgets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/session_service.dart';
import '../../core/models/project_model.dart';
import '../../core/models/user_model.dart';
import 'project_detail_screen.dart';
import 'project_form_screen.dart';
import 'walkthrough_screen.dart';

class ArchitectDashboard extends StatefulWidget {
  final bool isDarkMode;

  const ArchitectDashboard({super.key, required this.isDarkMode});

  @override
  State<ArchitectDashboard> createState() => _ArchitectDashboardState();
}

class _ArchitectDashboardState extends State<ArchitectDashboard> {
  int _currentIndex = 0;
  String? userId;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, DatabaseService>(
      builder: (context, authService, dbService, child) {
        userId = authService.currentUser?.uid;
        if (userId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ArchyDashboardScaffold(
          title: 'Studio',
          subtitle: 'Architect',
          index: _currentIndex,
          onTabChanged: (i) => setState(() => _currentIndex = i),
          tabs: const [
            ArchyTab(Icons.grid_view_rounded, 'Studio'),
            ArchyTab(Icons.folder_outlined, 'Projects'),
            ArchyTab(Icons.people_outline, 'Collab'),
            ArchyTab(Icons.person_outline, 'Profile'),
          ],
          floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
              ? FloatingActionButton.extended(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProjectFormScreen(isDarkMode: widget.isDarkMode),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('New Project'),
                )
              : null,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(),
              _buildProjectsTab(),
              _buildCollaborationTab(),
              _buildProfileTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    final c = context.archy;
    final db = Provider.of<DatabaseService>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back',
              style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
          const SizedBox(height: 2),
          FutureBuilder<UserModel?>(
            future: db.getUser(userId!),
            builder: (context, snap) => Text(
              snap.data?.name ?? 'Architect',
              style: ArchyTheme.serif(c, size: 28),
            ),
          ),
          const SizedBox(height: 22),
          StreamBuilder<List<ProjectModel>>(
            stream: db.architectProjectsStream(userId!),
            builder: (context, snapshot) {
              final projects = snapshot.data ?? [];
              final clients = projects
                  .map((p) => p.diasporaId)
                  .where((id) => id != null)
                  .toSet()
                  .length;
              final pending = projects
                  .expand((p) => p.milestones)
                  .where((m) => m.status == 'pending')
                  .length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ArchyStatTile(
                              c: c,
                              label: 'Active',
                              value: projects.length.toString(),
                              sub: 'projects',
                              accent: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: ArchyStatTile(
                              c: c,
                              label: 'Clients',
                              value: clients.toString(),
                              sub: 'assigned')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: ArchyStatTile(
                              c: c,
                              label: 'To verify',
                              value: pending.toString(),
                              sub: 'milestones')),
                    ],
                  ),
                  const SizedBox(height: 26),
                  ArchySectionLabel(
                    c: c,
                    label: 'Projects',
                    trailing: projects.isEmpty
                        ? null
                        : Text(projects.length.toString(),
                            style: ArchyTheme.mono(c, size: 11, color: c.ink3)),
                  ),
                  if (projects.isEmpty)
                    _EmptyHint(
                      c: c,
                      icon: Icons.architecture,
                      title: 'No projects yet',
                      body: 'Tap "New Project" to create your first build.',
                    )
                  else
                    for (final p in projects)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProjectCard(
                          c: c,
                          project: p,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(
                                projectId: p.id,
                                isDarkMode: widget.isDarkMode,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    final c = context.archy;
    final db = Provider.of<DatabaseService>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My projects', style: ArchyTheme.serif(c, size: 26)),
          const SizedBox(height: 18),
          StreamBuilder<List<ProjectModel>>(
            stream: db.architectProjectsStream(userId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final projectList = snapshot.data ?? [];
              if (projectList.isEmpty) {
                return _EmptyHint(
                  c: c,
                  icon: Icons.folder_open,
                  title: 'No projects yet',
                  body: 'Tap "New Project" below to get started.',
                );
              }
              return Column(
                children: [
                  for (final project in projectList)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProjectCard(
                        c: c,
                        project: project,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(
                              projectId: project.id,
                              isDarkMode: widget.isDarkMode,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationTab() {
    final c = context.archy;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live collaboration', style: ArchyTheme.serif(c, size: 26)),
          const SizedBox(height: 6),
          Text('Start a walkthrough and invite your client to join.',
              style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
          const SizedBox(height: 20),
          StreamBuilder<List<ProjectModel>>(
            stream: Provider.of<DatabaseService>(
              context,
              listen: false,
            ).architectProjectsStream(userId ?? ''),
            builder: (context, snapshot) {
              final projects = snapshot.data ?? [];
              if (projects.isEmpty) {
                return _EmptyHint(
                  c: c,
                  icon: Icons.groups_outlined,
                  title: 'No sessions yet',
                  body: 'Create a project first to start a walkthrough.',
                );
              }
              final session = Provider.of<SessionService>(
                context,
                listen: false,
              );
              return Column(
                children: [
                  for (final p in projects)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ArchyCard(
                        c: c,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                style: ArchyTheme.sans(c,
                                    size: 15.5, weight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            StreamBuilder<SessionState>(
                              stream: session.sessionStream(p.id),
                              builder: (context, s) {
                                final n = (s.data ?? SessionState())
                                    .participants
                                    .length;
                                return ArchyPill(
                                  c: c,
                                  tone: n > 0 ? 'green' : 'neutral',
                                  icon: Icons.circle,
                                  label: n > 0
                                      ? '$n in session'
                                      : 'No one in session',
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            ArchyButton(
                              c: c,
                              label: 'Start / Join walkthrough',
                              icon: Icons.view_in_ar,
                              full: true,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WalkthroughScreen(
                                    projectId: p.id,
                                    isDarkMode: widget.isDarkMode,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final c = context.archy;
    final auth = Provider.of<AuthService>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          FutureBuilder<UserModel?>(
            future: auth.getUserData(userId!),
            builder: (context, snap) {
              final name = snap.data?.name ?? 'Architect';
              final email = snap.data?.email ?? '';
              return Column(
                children: [
                  ArchyAvatar(c: c, name: name, size: 84, tone: 'clay'),
                  const SizedBox(height: 16),
                  Text(name, style: ArchyTheme.serif(c, size: 24)),
                  const SizedBox(height: 2),
                  Text(email.isEmpty ? 'Architect' : email,
                      style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          _SettingsItem(
              c: c, icon: Icons.person_outline, title: 'Edit profile'),
          _SettingsItem(
              c: c,
              icon: Icons.notifications_outlined,
              title: 'Notifications'),
          _SettingsItem(
              c: c, icon: Icons.lock_outline, title: 'Privacy & security'),
          _SettingsItem(
              c: c, icon: Icons.help_outline, title: 'Help & support'),
          const SizedBox(height: 8),
          _SettingsItem(
            c: c,
            icon: Icons.logout,
            title: 'Sign out',
            destructive: true,
            onTap: () => auth.signOut(),
          ),
        ],
      ),
    );
  }

}

// Supporting widgets
class _ProjectCard extends StatelessWidget {
  final ArchyColors c;
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.c,
    required this.project,
    required this.onTap,
  });

  double get _pct {
    if (project.milestones.isEmpty) return 0;
    final done = project.milestones
        .where((m) => m.status == 'approved' || m.status == 'paid')
        .length;
    return done / project.milestones.length * 100;
  }

  String _statusTone(String s) {
    switch (s) {
      case 'completed':
        return 'green';
      case 'in_progress':
        return 'blue';
      case 'on_hold':
        return 'gold';
      default:
        return 'clay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ArchyCard(
      c: c,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // thumbnail
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.paper3,
                  borderRadius: BorderRadius.circular(12),
                  image: project.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(project.imageUrl),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: project.imageUrl.isEmpty
                    ? Icon(Icons.home_work_outlined, color: c.ink3, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArchyTheme.sans(c,
                            size: 15.5, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                        project.address.isEmpty
                            ? 'No location set'
                            : project.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArchyTheme.sans(c, size: 12.5, color: c.ink3)),
                    const SizedBox(height: 4),
                    Text(
                        project.diasporaName == null
                            ? 'CLIENT · unassigned'
                            : 'CLIENT · ${project.diasporaName}',
                        style: ArchyTheme.mono(c, size: 10, color: c.ink3)),
                  ],
                ),
              ),
              ArchyPill(
                  c: c,
                  label: project.status.replaceAll('_', ' '),
                  tone: _statusTone(project.status)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: ArchyProgress(c: c, value: _pct, height: 6)),
              const SizedBox(width: 10),
              Text('${_pct.toStringAsFixed(0)}%',
                  style: ArchyTheme.mono(c,
                      size: 12, weight: FontWeight.w700, color: c.clay)),
            ],
          ),
          const SizedBox(height: 10),
          ArchyMoney(c: c, amount: project.budget, size: 15, color: c.ink2),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final ArchyColors c;
  final IconData icon;
  final String title;
  final String body;

  const _EmptyHint({
    required this.c,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return ArchyCard(
      c: c,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 44, color: c.ink3),
          const SizedBox(height: 14),
          Text(title,
              style: ArchyTheme.sans(c, size: 16, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(body,
              textAlign: TextAlign.center,
              style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final ArchyColors c;
  final IconData icon;
  final String title;
  final bool destructive;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.c,
    required this.icon,
    required this.title,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = destructive ? const Color(0xFFC0392B) : c.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ArchyCard(
        c: c,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: destructive ? fg : c.ink2),
            const SizedBox(width: 14),
            Text(title, style: ArchyTheme.sans(c, size: 15, color: fg)),
            const Spacer(),
            Icon(Icons.chevron_right, size: 18, color: c.ink3),
          ],
        ),
      ),
    );
  }
}
