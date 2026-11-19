// lib/presentation/viewmodels/interior_viewmodel.dart
// v4 — passes budget and city to backend, handles full Gemini response

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../data/models/interior_design_model.dart';

class InteriorViewModel extends ChangeNotifier {
  bool                _isLoading    = false;
  String?             _errorMessage;
  InteriorDesignModel? _design;
  int                 _selTheme     = 0;

  bool                get isLoading     => _isLoading;
  String?             get errorMessage  => _errorMessage;
  InteriorDesignModel? get design       => _design;
  int                 get selTheme      => _selTheme;

  void setTheme(int i) { _selTheme = i; notifyListeners(); }

  Future<void> fetchInteriorDesign({
    required String roomType,
    required double roomSize,
    String stylePreference = 'modern',
    String budget          = 'standard',
    String city            = 'lahore',
    bool   generateImage   = true,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    _selTheme     = 0;
    notifyListeners();

    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.interiorDesign}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'room_type':        roomType,
          'room_size':        roomSize,
          'style_preference': stylePreference,
          'budget':           budget,
          'city':             city,
          'generate_image':   generateImage,
        }),
      ).timeout(
        const Duration(seconds: 120),
        onTimeout: () => throw Exception(
            'Request timed out. Hugging Face may be cold-starting. Try again.'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          _design = InteriorDesignModel.fromJson(json);
        } else {
          throw Exception(json['error'] ?? 'Unknown error from server');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Options for UI dropdowns
  static const roomOptions = [
    'bedroom', 'living_room', 'kitchen', 'bathroom',
    'drawing_room', 'dining_room',
  ];
  static const roomLabels = [
    'Bedroom', 'Living Room', 'Kitchen', 'Bathroom',
    'Drawing Room', 'Dining Room',
  ];
  static const styleOptions  = ['modern', 'traditional', 'minimalist', 'luxury'];
  static const styleLabels   = ['Modern', 'Traditional', 'Minimalist', 'Luxury'];
  static const budgetOptions  = ['economy', 'standard', 'luxury'];
  static const budgetLabels   = ['Economy', 'Standard', 'Luxury'];
  static const cityOptions    = ['lahore', 'karachi', 'islamabad', 'rawalpindi', 'faisalabad'];
  static const cityLabels     = ['Lahore', 'Karachi', 'Islamabad', 'Rawalpindi', 'Faisalabad'];
}