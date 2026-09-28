import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/plot_input_model.dart';
import '../models/layout_model.dart';
import '../models/material_model.dart';
import '../models/cost_estimation_model.dart';
import '../models/chat_message_model.dart';

class ApiService {
  final http.Client _client;
  final String baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl  = baseUrl ?? ApiConstants.baseUrl;

  // ─── Error handler ────────────────────────────────────────
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      Map<String, dynamic> body = {};
      try { body = json.decode(response.body); } catch (_) {}
      throw ApiException(
        statusCode: response.statusCode,
        message: body['detail']?.toString()
            ?? 'Server error ${response.statusCode}',
      );
    }
  }

  // ─── Health check ─────────────────────────────────────────
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final r = await _client
          .get(Uri.parse('$baseUrl${ApiConstants.healthCheck}'))
          .timeout(ApiConstants.connectionTimeout);
      _handleError(r);
      return json.decode(r.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Cannot connect to server.\n'
            '• Run: python main.py on your PC\n'
            '• Phone and PC must be on the same WiFi\n'
            '• Update _pcIpAddress in api_constants.dart',
      );
    }
  }

  // ─── Layout ───────────────────────────────────────────────
  Future<LayoutModel> generateLayout(PlotInputModel input) async {
    try {
      final r = await _client
          .post(
        Uri.parse('$baseUrl${ApiConstants.generateLayout}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(input.toJson()),
      )
          .timeout(ApiConstants.receiveTimeout);
      _handleError(r);
      final data = json.decode(r.body) as Map<String, dynamic>;
      if (data['success'] == true && data['layout_data'] != null) {
        return LayoutModel.fromJson(data['layout_data'] as Map<String, dynamic>);
      }
      throw ApiException(statusCode: 500,
          message: data['message']?.toString() ?? 'Layout generation failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Layout failed: $e');
    }
  }

  // ─── Materials ────────────────────────────────────────────
  Future<MaterialModel> recommendMaterials({
    required double plotArea,
    required int    numFloors,
    required String budgetCategory,
    String city = 'lahore',
  }) async {
    try {
      final r = await _client
          .post(
        Uri.parse('$baseUrl${ApiConstants.recommendMaterials}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'plot_area':    plotArea,
          'num_floors':   numFloors,
          'budget_range': ApiConstants.normalizeBudget(budgetCategory),
          'city':         city,
        }),
      )
          .timeout(ApiConstants.receiveTimeout);
      _handleError(r);
      final data = json.decode(r.body) as Map<String, dynamic>;
      if (data['success'] == true) return MaterialModel.fromJson(data);
      throw ApiException(statusCode: 500,
          message: data['message']?.toString() ?? 'Material recommendation failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Materials failed: $e');
    }
  }

  // ─── Cost ─────────────────────────────────────────────────
  Future<CostEstimationModel> estimateCost({
    required double plotArea,
    required int    numFloors,
    required double coveredArea,
    String budgetCategory  = 'medium',
    String city            = 'lahore',
    bool   includeBasement = false,
    bool   includeGarage   = false,
  }) async {
    try {
      final r = await _client
          .post(
        Uri.parse('$baseUrl${ApiConstants.estimateCost}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'plot_area':        plotArea,
          'num_floors':       numFloors,
          'budget_range':     ApiConstants.normalizeBudget(budgetCategory),
          'city':             city,
          'include_basement': includeBasement,
          'include_garage':   includeGarage,
        }),
      )
          .timeout(ApiConstants.receiveTimeout);
      _handleError(r);
      final data = json.decode(r.body) as Map<String, dynamic>;
      if (data['success'] == true) return CostEstimationModel.fromJson(data);
      throw ApiException(statusCode: 500,
          message: data['message']?.toString() ?? 'Cost estimation failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Cost failed: $e');
    }
  }

  // ─── Chatbot ──────────────────────────────────────────────
  Future<String> sendChatMessage({
    required String            message,
    required List<ChatMessage> conversationHistory,
    String city = 'lahore',
  }) async {
    try {
      final r = await _client
          .post(
        Uri.parse('$baseUrl${ApiConstants.chatbot}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'city':    city,
          'conversation_history': conversationHistory
              .map((m) => {'role': m.role, 'content': m.content})
              .toList(),
        }),
      )
          .timeout(ApiConstants.receiveTimeout);
      _handleError(r);
      final data = json.decode(r.body) as Map<String, dynamic>;
      if (data['success'] == true && data['response'] != null) {
        return data['response'] as String;
      }
      throw ApiException(statusCode: 500, message: 'No response from chatbot');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Chat failed: $e');
    }
  }

  // ─── PDF Export ───────────────────────────────────────────
  Future<Map<String, dynamic>> exportPdf({
    required String projectName,
    required String ownerName,
    required double plotArea,
    required int    numFloors,
    required int    bedrooms,
    required int    bathrooms,
    required String budgetRange,
    required double totalCost,
    required double greyStructureCost,
    required double finishingCost,
    required double laborCost,
  }) async {
    try {
      final r = await _client
          .post(
        Uri.parse('$baseUrl${ApiConstants.exportPdf}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'project_name':        projectName,
          'owner_name':          ownerName,
          'plot_area':           plotArea,
          'num_floors':          numFloors,
          'bedrooms':            bedrooms,
          'bathrooms':           bathrooms,
          'budget_range':        ApiConstants.normalizeBudget(budgetRange),
          'total_cost':          totalCost,
          'grey_structure_cost': greyStructureCost,
          'finishing_cost':      finishingCost,
          'labor_cost':          laborCost,
        }),
      )
          .timeout(ApiConstants.pdfTimeout);
      _handleError(r);
      return json.decode(r.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'PDF export failed: $e');
    }
  }

  void dispose() => _client.close();
}

// ─── Exception ────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int    statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}
