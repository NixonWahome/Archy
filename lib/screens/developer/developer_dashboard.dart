import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neomorphic_widgets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../core/design/archy_scaffold.dart';
import '../../core/design/archy_context.dart';
import '../../core/design/archy_theme.dart';
import '../../core/design/archy_tokens.dart';
import '../../core/design/archy_widgets.dart';
import '../../core/models/property_model.dart';
import 'property_detail_screen.dart';
import 'property_form_screen.dart';

class DeveloperDashboard extends StatefulWidget {
  final bool isDarkMode;

  const DeveloperDashboard({super.key, required this.isDarkMode});

  @override
  State<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends State<DeveloperDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ArchyDashboardScaffold(
      title: 'Developments',
      subtitle: 'Developer',
      index: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      tabs: const [
        ArchyTab(Icons.grid_view_rounded, 'Home'),
        ArchyTab(Icons.apartment_outlined, 'Listings'),
        ArchyTab(Icons.trending_up, 'Sales'),
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
                      PropertyFormScreen(isDarkMode: widget.isDarkMode),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New Property'),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildPropertiesTab(),
          _buildSalesTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  String? get _uid => context.read<AuthService>().currentUser?.uid;

  Widget _buildHomeTab() {
    final c = context.archy;
    final db = Provider.of<DatabaseService>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: db.getUser(_uid ?? ''),
            builder: (context, snap) {
              final name = snap.data?.name ?? 'Developer';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back',
                      style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
                  const SizedBox(height: 2),
                  Text(name, style: ArchyTheme.serif(c, size: 28)),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          StreamBuilder<List<PropertyModel>>(
            stream: db.developerPropertiesStream(_uid ?? ''),
            builder: (context, snapshot) {
              final properties = snapshot.data ?? [];
              final sold = properties.where((p) => p.status == 'sold').length;
              final available =
                  properties.where((p) => p.status == 'available').length;
              return Row(
                children: [
                  Expanded(
                      child: ArchyStatTile(
                          c: c,
                          label: 'Listings',
                          value: properties.length.toString(),
                          sub: 'total',
                          accent: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ArchyStatTile(
                          c: c,
                          label: 'Available',
                          value: available.toString(),
                          sub: 'on market')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ArchyStatTile(
                          c: c,
                          label: 'Sold',
                          value: sold.toString(),
                          sub: 'units')),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: db.leadsStream(_uid ?? ''),
            builder: (context, leadSnap) {
              final leads = leadSnap.data ?? [];
              return ArchyCard(
                c: c,
                color: c.blueprintSoft,
                onTap: () => setState(() => _currentIndex = 2),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_outlined, color: c.blueprint),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('${leads.length} active lead${leads.length == 1 ? '' : 's'}',
                          style: ArchyTheme.sans(c,
                              size: 14,
                              weight: FontWeight.w600,
                              color: c.blueprint)),
                    ),
                    Icon(Icons.chevron_right, color: c.blueprint),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 26),
          ArchySectionLabel(c: c, label: 'Your listings'),
          StreamBuilder<List<PropertyModel>>(
            stream: db.developerPropertiesStream(_uid ?? ''),
            builder: (context, snapshot) {
              final properties = snapshot.data ?? [];
              if (properties.isEmpty) {
                return _DevEmpty(
                  c: c,
                  onAdd: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyFormScreen(isDarkMode: widget.isDarkMode),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final p in properties)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PropertyCard(
                        c: c,
                        property: p,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              isDarkMode: widget.isDarkMode,
                              property: p,
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

  Widget _buildPropertiesTab() {
    final c = context.archy;
    final db = Provider.of<DatabaseService>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Listings', style: ArchyTheme.serif(c, size: 26)),
          const SizedBox(height: 18),
          StreamBuilder<List<PropertyModel>>(
            stream: db.developerPropertiesStream(_uid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final properties = snapshot.data ?? [];
              if (properties.isEmpty) {
                return _DevEmpty(
                  c: c,
                  onAdd: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyFormScreen(isDarkMode: widget.isDarkMode),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final p in properties)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PropertyCard(
                        c: c,
                        property: p,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              isDarkMode: widget.isDarkMode,
                              property: p,
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

  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Revenue Card
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
                        color: AppTheme.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Revenue',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  widget.isDarkMode
                                      ? Colors.white54
                                      : Colors.black45,
                            ),
                          ),
                          StreamBuilder<List<PropertyModel>>(
                            stream: Provider.of<DatabaseService>(
                              context,
                              listen: false,
                            ).developerPropertiesStream(_uid ?? ''),
                            builder: (context, snap) {
                              final revenue = (snap.data ?? [])
                                  .where((p) => p.status == 'sold')
                                  .fold<double>(0, (s, p) => s + p.price);
                              return Text(
                                'KES ${revenue.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<PropertyModel>>(
                  stream: Provider.of<DatabaseService>(
                    context,
                    listen: false,
                  ).developerPropertiesStream(_uid ?? ''),
                  builder: (context, snap) {
                    final props = snap.data ?? [];
                    final available =
                        props.where((p) => p.status == 'available').length;
                    final sold = props.where((p) => p.status == 'sold').length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SalesMetric(
                          isDarkMode: widget.isDarkMode,
                          label: 'Available',
                          value: available.toString(),
                          isPositive: true,
                        ),
                        _SalesMetric(
                          isDarkMode: widget.isDarkMode,
                          label: 'Sold',
                          value: sold.toString(),
                          isPositive: true,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recent Inquiries (live leads)
          Text(
            'Recent Inquiries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Provider.of<DatabaseService>(
              context,
              listen: false,
            ).leadsStream(_uid ?? ''),
            builder: (context, snap) {
              final leads = snap.data ?? [];
              if (leads.isEmpty) {
                return Text(
                  'No inquiries yet',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                );
              }
              return Column(
                children: [
                  for (final l in leads)
                    _SaleItem(
                      isDarkMode: widget.isDarkMode,
                      property: (l['propertyTitle'] ?? 'Property').toString(),
                      buyer: (l['buyerName'] ?? 'Buyer').toString(),
                      amount: (l['status'] ?? 'new').toString().toUpperCase(),
                      date: '',
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
          FutureBuilder(
            future: auth.getUserData(_uid ?? ''),
            builder: (context, snap) {
              final name = snap.data?.name ?? 'Developer';
              final email = snap.data?.email ?? '';
              return Column(
                children: [
                  ArchyAvatar(c: c, name: name, size: 84, tone: 'blue'),
                  const SizedBox(height: 16),
                  Text(name, style: ArchyTheme.serif(c, size: 24)),
                  const SizedBox(height: 2),
                  Text(email.isEmpty ? 'Developer' : email,
                      style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          _SettingsItem(c: c, icon: Icons.business, title: 'Company profile'),
          _SettingsItem(
              c: c, icon: Icons.analytics_outlined, title: 'Analytics'),
          _SettingsItem(c: c, icon: Icons.settings_outlined, title: 'Settings'),
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

class _PropertyCard extends StatelessWidget {
  final ArchyColors c;
  final PropertyModel property;
  final VoidCallback onTap;

  const _PropertyCard({
    required this.c,
    required this.property,
    required this.onTap,
  });

  String _tone(String s) {
    switch (s) {
      case 'sold':
        return 'neutral';
      case 'reserved':
        return 'gold';
      default:
        return 'green';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ArchyCard(
      c: c,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  color: c.paper3,
                  child: property.imageUrl.isNotEmpty
                      ? Image.network(property.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Icon(
                              Icons.apartment, color: c.ink3, size: 40))
                      : Icon(Icons.apartment, color: c.ink3, size: 40),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: ArchyPill(
                      c: c,
                      label: property.status,
                      tone: _tone(property.status)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    style: ArchyTheme.serif(c, size: 18)),
                const SizedBox(height: 3),
                Text(
                    '${property.propertyType} · ${property.address.isEmpty ? 'Kenya' : property.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArchyTheme.sans(c, size: 12.5, color: c.ink3)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ArchyMoney(c: c, amount: property.price, size: 18),
                    Row(
                      children: [
                        Icon(Icons.bed_outlined, size: 15, color: c.ink3),
                        const SizedBox(width: 3),
                        Text('${property.bedrooms}',
                            style: ArchyTheme.mono(c, size: 12, color: c.ink2)),
                        const SizedBox(width: 10),
                        Icon(Icons.square_foot, size: 15, color: c.ink3),
                        const SizedBox(width: 3),
                        Text('${property.squareFeet.toStringAsFixed(0)}m²',
                            style: ArchyTheme.mono(c, size: 12, color: c.ink2)),
                      ],
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

class _DevEmpty extends StatelessWidget {
  final ArchyColors c;
  final VoidCallback onAdd;
  const _DevEmpty({required this.c, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ArchyCard(
      c: c,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.apartment_outlined, size: 46, color: c.ink3),
          const SizedBox(height: 14),
          Text('No properties yet',
              style: ArchyTheme.sans(c, size: 16, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Add your first listing to start attracting buyers.',
              textAlign: TextAlign.center,
              style: ArchyTheme.sans(c, size: 13, color: c.ink3)),
          const SizedBox(height: 16),
          ArchyButton(
              c: c, label: 'Add property', icon: Icons.add, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _SalesMetric extends StatelessWidget {
  final bool isDarkMode;
  final String label;
  final String value;
  final bool isPositive;

  const _SalesMetric({
    required this.isDarkMode,
    required this.label,
    required this.value,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: isPositive ? AppTheme.success : AppTheme.error,
            ),
          ],
        ),
      ],
    );
  }
}

class _SaleItem extends StatelessWidget {
  final bool isDarkMode;
  final String property;
  final String buyer;
  final String amount;
  final String date;

  const _SaleItem({
    required this.isDarkMode,
    required this.property,
    required this.buyer,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeomorphicContainer(
        isDarkMode: isDarkMode,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check, color: AppTheme.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '$buyer • $date',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.success,
              ),
            ),
          ],
        ),
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
