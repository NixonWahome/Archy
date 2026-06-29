class DemoData {
  // App Info
  static const String appName = 'BuildSync XR';
  static const String tagline = 'Design Together. Build Anywhere.';

  // Demo Project - Karen Modern Villa
  static const String projectName = 'Karen Modern Villa';
  static const double totalBudget = 18500000; // KES
  static const double budgetUsed = 12400000; // KES
  static const int completionPercentage = 65;
  static const double area = 320; // sqm
  static const String location = 'Karen, Nairobi';
  static const String status = 'Design Phase';
  static const String lastUpdated = '2 days ago';

  // Budget breakdown
  static const Map<String, double> floorOptions = {
    'Ceramic Tile': 0,
    'Hardwood': 350000,
    'Marble': 1200000,
  };

  static const Map<String, double> wallOptions = {
    'Standard Paint': 0,
    'Premium Paint': 150000,
    'Textured Walls': 280000,
  };

  static const Map<String, double> roofOptions = {
    'Iron Sheets': 0,
    'Tiles': 450000,
    'Green Roof': 850000,
  };

  // Milestones
  static const List<Map<String, dynamic>> milestones = [
    {'name': 'Foundation', 'status': 'completed', 'cost': 2500000},
    {'name': 'Structure', 'status': 'completed', 'cost': 4500000},
    {'name': 'Roofing', 'status': 'pending', 'cost': 1800000},
    {'name': 'Electrical', 'status': 'upcoming', 'cost': 1200000},
    {'name': 'Plumbing', 'status': 'upcoming', 'cost': 1500000},
    {'name': 'Finishing', 'status': 'upcoming', 'cost': 3500000},
  ];

  // Collaboration messages
  static const List<Map<String, dynamic>> chatMessages = [
    {
      'sender': 'Architect',
      'message': 'Can we increase ceiling height?',
      'time': '10:30 AM',
    },
    {'sender': 'Client', 'message': 'Yes, updating now.', 'time': '10:32 AM'},
    {
      'sender': 'Architect',
      'message': 'I\'ve added the skylight as requested.',
      'time': '10:45 AM',
    },
    {
      'sender': 'Client',
      'message': 'Looks amazing! Can we see it in VR?',
      'time': '10:46 AM',
    },
  ];

  // Projects for architect
  static const List<Map<String, dynamic>> architectProjects = [
    {
      'name': 'Karen Modern Villa',
      'status': 'Design Phase',
      'lastUpdated': '2 days ago',
      'budget': 'KES 18.5M',
      'completion': 65,
    },
    {
      'name': 'Westlands Penthouse',
      'status': 'Construction',
      'lastUpdated': '1 week ago',
      'budget': 'KES 42M',
      'completion': 35,
    },
    {
      'name': 'Kilimani Apartment',
      'status': 'Pending Approval',
      'lastUpdated': '3 days ago',
      'budget': 'KES 8.5M',
      'completion': 0,
    },
  ];

  // Developer properties
  static const List<Map<String, dynamic>> developerProperties = [
    {
      'name': 'Luxury Apartments - Westlands',
      'type': '2 Bedroom',
      'price': 'KES 12.5M',
      'location': 'Westlands',
      'status': 'Available',
    },
    {
      'name': 'Garden City Residences',
      'type': '3 Bedroom',
      'price': 'KES 18M',
      'location': 'Garden City',
      'status': 'Available',
    },
    {
      'name': 'Kilimani Studio',
      'type': 'Studio',
      'price': 'KES 6.5M',
      'location': 'Kilimani',
      'status': 'Reserved',
    },
  ];

  // Diaspora client info
  static const Map<String, dynamic> diasporaClient = {
    'name': 'James Kariuki',
    'location': 'London, UK',
    'project': 'Karen Modern Villa',
    'progress': 65,
    'nextMilestone': 'Roofing',
    'budgetUsed': 'KES 12.4M',
    'budgetTotal': 'KES 18.5M',
    'nextPayment': 'KES 2M',
    'paymentDueDate': 'March 15, 2024',
  };

  // Format currency
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'KES ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'KES ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'KES $amount';
  }
}
