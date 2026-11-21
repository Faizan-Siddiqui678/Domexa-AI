import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._fb) {
    _sub = _fb.authChanges.listen((u) {
      _user = u;
      _ready = true;
      if (u != null) _guest = false;
      notifyListeners();
    });
  }
  final FirebaseService _fb;
  StreamSubscription<User?>? _sub;
  User? _user;
  bool _ready = false, _guest = false, _busy = false;
  String? _error, _info;

  User? get user => _user;
  bool get ready => _ready;
  bool get isGuest => _guest && _user == null;
  bool get isSignedIn => _user != null;
  bool get canEnter => isSignedIn || _guest;
  bool get busy => _busy;
  String? get error => _error;
  String? get info => _info;
  String get displayName => (_user?.displayName?.trim().isNotEmpty ?? false) ? _user!.displayName! : (_user?.email ?? 'Guest');

  void clearMessages() {
    _error = null;
    _info = null;
    notifyListeners();
  }

  void continueAsGuest() {
    _guest = true;
    notifyListeners();
  }

  Future<bool> _do(Future<void> Function() f, {String? okInfo}) async {
    _busy = true;
    _error = null;
    _info = null;
    notifyListeners();
    try {
      await f();
      _info = okInfo;
      return true;
    } catch (e) {
      _error = FirebaseService.friendlyError(e);
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String pw) => _do(() => _fb.signIn(email, pw));
  Future<bool> register(String name, String email, String pw) => _do(() => _fb.register(name, email, pw));
  Future<bool> resetPassword(String email) =>
      _do(() => _fb.sendReset(email), okInfo: 'Reset link sent. Check your email inbox (and spam folder).');

  Future<void> signOut() async {
    await _fb.signOut();
    _guest = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}