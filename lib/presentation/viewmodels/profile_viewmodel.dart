import '../../data/services/api_service.dart';
import '../../data/services/settings_service.dart';
import 'base_viewmodel.dart';

/// Server address + connection test (uses GET /health).
class ProfileViewModel extends BaseViewModel {
  ProfileViewModel(this._settings, this._api);
  final SettingsService _settings;
  final ApiService _api;

  Map<String, dynamic>? health;

  String get baseUrl => _settings.baseUrl;

  Future<void> saveServer(String url) async {
    await _settings.setBaseUrl(url);
    health = null;
    notifyListeners();
  }

  Future<void> testConnection() => run(() => _api.health(), (h) => health = h);

  /// Friendly summary lines from /health.
  List<(String, bool)> get healthLines {
    final h = health;
    if (h == null) return [];
    final ai = (h['ai_chatbot'] is Map ? h['ai_chatbot']['status'] : '')?.toString() ?? '';
    final img = h['image_generation'] is Map && h['image_generation']['hugging_face_token_present'] == true;
    return [
      ('Server is running (v${h['version'] ?? '?'})', true),
      (ai == 'gemini_active' ? 'AI assistant is active' : 'AI assistant is in basic mode (no Gemini key on server)', ai == 'gemini_active'),
      (img ? 'Room image generation is available' : 'Room image generation is not configured on the server', img),
    ];
  }
}