// lib/presentation/viewmodels/interior_viewmodel.dart
// Updated: now calls real backend instead of building data locally

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../data/models/interior_design_model.dart';

class InteriorViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  InteriorDesignModel? _interiorDesign;
  int _selectedThemeIndex = 0;

  bool get isLoading           => _isLoading;
  String? get errorMessage     => _errorMessage;
  InteriorDesignModel? get interiorDesign => _interiorDesign;
  int get selectedThemeIndex   => _selectedThemeIndex;

  void setSelectedTheme(int index) {
    _selectedThemeIndex = index;
    notifyListeners();
  }

  /// Called by interior_screen.dart — now hits real backend
  Future<void> fetchInteriorDesign({
    required String roomType,
    required double roomSize,
    String stylePreference = 'modern',
    bool generateImage = true,   // pass false to skip DALL-E (instant response)
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedThemeIndex = 0;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/interior-design');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'room_type':        roomType,
          'room_size':        roomSize,
          'style_preference': stylePreference,
          'generate_image':   generateImage,
        }),
      ).timeout(
        // DALL-E can take up to 30s — increase timeout
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timed out. Try again.'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _interiorDesign = InteriorDesignModel.fromJson(json);
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  List<String> get roomOptions => [
    'bedroom',
    'living_room',
    'drawing_room',
    'kitchen',
    'bathroom',
    'dining_room',
  ];

  List<String> get roomLabels => [
    'Bedroom',
    'Living Room',
    'Drawing Room',
    'Kitchen',
    'Bathroom',
    'Dining Room',
  ];

  List<String> get styleOptions => [
    'modern',
    'traditional',
    'minimalist',
    'luxury',
  ];

  @override
  void dispose() {
    super.dispose();
  }
}