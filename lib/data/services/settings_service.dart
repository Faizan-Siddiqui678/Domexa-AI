import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

/// Small local store: server address (so a real phone can reach the PC running FastAPI).
class SettingsService {
  SettingsService(this._prefs);
  final SharedPreferences _prefs;
  static const _kBase = 'api_base_url';

  static Future<SettingsService> load() async => SettingsService(await SharedPreferences.getInstance());

  String get baseUrl => _prefs.getString(_kBase) ?? ApiConstants.defaultBaseUrl;

  Future<void> setBaseUrl(String raw) async {
    var v = raw.trim();
    if (v.isEmpty) {
      await _prefs.remove(_kBase);
      return;
    }
    if (!v.startsWith('http://') && !v.startsWith('https://')) v = 'http://$v';
    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    await _prefs.setString(_kBase, v);
  }
}