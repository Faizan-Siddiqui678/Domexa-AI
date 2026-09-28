import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

/// Firebase Service
/// Handles all Firestore database operations for projects and user data

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Get current user profile
  Future<UserModel?> getUserProfile() async {
    if (_uid == null) return null;
    try {
      final doc = await _db.collection('users').doc(_uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user projects
  Future<List<ProjectModel>> getUserProjects() async {
    if (_uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('projects')
          .orderBy('created_at', descending: true)
          .get();
      return snap.docs
          .map((d) => ProjectModel.fromJson(d.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save a project to Firestore
  Future<void> saveProject(ProjectModel project) async {
    if (_uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('projects')
          .doc(project.projectId)
          .set(project.toJson());
    } catch (e) {
      throw Exception('Failed to save project: $e');
    }
  }

  /// Get all projects for current user
  Future<List<ProjectModel>> getProjects() async {
    if (_uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('projects')
          .orderBy('created_at', descending: true)
          .get();
      return snap.docs
          .map((d) => ProjectModel.fromJson(d.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('projects')
        .doc(projectId)
        .delete();
  }

  /// Update user profile (single method with named parameters)
  Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    String? location,
    String? profilePicture,
  }) async {
    if (_uid == null) return;
    final Map<String, dynamic> data = {};
    if (displayName != null) data['display_name'] = displayName;
    if (phone != null) data['phone'] = phone;
    if (location != null) data['location'] = location;
    if (profilePicture != null) data['profile_picture'] = profilePicture;

    if (data.isNotEmpty) {
      await _db.collection('users').doc(_uid).update(data);
    }
  }

  /// Update user profile (legacy method with Map parameter)
  Future<void> updateUserProfileMap(Map<String, dynamic> data) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).update(data);
  }

  /// Stream of user's projects (real-time)
  Stream<List<ProjectModel>> projectsStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('projects')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ProjectModel.fromJson(d.data()))
        .toList());
  }
}