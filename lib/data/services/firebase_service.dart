import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> register(String name, String email, String password) async {
    final c = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await c.user?.updateDisplayName(name.trim());
  }

  Future<void> sendReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => _auth.signOut();

  CollectionReference<Map<String, dynamic>> _projects(String uid) =>
      _db.collection('users').doc(uid).collection('projects');

  Stream<List<ProjectModel>> watchProjects(String uid) => _projects(uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ProjectModel.fromMap(d.id, d.data())).toList());

  Future<void> saveProject(String uid, ProjectModel p) => _projects(uid).doc(p.id).set(p.toMap());
  Future<void> deleteProject(String uid, String id) => _projects(uid).doc(id).delete();

  /// Plain-language messages (heuristic: help users recognise and recover from errors).
  static String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email': return 'That email address does not look right.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential': return 'Email or password is incorrect. You can reset your password below.';
        case 'email-already-in-use': return 'An account with this email already exists. Try signing in instead.';
        case 'weak-password': return 'Choose a stronger password (at least 6 characters).';
        case 'network-request-failed': return 'No internet connection. Check your network and try again.';
        case 'too-many-requests': return 'Too many attempts. Please wait a few minutes and try again.';
        case 'user-disabled': return 'This account has been disabled.';
      }
    }
    if (e is FirebaseException && e.code == 'permission-denied') {
      return 'You do not have permission to do that. Please sign in again.';
    }
    return 'Something went wrong. Please try again.';
  }
}