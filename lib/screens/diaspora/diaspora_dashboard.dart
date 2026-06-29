import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design/archy_scaffold.dart';
import '../../core/design/archy_context.dart';
import '../../core/design/archy_theme.dart';
import '../../core/design/archy_tokens.dart';
import '../../core/design/archy_widgets.dart';
import '../../core/services/database_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/project_model.dart';
import '../shared/chat_panel.dart';
import 'virtual_visit_screen.dart';
import 'milestone_approval_screen.dart';

class DiasporaDashboard extends StatefulWidget {
  final bool isDarkMode;

  const DiasporaDashboard({super.key, required this.isDarkMode});

  @override
  State<DiasporaDashboard> createState() => _DiasporaDashboardState();
}

class _DiasporaDashboardState extends State<DiasporaDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, DatabaseService>(
      builder: (context, authService, dbService, child) {
        final user = authService.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ArchyDashboardScaffold(
          title: 'My Build',
          subtitle: 'Diaspora client',
          index: _currentIndex,
          onTabChanged: (i) => setState(() => _currentIndex = i),
          tabs: const [
            ArchyTab(Icons.home_outlined, 'Home'),
            ArchyTab(Icons.threed_rotation, 'Visit'),
            ArchyTab(Icons.payments_outlined, 'Payments'),
            ArchyTab(Icons.chat_bubble_outline, 'Chat'),
          ],
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(dbService, user.uid),
              _buildVisitTab(dbService, user.uid),
              _buildPaymentsTab(dbService, user.uid),
              _buildMessagesTab(dbService, user.uid),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeTab(DatabaseService dbService, String userId) {
    final c = context.archy;
    return StreamBuilder<List<ProjectModel>>(
      stream: dbService.diasporaProjectsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final projects = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your build', style: ArchyTheme.serif(c, size: 28)),
              const SizedBox(height: 2),
              Text(
                  projects.isEmpty
                      ? 'Waiting for your architect to invite you'
                      : '${projects.length} active project${projects.length == 1 ? '' : 's'}',
                  style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
              const SizedBox(height: 20),
              if (projects.isEmpty)
                _DiaEmpty(c: c)
              else
                for (final project in projects)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BuildCard(
                      c: c,
                      project: project,
                      onOpen: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MilestoneApprovalScreen(
                            projectId: project.id,
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                      ),
                      onVisit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VirtualVisitScreen(isDarkMode: widget.isDarkMode),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisitTab(DatabaseService db, String uid) {
    return StreamBuilder<List<ProjectModel>>(
      stream: db.diasporaProjectsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final c = context.archy;
        final projects = snapshot.data ?? [];
        if (projects.isEmpty) {
          return _EmptyState(
            c: c,
            icon: Icons.threed_rotation,
            message: 'No projects to visit yet',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text('Virtual visit', style: ArchyTheme.serif(c, size: 26)),
            const SizedBox(height: 16),
            for (final p in projects)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArchyCard(
                  c: c,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VirtualVisitScreen(isDarkMode: widget.isDarkMode),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.claySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.view_in_ar, color: c.clayDeep),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                style: ArchyTheme.sans(c,
                                    size: 15, weight: FontWeight.w600)),
                            Text(
                                p.address.isEmpty ? 'Tap to tour' : p.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ArchyTheme.sans(c,
                                    size: 12.5, color: c.ink3)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: c.ink3),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentsTab(DatabaseService db, String uid) {
    return StreamBuilder<List<ProjectModel>>(
      stream: db.diasporaProjectsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final c = context.archy;
        final projects = snapshot.data ?? [];
        if (projects.isEmpty) {
          return _EmptyState(
            c: c,
            icon: Icons.payments_outlined,
            message: 'No payments due yet',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text('Payments', style: ArchyTheme.serif(c, size: 26)),
            const SizedBox(height: 16),
            for (final p in projects)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArchyCard(
                  c: c,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MilestoneApprovalScreen(
                        projectId: p.id,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title,
                          style: ArchyTheme.sans(c,
                              size: 15, weight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                          '${p.milestones.where((m) => m.status == 'approved' || m.status == 'paid').length}/${p.milestones.length} milestones cleared',
                          style:
                              ArchyTheme.sans(c, size: 12.5, color: c.ink3)),
                      const SizedBox(height: 10),
                      ArchyMoney(c: c, amount: p.budget, size: 16),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMessagesTab(DatabaseService db, String uid) {
    return StreamBuilder<List<ProjectModel>>(
      stream: db.diasporaProjectsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final projects = snapshot.data ?? [];
        if (projects.isEmpty) {
          return _EmptyState(
            c: context.archy,
            icon: Icons.chat_bubble_outline,
            message: 'No conversations yet',
          );
        }
        return ChatPanel(
          projectId: projects.first.id,
          isDarkMode: widget.isDarkMode,
        );
      },
    );
  }

}

/// Hero "active build" card — the centrepiece of the client home.
class _BuildCard extends StatelessWidget {
  final ArchyColors c;
  final ProjectModel project;
  final VoidCallback onOpen;
  final VoidCallback onVisit;

  const _BuildCard({
    required this.c,
    required this.project,
    required this.onOpen,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    final ms = project.milestones;
    final done =
        ms.where((m) => m.status == 'approved' || m.status == 'paid').length;
    final pct = ms.isEmpty ? 0.0 : done / ms.length * 100;
    final next = ms.where((m) => m.status == 'pending').isNotEmpty
        ? ms.firstWhere((m) => m.status == 'pending').title
        : (ms.isEmpty ? 'No milestones yet' : 'All milestones cleared');

    return ArchyCard(
      c: c,
      padding: EdgeInsets.zero,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              height: 130,
              width: double.infinity,
              color: c.paper3,
              child: project.imageUrl.isNotEmpty
                  ? Image.network(project.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.home_work_outlined, color: c.ink3, size: 40))
                  : Icon(Icons.home_work_outlined, color: c.ink3, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(project.title,
                          style: ArchyTheme.serif(c, size: 19)),
                    ),
                    Text('${pct.toStringAsFixed(0)}%',
                        style: ArchyTheme.mono(c,
                            size: 16, weight: FontWeight.w700, color: c.clay)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(project.address.isEmpty ? 'Kenya' : project.address,
                    style: ArchyTheme.sans(c, size: 12.5, color: c.ink3)),
                const SizedBox(height: 14),
                ArchyProgress(c: c, value: pct),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NEXT',
                              style:
                                  ArchyTheme.mono(c, size: 9.5, color: c.ink3)),
                          const SizedBox(height: 2),
                          Text(next,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ArchyTheme.sans(c,
                                  size: 13, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('BUDGET',
                            style:
                                ArchyTheme.mono(c, size: 9.5, color: c.ink3)),
                        const SizedBox(height: 2),
                        ArchyMoney(c: c, amount: project.budget, size: 14),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ArchyButton(
                        c: c,
                        label: 'Virtual visit',
                        icon: Icons.view_in_ar,
                        variant: ArchyBtnVariant.soft,
                        onPressed: onVisit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ArchyButton(
                        c: c,
                        label: 'Milestones',
                        icon: Icons.flag_outlined,
                        onPressed: onOpen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaEmpty extends StatelessWidget {
  final ArchyColors c;
  const _DiaEmpty({required this.c});

  @override
  Widget build(BuildContext context) {
    return ArchyCard(
      c: c,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.construction, size: 46, color: c.ink3),
          const SizedBox(height: 14),
          Text('No projects yet',
              style: ArchyTheme.sans(c, size: 16, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Your architect will invite you here once your build is set up.',
            textAlign: TextAlign.center,
            style: ArchyTheme.sans(c, size: 13, color: c.ink3),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ArchyColors c;
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.c,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: c.ink3),
          const SizedBox(height: 14),
          Text(message, style: ArchyTheme.sans(c, size: 15, color: c.ink3)),
        ],
      ),
    );
  }
}
