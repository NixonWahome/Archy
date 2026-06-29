/// Project model for architect projects
class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String address;
  final double budget;
  final String imageUrl;
  final List<String> images;
  final String status; // 'planning', 'in_progress', 'completed', 'on_hold'
  final String architectId;
  final String architectName;
  final String? diasporaId;
  final String? diasporaName;
  final String? model3dUrl;
  final List<MilestoneModel> milestones;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.budget,
    required this.imageUrl,
    required this.images,
    required this.status,
    required this.architectId,
    required this.architectName,
    this.diasporaId,
    this.diasporaName,
    this.model3dUrl,
    required this.milestones,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      budget: (map['budget'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      status: map['status'] ?? 'planning',
      architectId: map['architectId'] ?? '',
      architectName: map['architectName'] ?? '',
      diasporaId: map['diasporaId'],
      diasporaName: map['diasporaName'],
      model3dUrl: map['model3dUrl'],
      milestones:
          (map['milestones'] as List<dynamic>?)
              ?.map((m) => MilestoneModel.fromMap(m))
              .toList() ??
          [],
      startDate:
          map['startDate'] != null
              ? DateTime.parse(map['startDate'])
              : DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'budget': budget,
      'imageUrl': imageUrl,
      'images': images,
      'status': status,
      'architectId': architectId,
      'architectName': architectName,
      'diasporaId': diasporaId,
      'diasporaName': diasporaName,
      'model3dUrl': model3dUrl,
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Milestone model for project milestones
class MilestoneModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String status; // 'pending', 'approved', 'rejected', 'paid'
  final int order;
  final DateTime? dueDate;
  final DateTime? completedAt;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.status,
    required this.order,
    this.dueDate,
    this.completedAt,
  });

  factory MilestoneModel.fromMap(Map<String, dynamic> map) {
    return MilestoneModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      order: map['order'] ?? 0,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      completedAt:
          map['completedAt'] != null
              ? DateTime.parse(map['completedAt'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'status': status,
      'order': order,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
