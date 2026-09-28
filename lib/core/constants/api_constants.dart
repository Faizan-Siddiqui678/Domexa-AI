library;

class ApiConstants {
  // ──────────────────────────────────────────────────────────
  // PHYSICAL DEVICE — run `ipconfig` on Windows, find IPv4
  // under your WiFi adapter and paste it below.
  // Phone and PC must be on the SAME WiFi networvk.
  // ──────────────────────────────────────────────────────────
  static const String _pcIpAddress = '192.168.1.7';

  static const String devBaseUrl = 'http://$_pcIpAddress:8000';
  static const bool   isProduction = false;

  static String get baseUrl =>
      isProduction ? 'https://your-api-domain.com' : devBaseUrl;

  // Endpoints
  static const String healthCheck        = '/health';
  static const String generateLayout     = '/api/generate-layout';
  static const String recommendMaterials = '/api/recommend-materials';
  static const String estimateCost       = '/api/estimate-cost';
  static const String chatbot            = '/api/chatbot';
  static const String exportPdf          = '/api/export-pdf';
  static const String livePrices         = '/api/prices';

  // Normalize Flutter budget labels → backend values
  static const Map<String, String> budgetKeyMap = {
    'economy': 'low',  'standard': 'medium', 'premium': 'high',
    'low':     'low',  'medium':   'medium',  'high':    'high',
  };
  static String normalizeBudget(String key) =>
      budgetKeyMap[key.toLowerCase()] ?? 'medium';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout    = Duration(seconds: 60);
  static const Duration pdfTimeout        = Duration(seconds: 90);
}
