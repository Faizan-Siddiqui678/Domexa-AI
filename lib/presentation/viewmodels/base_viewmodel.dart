import 'package:flutter/foundation.dart';
import '../../data/services/api_service.dart';

enum ViewState { idle, loading, success, error }

/// Shared loading/error handling. A request token lets the user cancel or
/// leave a slow request; late answers are ignored (HCI: user control & freedom).
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _error;
  bool _retryable = true;
  int _token = 0;
  bool _disposed = false;

  ViewState get state => _state;
  String? get errorMessage => _error;
  bool get canRetry => _retryable;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;

  @protected
  Future<void> run<T>(Future<T> Function() task, void Function(T) onOk) async {
    final t = ++_token;
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    try {
      final r = await task();
      if (t != _token) return;
      onOk(r);
      _state = ViewState.success;
    } on ApiException catch (e) {
      if (t != _token) return;
      _error = e.message;
      _retryable = e.retryable;
      _state = ViewState.error;
    } catch (_) {
      if (t != _token) return;
      _error = 'Something unexpected happened. Please try again.';
      _retryable = true;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  /// Stop waiting for the running request.
  void cancel() {
    _token++;
    if (_state == ViewState.loading) {
      _state = ViewState.idle;
      notifyListeners();
    }
  }

  @protected
  void setIdle() {
    _state = ViewState.idle;
    _error = null;
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}