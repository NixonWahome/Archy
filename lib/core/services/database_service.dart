import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';
import 'package:file_picker/file_picker.dart';
import 'storage_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();

  // Collection names
  static const String usersCollection = 'users';
  static const String propertiesCollection = 'properties';
  static const String projectsCollection = 'projects';
  static const String milestonesCollection = 'milestones';

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection(usersCollection).doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection(usersCollection).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(usersCollection)
        .doc(user.id)
        .update(user.toMap());
  }

  Stream<UserModel?> userStream(String userId) {
    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  // Property operations
  Future<void> createProperty(PropertyModel property) async {
    await _firestore
        .collection(propertiesCollection)
        .doc(property.id)
        .set(property.toMap());
  }

  Future<PropertyModel?> getProperty(String propertyId) async {
    final doc =
        await _firestore.collection(propertiesCollection).doc(propertyId).get();
    if (doc.exists) {
      return PropertyModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateProperty(PropertyModel property) async {
    await _firestore
        .collection(propertiesCollection)
        .doc(property.id)
        .update(property.toMap());
  }

  Future<void> deleteProperty(String propertyId) async {
    await _firestore.collection(propertiesCollection).doc(propertyId).delete();
  }

  /// Uploads a property image to the free host and returns its public URL.
  Future<String?> uploadPropertyImage(
    String propertyId,
    PlatformFile file,
  ) async {
    if (file.bytes == null || file.bytes!.isEmpty) return null;
    return _storage.uploadPickedFile(
      file,
      folder: 'property_images/$propertyId',
    );
  }

  // Leads / inquiries ---------------------------------------------------------

  Future<void> createLead({
    required String propertyId,
    required String propertyTitle,
    required String developerId,
    required String buyerId,
    required String buyerName,
    String message = '',
  }) async {
    await _firestore.collection('leads').add({
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'developerId': developerId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'message': message,
      'status': 'new',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> leadsStream(String developerId) {
    return _firestore
        .collection('leads')
        .where('developerId', isEqualTo: developerId)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Stream<List<PropertyModel>> propertiesStream() {
    return _firestore
        .collection(propertiesCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Stream<List<PropertyModel>> developerPropertiesStream(String developerId) {
    return _firestore
        .collection(propertiesCollection)
        .where('developerId', isEqualTo: developerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Project operations
  Future<void> createProject(ProjectModel project) async {
    await _firestore
        .collection(projectsCollection)
        .doc(project.id)
        .set(project.toMap());
  }

  Future<ProjectModel?> getProject(String projectId) async {
    final doc =
        await _firestore.collection(projectsCollection).doc(projectId).get();
    if (doc.exists) {
      return ProjectModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateProject(ProjectModel project) async {
    await _firestore
        .collection(projectsCollection)
        .doc(project.id)
        .update(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _firestore.collection(projectsCollection).doc(projectId).delete();
  }

  Stream<List<ProjectModel>> architectProjectsStream(String architectId) {
    return _firestore
        .collection(projectsCollection)
        .where('architectId', isEqualTo: architectId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Stream<List<ProjectModel>> diasporaProjectsStream(String diasporaId) {
    return _firestore
        .collection(projectsCollection)
        .where('diasporaId', isEqualTo: diasporaId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Stream<List<ProjectModel>> allProjectsStream() {
    return _firestore
        .collection(projectsCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Stream<List<Message>> chatStream(String projectId) {
    return _firestore
        .collection('chats')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList(),
        );
  }

  Future<void> sendMessage(
    String projectId,
    String text,
    String senderId,
    String senderName,
  ) async {
    await _firestore
        .collection('chats')
        .doc(projectId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': senderId,
          'senderName': senderName,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Stream<ProjectModel?> projectStream(String projectId) {
    return _firestore
        .collection(projectsCollection)
        .doc(projectId)
        .snapshots()
        .map((doc) => doc.exists ? ProjectModel.fromMap(doc.data()!) : null);
  }

  Future<String?> uploadARModel(String projectId, PlatformFile file) async {
    if (file.bytes == null || file.bytes!.isEmpty) return null;

    final downloadUrl = await _storage.uploadPickedFile(
      file,
      folder: 'ar_models/$projectId',
    );

    // Update project Firestore
    await _firestore.collection(projectsCollection).doc(projectId).update({
      'model3dUrl': downloadUrl,
    });

    return downloadUrl;
  }

  Future<void> updateProjectModelUrl(String projectId, String modelUrl) async {
    await _firestore.collection(projectsCollection).doc(projectId).update({
      'model3dUrl': modelUrl,
    });
  }

  Stream<String?> projectModel3dUrlStream(String projectId) {
    return projectStream(projectId).map((p) => p?.model3dUrl);
  }

  // Generic helpers -----------------------------------------------------------

  /// Generates a Firestore-style unique id for new documents created client-side.
  String newDocId() => _firestore.collection('_meta').doc().id;

  /// Patches arbitrary fields on a project (status, budget config, etc.).
  Future<void> updateProjectFields(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(projectsCollection).doc(projectId).update({
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProjectStatus(String projectId, String status) =>
      updateProjectFields(projectId, {'status': status});

  /// Appends a milestone to a project.
  Future<void> addMilestone(String projectId, MilestoneModel milestone) async {
    final project = await getProject(projectId);
    if (project == null) return;
    final list = [...project.milestones, milestone];
    await _firestore.collection(projectsCollection).doc(projectId).update({
      'milestones': list.map((m) => m.toMap()).toList(),
    });
  }

  /// Uploads a project cover image to the free host and stores the URL.
  Future<String?> uploadProjectImage(String projectId, PlatformFile file) async {
    if (file.bytes == null || file.bytes!.isEmpty) return null;
    final url = await _storage.uploadPickedFile(
      file,
      folder: 'project_images/$projectId',
    );
    await _firestore.collection(projectsCollection).doc(projectId).update({
      'imageUrl': url,
    });
    return url;
  }

  // Client assignment ---------------------------------------------------------

  /// Looks up a user by their email (used by architects to invite a diaspora
  /// client to a project). Returns null if no account uses that email.
  Future<UserModel?> findUserByEmail(String email) async {
    final snapshot =
        await _firestore
            .collection(usersCollection)
            .where('email', isEqualTo: email.trim().toLowerCase())
            .limit(1)
            .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromMap(snapshot.docs.first.data());
  }

  /// Assigns a diaspora client to a project so it appears in their dashboard
  /// (`diasporaProjectsStream` filters on `diasporaId`).
  Future<void> assignClientToProject(
    String projectId,
    String diasporaId,
    String diasporaName,
  ) async {
    await _firestore.collection(projectsCollection).doc(projectId).update({
      'diasporaId': diasporaId,
      'diasporaName': diasporaName,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Payments ------------------------------------------------------------------

  /// Records a payment against a milestone and marks that milestone as paid.
  Future<void> recordMilestonePayment({
    required String projectId,
    required String milestoneId,
    required double amount,
    required String payerId,
    String method = 'manual',
    String reference = '',
  }) async {
    final payments = _firestore
        .collection(projectsCollection)
        .doc(projectId)
        .collection('payments');
    await payments.add({
      'milestoneId': milestoneId,
      'amount': amount,
      'payerId': payerId,
      'method': method,
      'reference': reference,
      'status': 'released',
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Flip the milestone to paid.
    final project = await getProject(projectId);
    if (project != null) {
      final milestones =
          project.milestones.map((m) {
            if (m.id == milestoneId) {
              return MilestoneModel(
                id: m.id,
                title: m.title,
                description: m.description,
                amount: m.amount,
                status: 'paid',
                order: m.order,
                dueDate: m.dueDate,
                completedAt: DateTime.now(),
              );
            }
            return m;
          }).toList();
      await _firestore.collection(projectsCollection).doc(projectId).update({
        'milestones': milestones.map((m) => m.toMap()).toList(),
      });
    }
  }

  Stream<List<Map<String, dynamic>>> paymentsStream(String projectId) {
    return _firestore
        .collection(projectsCollection)
        .doc(projectId)
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // Milestone operations
  Future<void> updateMilestone(
    String projectId,
    MilestoneModel milestone,
  ) async {
    final project = await getProject(projectId);
    if (project != null) {
      final milestones =
          project.milestones.map((m) {
            if (m.id == milestone.id) {
              return milestone;
            }
            return m;
          }).toList();

      await _firestore.collection(projectsCollection).doc(projectId).update({
        'milestones': milestones.map((m) => m.toMap()).toList(),
      });
    }
  }

  Future<void> approveMilestone(String projectId, String milestoneId) async {
    final project = await getProject(projectId);
    if (project != null) {
      final milestones =
          project.milestones.map((m) {
            if (m.id == milestoneId) {
              return MilestoneModel(
                id: m.id,
                title: m.title,
                description: m.description,
                amount: m.amount,
                status: 'approved',
                order: m.order,
                dueDate: m.dueDate,
                completedAt: m.completedAt,
              );
            }
            return m;
          }).toList();

      await _firestore.collection(projectsCollection).doc(projectId).update({
        'milestones': milestones.map((m) => m.toMap()).toList(),
      });
    }
  }

  Future<void> rejectMilestone(
    String projectId,
    String milestoneId,
    String reason,
  ) async {
    final project = await getProject(projectId);
    if (project != null) {
      final milestones =
          project.milestones.map((m) {
            if (m.id == milestoneId) {
              return MilestoneModel(
                id: m.id,
                title: m.title,
                description: m.description,
                amount: m.amount,
                status: 'rejected',
                order: m.order,
                dueDate: m.dueDate,
                completedAt: m.completedAt,
              );
            }
            return m;
          }).toList();

      await _firestore.collection(projectsCollection).doc(projectId).update({
        'milestones': milestones.map((m) => m.toMap()).toList(),
      });
    }
  }
}
