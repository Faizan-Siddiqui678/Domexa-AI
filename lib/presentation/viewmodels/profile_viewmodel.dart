import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/project_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  ProfileViewModel({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  UserModel? _user;
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  UserModel?          get user           => _user;
  List<ProjectModel>  get projects       => _projects;
  bool                get isLoading      => _isLoading;
  bool                get isSaving       => _isSaving;
  String?             get errorMessage   => _errorMessage;
  String?             get successMessage => _successMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user     = await _firebaseService.getUserProfile();
      _projects = await _firebaseService.getUserProjects();
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    required String phone,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await _firebaseService.updateUserProfile(
          displayName: displayName, phone: phone);
      _user = _user?.copyWith(displayName: displayName, phone: phone);
      _successMessage = 'Profile updated successfully!';
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'Update failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _firebaseService.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Delete failed: $e';
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}