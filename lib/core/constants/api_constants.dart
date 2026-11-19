// lib/core/constants/api_constants.dart
// v4 — added interiorDesign endpoint + increased timeouts

library;

class ApiConstants {
  // ──────────────────────────────────────────────────────────────────────────
  // PHYSICAL DEVICE — run `ipconfig` on Windows, find IPv4
  // under your WiFi adapter and paste it below.
  // Phone and PC must be on the SAME WiFi network.
  // ──────────────────────────────────────────────────────────────────────────
  static const String _pcIpAddress = '192.168.1.7'; // ← your PC's WiFi IP

  static const String devBaseUrl   = 'http://$_pcIpAddress:8000';
  static const bool   isProduction = false;

  static String get baseUrl =>
      isProduction ? 'https://your-api-domain.com' : devBaseUrl;

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String healthCheck        = '/health';
  static const String generateLayout     = '/api/generate-layout';
  static const String recommendMaterials = '/api/recommend-materials';
  static const String estimateCost       = '/api/estimate-cost';
  static const String chatbot            = '/api/chatbot';
  static const String exportPdf          = '/api/export-pdf';
  static const String livePrices         = '/api/prices';
  static const String interiorDesign     = '/api/interior-design'; // ← NEW

  // ── Timeouts ──────────────────────────────────────────────────────────────
  // Increased because:
  // - Gemini LLM takes 5-15 seconds
  // - Hugging Face image takes 20-40 seconds
  // - Layout generation takes 5-10 seconds
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout    = Duration(seconds: 120);
  static const Duration pdfTimeout        = Duration(seconds: 120);

  // ── Budget normalizer ─────────────────────────────────────────────────────
  static const Map<String, String> budgetKeyMap = {
    'economy':  'economy',
    'standard': 'standard',
    'premium':  'luxury',
    'luxury':   'luxury',
    'low':      'economy',
    'medium':   'standard',
    'high':     'luxury',
  };
  static String normalizeBudget(String key) =>
      budgetKeyMap[key.toLowerCase()] ?? 'standard';
}