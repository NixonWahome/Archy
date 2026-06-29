import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neomorphic_widgets.dart';
import '../../core/models/property_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';

class PropertyDetailScreen extends StatelessWidget {
  final bool isDarkMode;
  final PropertyModel property;

  const PropertyDetailScreen({
    super.key,
    required this.isDarkMode,
    required this.property,
  });

  Future<void> _reserve(BuildContext context) async {
    final auth = context.read<AuthService>();
    final db = context.read<DatabaseService>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final user = await auth.getUserData(uid);
    await db.createLead(
      propertyId: property.id,
      propertyTitle: property.title,
      developerId: property.developerId,
      buyerId: uid,
      buyerName: user?.name ?? auth.currentUser?.email ?? 'Buyer',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation request sent to developer')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = property.imageUrl.isNotEmpty;
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        title: Text(
          property.title,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: hasImage
                  ? Image.network(
                      property.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'KES ${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeomorphicContainer(
                    isDarkMode: isDarkMode,
                    child: Column(
                      children: [
                        _DetailRow(
                          isDarkMode: isDarkMode,
                          label: 'Type',
                          value: property.propertyType.toUpperCase(),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          isDarkMode: isDarkMode,
                          label: 'Bedrooms',
                          value: property.bedrooms.toString(),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          isDarkMode: isDarkMode,
                          label: 'Bathrooms',
                          value: property.bathrooms.toString(),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          isDarkMode: isDarkMode,
                          label: 'Area',
                          value: '${property.squareFeet.toStringAsFixed(0)} m²',
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          isDarkMode: isDarkMode,
                          label: 'Status',
                          value: property.status.toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                  if (property.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.description,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: property.status == 'available'
                          ? () => _reserve(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        property.status == 'available'
                            ? 'Reserve Unit'
                            : 'Not available',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.4),
            AppTheme.primaryBlue.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.apartment,
          size: 100,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
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
    return Row(
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
