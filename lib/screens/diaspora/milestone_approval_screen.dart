import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neomorphic_widgets.dart';
import '../../core/services/database_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/project_model.dart';

class MilestoneApprovalScreen extends StatefulWidget {
  final String projectId;
  final bool isDarkMode;

  const MilestoneApprovalScreen({
    super.key,
    required this.projectId,
    required this.isDarkMode,
  });

  @override
  State<MilestoneApprovalScreen> createState() =>
      _MilestoneApprovalScreenState();
}

class _MilestoneApprovalScreenState extends State<MilestoneApprovalScreen> {
  final TextEditingController _commentController = TextEditingController();

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
            title: const Text('Milestone Approval'),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: StreamBuilder<ProjectModel?>(
            stream: dbService.projectStream(widget.projectId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final project = snapshot.data!;
              final pendingMilestones =
                  project.milestones
                      .where((m) => m.status == 'pending')
                      .toList();
              final pending =
                  pendingMilestones.isNotEmpty ? pendingMilestones.first : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Info
                    NeomorphicContainer(
                      isDarkMode: widget.isDarkMode,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.home_work,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        widget.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${project.milestones.where((m) => m.status == "approved" || m.status == "completed").length}/${project.milestones.length} Complete',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        widget.isDarkMode
                                            ? Colors.white54
                                            : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Milestones List
                    Text(
                      'Project Milestones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...project.milestones.map(
                      (milestone) => _MilestoneItem(
                        milestone: milestone,
                        isDarkMode: widget.isDarkMode,
                        onPay: milestone.status == 'approved'
                            ? () => _payMilestone(dbService, milestone)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (pending != null) ...[
                      // Pending Approval Section
                      Text(
                        'Pending Approval',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      NeomorphicContainer(
                        isDarkMode: widget.isDarkMode,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warning.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.pending,
                                    color: AppTheme.warning,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pending.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              widget.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Awaiting your approval',
                                        style: TextStyle(
                                          color: AppTheme.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    widget.isDarkMode
                                        ? Colors.white10
                                        : Colors.black12,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color:
                                        widget.isDarkMode
                                            ? Colors.white54
                                            : Colors.black45,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cost: KES ${pending.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          widget.isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: NeomorphicButton(
                                    isDarkMode: widget.isDarkMode,
                                    onPressed:
                                        () => _approveMilestone(
                                          dbService,
                                          pending.id,
                                        ),

                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Approve',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: NeomorphicButton(
                                    isDarkMode: widget.isDarkMode,
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cancel,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Reject',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    onPressed:
                                        () => _rejectMilestone(
                                          dbService,
                                          pending.id,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Add Comment Section
                    Text(
                      'Add Comment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    NeomorphicContainer(
                      isDarkMode: widget.isDarkMode,
                      padding: const EdgeInsets.all(4),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your feedback or questions...',
                          hintStyle: TextStyle(
                            color:
                                widget.isDarkMode
                                    ? Colors.white38
                                    : Colors.black38,
                          ),
                          filled: true,
                          fillColor:
                              widget.isDarkMode
                                  ? AppTheme.darkSurface
                                  : AppTheme.lightCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: NeomorphicButton(
                        isDarkMode: widget.isDarkMode,
                        onPressed: () => _submitFeedback(dbService, authService),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Submit Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _approveMilestone(DatabaseService db, String milestoneId) async {
    await db.approveMilestone(widget.projectId, milestoneId);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Milestone approved')));
  }

  Future<void> _rejectMilestone(DatabaseService db, String milestoneId) async {
    final reason = _commentController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a reason for rejection')),
      );
      return;
    }
    await db.rejectMilestone(widget.projectId, milestoneId, reason);
    await _postChat(db, 'Milestone rejected: $reason');
    _commentController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Milestone rejected')));
  }

  Future<void> _payMilestone(DatabaseService db, MilestoneModel m) async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) return;
    await db.recordMilestonePayment(
      projectId: widget.projectId,
      milestoneId: m.id,
      amount: m.amount,
      payerId: uid,
    );
    await _postChat(
      db,
      'Payment released for "${m.title}" (KES ${m.amount.toStringAsFixed(0)})',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment released')));
  }

  Future<void> _submitFeedback(DatabaseService db, AuthService auth) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();
    await _postChat(db, text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feedback sent')));
  }

  Future<void> _postChat(DatabaseService db, String text) async {
    final auth = context.read<AuthService>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final user = await auth.getUserData(uid);
    await db.sendMessage(
      widget.projectId,
      text,
      uid,
      user?.name ?? auth.currentUser?.email ?? 'Client',
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final MilestoneModel milestone;
  final bool isDarkMode;
  final VoidCallback? onPay;

  const _MilestoneItem({
    required this.milestone,
    required this.isDarkMode,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (milestone.status) {
      case 'completed':
      case 'approved':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppTheme.warning;
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = AppTheme.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.info;
        statusIcon = Icons.schedule;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            Container(
              width: 2,
              height: 50,
              color: isDarkMode ? Colors.white10 : Colors.black12,
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'KES ${milestone.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    milestone.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                if (onPay != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.payments, size: 18),
                    label: const Text('Release payment'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
