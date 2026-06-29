import 'package:cloud_firestore/cloud_firestore.dart';

/// A live collaborative walkthrough session, one per project. Built on Firestore
/// so it needs no extra infrastructure: it syncs who is present and the shared
/// finish selections (floor / wall / roof) in real time. Live text chat is
/// handled separately by the existing `chats/{projectId}` thread.
class SessionState {
  final String? hostUid;
  final String? hostName;
  final bool active;
  final String selectedFloor;
  final String selectedWall;
  final String selectedRoof;
  final List<SessionParticipant> participants;

  SessionState({
    this.hostUid,
    this.hostName,
    this.active = false,
    this.selectedFloor = 'Ceramic Tile',
    this.selectedWall = 'Standard Paint',
    this.selectedRoof = 'Iron Sheets',
    this.participants = const [],
  });

  factory SessionState.fromMap(Map<String, dynamic>? map) {
    if (map == null) return SessionState();
    final raw = (map['participants'] as Map<String, dynamic>?) ?? {};
    final people = raw.entries
        .map((e) => SessionParticipant.fromMap(e.key, e.value))
        .toList();
    return SessionState(
      hostUid: map['hostUid'],
      hostName: map['hostName'],
      active: map['active'] ?? false,
      selectedFloor: map['selectedFloor'] ?? 'Ceramic Tile',
      selectedWall: map['selectedWall'] ?? 'Standard Paint',
      selectedRoof: map['selectedRoof'] ?? 'Iron Sheets',
      participants: people,
    );
  }
}

class SessionParticipant {
  final String uid;
  final String name;
  final String role;

  SessionParticipant({required this.uid, required this.name, required this.role});

  factory SessionParticipant.fromMap(String uid, dynamic value) {
    final m = (value as Map<String, dynamic>?) ?? {};
    return SessionParticipant(
      uid: uid,
      name: m['name'] ?? 'Guest',
      role: m['role'] ?? 'guest',
    );
  }
}

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String projectId) =>
      _firestore.collection('sessions').doc(projectId);

  Stream<SessionState> sessionStream(String projectId) {
    return _doc(projectId).snapshots().map((d) => SessionState.fromMap(d.data()));
  }

  /// Adds the user to the session (creating it if needed). The first joiner —
  /// or anyone passing [asHost] — becomes the host who drives shared selections.
  Future<void> join(
    String projectId, {
    required String uid,
    required String name,
    required String role,
    bool asHost = false,
  }) async {
    final snap = await _doc(projectId).get();
    final exists = snap.exists && (snap.data()?['active'] == true);
    await _doc(projectId).set({
      'active': true,
      if (asHost || !exists) 'hostUid': uid,
      if (asHost || !exists) 'hostName': name,
      'participants': {
        uid: {'name': name, 'role': role, 'lastSeen': DateTime.now().toIso8601String()},
      },
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> leave(String projectId, String uid) async {
    await _doc(projectId).set({
      'participants': {uid: FieldValue.delete()},
    }, SetOptions(merge: true));
  }

  /// Host updates the shared finish selection; all participants see it live.
  Future<void> updateFinishes(
    String projectId, {
    String? floor,
    String? wall,
    String? roof,
  }) async {
    await _doc(projectId).set({
      if (floor != null) 'selectedFloor': floor,
      if (wall != null) 'selectedWall': wall,
      if (roof != null) 'selectedRoof': roof,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}
