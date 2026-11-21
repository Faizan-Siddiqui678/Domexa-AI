import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/json_utils.dart';
import '../models/chat_message_model.dart';
import '../models/cost_estimation_model.dart';
import '../models/export_model.dart';
import '../models/interior_design_model.dart';
import '../models/layout_model.dart';
import '../models/material_model.dart';
import '../models/plot_input_model.dart';
import '../models/price_model.dart';
import 'settings_service.dart';

/// Every failure reaches the UI as plain language + whether retrying makes sense.
class ApiException implements Exception {
  final String message;
  final bool retryable;
  const ApiException(this.message, {this.retryable = true});
  @override
  String toString() => message;
}

class ApiService {
  ApiService(this._settings);
  final SettingsService _settings;
  final http.Client _client = http.Client();

  String get baseUrl => _settings.baseUrl;

  Uri _uri(String path, [Map<String, String>? q]) => Uri.parse('$baseUrl$path').replace(queryParameters: q);

  Future<Map<String, dynamic>> _get(String path, {Map<String, String>? query, Duration? timeout}) =>
      _send(() => _client.get(_uri(path, query)), timeout ?? ApiConstants.shortTimeout);

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, Duration timeout) => _send(
          () => _client.post(_uri(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)),
      timeout);

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() call, Duration timeout) async {
    try {
      final res = await call().timeout(timeout);
      dynamic body;
      try {
        body = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {}
      if (res.statusCode >= 200 && res.statusCode < 300 && body is Map) return Map<String, dynamic>.from(body);
      if (res.statusCode == 422) {
        throw const ApiException('The server did not accept some of the values. Please review your inputs.', retryable: false);
      }
      final detail = body is Map ? (body['detail'] ?? body['error']) : null;
      throw ApiException(
          'The server hit a problem (code ${res.statusCode}).${detail != null ? ' $detail' : ''} Please try again.');
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('This is taking longer than expected. Check your connection and try again.');
    } on SocketException {
      throw ApiException('Cannot reach the Domexa server at $baseUrl. Make sure it is running and the address in Profile is correct.');
    } on http.ClientException {
      throw ApiException('Cannot reach the Domexa server at $baseUrl. Make sure it is running and the address in Profile is correct.');
    } on FormatException {
      throw const ApiException('The server sent an unreadable reply. Please try again.');
    }
  }

  // ---------------------------------------------------------------- endpoints

  Future<Map<String, dynamic>> health() => _get(ApiConstants.health);

  Future<PriceModel> prices(String city) async =>
      PriceModel.fromJson(await _get(ApiConstants.prices, query: {'city': city}, timeout: ApiConstants.aiTimeout));

  Future<LayoutModel> generateLayout(PlotInputModel plot) async {
    final r = await _post(ApiConstants.layout, plot.toJson(), ApiConstants.aiTimeout);
    final layout = LayoutModel.fromResponse(r);
    if (layout.floors.isEmpty) throw const ApiException('The server returned an empty layout. Please try again.');
    return layout;
  }

  Future<MaterialResult> recommendMaterials({
    required double plotArea, required int floors, required String budget, required String city,
  }) async =>
      MaterialResult.fromJson(await _post(ApiConstants.materials,
          {'plot_area': plotArea, 'num_floors': floors, 'budget_range': budget, 'city': city}, ApiConstants.aiTimeout));

  Future<CostResult> estimateCost({
    required PlotInputModel plot, required String budget, required String city,
  }) async =>
      CostResult.fromJson(await _post(
          ApiConstants.cost,
          {
            'plot_area': plot.plotArea, 'num_floors': plot.numFloors, 'budget_range': budget, 'city': city,
            'include_basement': plot.basement, 'include_garage': plot.garage,
          },
          ApiConstants.aiTimeout));

  /// Note: this endpoint answers HTTP 200 with {success:false, error} on failure.
  Future<InteriorDesign> interiorDesign({
    required String roomType, required double roomSize, required String style,
    required String budget, required String city, required bool generateImage,
  }) async {
    final r = await _post(
        ApiConstants.interior,
        {
          'room_type': roomType, 'room_size': roomSize, 'style_preference': style,
          'budget': budget, 'city': city, 'generate_image': generateImage,
        },
        generateImage ? ApiConstants.imageTimeout : ApiConstants.aiTimeout);
    if (r['success'] != true || r['data'] == null) {
      throw ApiException(js(r['error'], 'The design could not be generated. Please try again.'));
    }
    return InteriorDesign.fromJson(jmap(r['data']));
  }

  /// [history] must NOT contain [message]; the backend appends it itself.
  Future<String> chat({required String message, required List<ChatMessageModel> history, required String city}) async {
    final r = await _post(
        ApiConstants.chatbot,
        {'message': message, 'conversation_history': history.map((m) => m.toApi()).toList(), 'city': city},
        ApiConstants.aiTimeout);
    final text = js(r['response']).trim();
    if (text.isEmpty) throw const ApiException('The assistant sent an empty answer. Please ask again.');
    return text;
  }

  Future<ExportResult> exportPdf({
    required String projectName, required String ownerName, required PlotInputModel plot, required CostResult cost,
  }) async {
    final r = await _post(
        ApiConstants.exportPdf,
        {
          'project_name': projectName.trim().isEmpty ? 'My House Plan' : projectName.trim(),
          'owner_name': ownerName.trim(),
          'plot_area': plot.plotArea, 'num_floors': plot.numFloors,
          'bedrooms': plot.bedrooms, 'bathrooms': plot.bathrooms,
          'budget_range': cost.budgetRange, 'total_cost': cost.total,
          'grey_structure_cost': cost.grey, 'finishing_cost': cost.finishing, 'labor_cost': cost.labor,
        },
        ApiConstants.aiTimeout);
    final Uint8List bytes;
    try {
      bytes = base64Decode(js(r['pdf_base64']));
    } on FormatException {
      throw const ApiException('The PDF came back damaged. Please try again.');
    }
    return ExportResult(filename: js(r['filename'], 'Domexa_Report.pdf'), bytes: bytes);
  }
}