import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/project_model.dart';
import '../../data/services/firebase_service.dart';

class ProjectsViewModel extends ChangeNotifier {
  ProjectsViewModel(this._fb);
  final FirebaseService _fb;

  StreamSubscription<List<ProjectModel>>? _sub;
  String? _uid;
  List<ProjectModel> projects = [];
  String? error;
  ProjectModel? _lastDeleted;

  /// Call whenever the signed-in user changes.
  void bind(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    projects = [];
    error = null;
    if (uid == null) {
      notifyListeners();
      return;
    }
    _sub = _fb.watchProjects(uid).listen((p) {
      projects = p;
      error = null;
      notifyListeners();
    }, onError: (_) {
      error = 'Could not load your saved projects.';
      notifyListeners();
    });
  }

  Future<bool> save(ProjectModel p) async {
    if (_uid == null) return false;
    try {
      await _fb.saveProject(_uid!, p);
      return true;
    } catch (e) {
      error = FirebaseService.friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> delete(ProjectModel p) async {
    if (_uid == null) return;
    _lastDeleted = p;
    await _fb.deleteProject(_uid!, p.id);
  }

  /// Undo for the "Project deleted" snackbar.
  Future<void> undoDelete() async {
    final p = _lastDeleted;
    if (p == null || _uid == null) return;
    await _fb.saveProject(_uid!, p);
    _lastDeleted = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}