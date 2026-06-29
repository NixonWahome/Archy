import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Create or update user in Firestore after authentication
  Future<void> createUserDocument(User user, String name, String role) async {
    final existingUser = await _databaseService.getUser(user.uid);
    if (existingUser == null) {
      final newUser = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        role: role,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await _databaseService.createUser(newUser);
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    return await _databaseService.getUser(userId);
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    await _databaseService.updateUser(user);
  }

  // Update user email (deprecated - to be replaced if used)
  Future<void> updateEmail(String email) async {
    await currentUser?.verifyBeforeUpdateEmail(email);
  }

  // Update user password
  Future<void> updatePassword(String password) async {
    await currentUser?.updatePassword(password);
  }

  // Delete account
  Future<void> deleteAccount() async {
    await currentUser?.delete();
  }
}
