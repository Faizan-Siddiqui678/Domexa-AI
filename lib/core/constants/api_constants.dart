/// Endpoints and timeouts. Paths match backend_final/main.py exactly.
class ApiConstants {
  /// Android emulator -> host PC. On a real phone, set the PC's Wi-Fi IP in
  /// Profile > Server address (or build with --dart-define=API_BASE_URL=...).
  static const String defaultBaseUrl =
  String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.1.4:8000');

  static const String health = '/health';
  static const String prices = '/api/prices';
  static const String layout = '/api/generate-layout';
  static const String interior = '/api/interior-design';
  static const String materials = '/api/recommend-materials';
  static const String cost = '/api/estimate-cost';
  static const String chatbot = '/api/chatbot';
  static const String exportPdf = '/api/export-pdf';

  static const Duration shortTimeout = Duration(seconds: 15);
  static const Duration aiTimeout = Duration(seconds: 75); // LLM + live scraping
  static const Duration imageTimeout = Duration(seconds: 150); // Stable Diffusion
}