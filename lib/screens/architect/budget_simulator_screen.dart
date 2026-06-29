import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neomorphic_widgets.dart';
import '../../core/data/demo_data.dart';
import '../../core/services/database_service.dart';

class BudgetSimulatorScreen extends StatefulWidget {
  final String projectId;
  final bool isDarkMode;

  const BudgetSimulatorScreen({
    super.key,
    required this.projectId,
    required this.isDarkMode,
  });

  @override
  State<BudgetSimulatorScreen> createState() => _BudgetSimulatorScreenState();
}

class _BudgetSimulatorScreenState extends State<BudgetSimulatorScreen> {
  double _totalBudget = DemoData.totalBudget;
  bool _saving = false;

  String _selectedFloor = 'Ceramic Tile';
  String _selectedWall = 'Standard Paint';
  String _selectedRoof = 'Iron Sheets';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProject());
  }

  Future<void> _loadProject() async {
    final db = context.read<DatabaseService>();
    final project = await db.getProject(widget.projectId);
    if (project != null && mounted && project.budget > 0) {
      setState(() => _totalBudget = project.budget);
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _saving = true);
    final db = context.read<DatabaseService>();
    try {
      await db.updateProjectFields(widget.projectId, {
        'budget': _totalBudget,
        'finishFloor': _selectedFloor,
        'finishWall': _selectedWall,
        'finishRoof': _selectedRoof,
        'finishExtraCost': _totalExtra,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double get _floorCost => DemoData.floorOptions[_selectedFloor] ?? 0;
  double get _wallCost => DemoData.wallOptions[_selectedWall] ?? 0;
  double get _roofCost => DemoData.roofOptions[_selectedRoof] ?? 0;
  double get _totalExtra => _floorCost + _wallCost + _roofCost;
  double get _remainingBudget => _totalBudget - _totalExtra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isDarkMode
              ? AppTheme.darkBackground
              : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor:
            widget.isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        title: Text(
          'Budget Simulator',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Display
            NeomorphicContainer(
              isDarkMode: widget.isDarkMode,
              child: Column(
                children: [
                  Text(
                    'Total Budget',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget.isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DemoData.formatCurrency(_totalBudget),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Budget Impact Bar
                  _BudgetImpactBar(
                    isDarkMode: widget.isDarkMode,
                    used: _totalExtra,
                    total: _totalBudget,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Floor Options
            _OptionSection(
              isDarkMode: widget.isDarkMode,
              title: 'Floor Materials',
              icon: Icons.layers,
              options: DemoData.floorOptions.keys.toList(),
              selected: _selectedFloor,
              onSelect: (value) => setState(() => _selectedFloor = value),
              getCost: (key) => DemoData.floorOptions[key] ?? 0,
            ),
            const SizedBox(height: 20),

            // Wall Options
            _OptionSection(
              isDarkMode: widget.isDarkMode,
              title: 'Wall Finishes',
              icon: Icons.format_paint,
              options: DemoData.wallOptions.keys.toList(),
              selected: _selectedWall,
              onSelect: (value) => setState(() => _selectedWall = value),
              getCost: (key) => DemoData.wallOptions[key] ?? 0,
            ),
            const SizedBox(height: 20),

            // Roof Options
            _OptionSection(
              isDarkMode: widget.isDarkMode,
              title: 'Roofing',
              icon: Icons.roofing,
              options: DemoData.roofOptions.keys.toList(),
              selected: _selectedRoof,
              onSelect: (value) => setState(() => _selectedRoof = value),
              getCost: (key) => DemoData.roofOptions[key] ?? 0,
            ),
            const SizedBox(height: 24),

            // Summary Card
            NeomorphicContainer(
              isDarkMode: widget.isDarkMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    isDarkMode: widget.isDarkMode,
                    label: 'Base Budget',
                    value: DemoData.formatCurrency(_totalBudget),
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    isDarkMode: widget.isDarkMode,
                    label: 'Floor Upgrade',
                    value: '+${DemoData.formatCurrency(_floorCost)}',
                    valueColor: _floorCost > 0 ? AppTheme.warning : null,
                  ),
                  _SummaryRow(
                    isDarkMode: widget.isDarkMode,
                    label: 'Wall Upgrade',
                    value: '+${DemoData.formatCurrency(_wallCost)}',
                    valueColor: _wallCost > 0 ? AppTheme.warning : null,
                  ),
                  _SummaryRow(
                    isDarkMode: widget.isDarkMode,
                    label: 'Roof Upgrade',
                    value: '+${DemoData.formatCurrency(_roofCost)}',
                    valueColor: _roofCost > 0 ? AppTheme.warning : null,
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    isDarkMode: widget.isDarkMode,
                    label: 'Total Extra',
                    value: DemoData.formatCurrency(_totalExtra),
                    isBold: true,
                    valueColor: _totalExtra > 0 ? AppTheme.warning : null,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getBudgetStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getBudgetStatusColor().withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining Budget',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                        Text(
                          DemoData.formatCurrency(_remainingBudget),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getBudgetStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: NeomorphicButton(
                isDarkMode: widget.isDarkMode,
                onPressed: _saving ? null : _saveConfig,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Configuration',
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
      ),
    );
  }

  Color _getBudgetStatusColor() {
    final ratio = _remainingBudget / _totalBudget;
    if (ratio >= 0.4) return AppTheme.success;
    if (ratio >= 0.1) return AppTheme.warning;
    return AppTheme.error;
  }
}

class _BudgetImpactBar extends StatelessWidget {
  final bool isDarkMode;
  final double used;
  final double total;

  const _BudgetImpactBar({
    required this.isDarkMode,
    required this.used,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = used / total;
    Color barColor;
    String status;

    if (ratio < 0.3) {
      barColor = AppTheme.success;
      status = 'Within Budget';
    } else if (ratio < 0.6) {
      barColor = AppTheme.warning;
      status = 'Near Limit';
    } else {
      barColor = AppTheme.error;
      status = 'Over Budget!';
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: isDarkMode ? Colors.white10 : Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Used: ${DemoData.formatCurrency(used)}',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.black45,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OptionSection extends StatelessWidget {
  final bool isDarkMode;
  final String title;
  final IconData icon;
  final List<String> options;
  final String selected;
  final Function(String) onSelect;
  final double Function(String) getCost;

  const _OptionSection({
    required this.isDarkMode,
    required this.title,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.getCost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selected == option;
                final cost = getCost(option);
                return GestureDetector(
                  onTap: () => onSelect(option),
                  child: NeomorphicContainer(
                    isDarkMode: isDarkMode,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppTheme.primaryBlue
                                      : Colors.grey,
                              width: 2,
                            ),
                            color:
                                isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.transparent,
                          ),
                          child:
                              isSelected
                                  ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              cost == 0
                                  ? 'Included'
                                  : '+${DemoData.formatCurrency(cost)}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    cost == 0
                                        ? AppTheme.success
                                        : AppTheme.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final bool isDarkMode;
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.isDarkMode,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
