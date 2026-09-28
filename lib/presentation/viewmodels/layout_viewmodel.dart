import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/models/layout_model.dart';

class LayoutViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  LayoutModel? _generatedLayout;

  // Input parameters
  double _plotArea = 2000;
  int _numFloors = 2;
  int _bedrooms = 3;
  int _bathrooms = 2;
  int _kitchen = 1;
  bool _hasDrawingRoom = true;
  bool _hasDiningRoom = true;
  bool _hasGarage = false;
  bool _hasBasement = false;
  bool _hasGallery = true;
  bool _hasOpenArea = true;
  bool _hasServantQuarter = false;
  bool _hasStoreRoom = false;
  String _houseStyle = 'modern';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LayoutModel? get generatedLayout => _generatedLayout;

  // Getters for input values
  double get plotArea => _plotArea;
  int get numFloors => _numFloors;
  int get bedrooms => _bedrooms;
  int get bathrooms => _bathrooms;
  int get kitchen => _kitchen;
  bool get hasDrawingRoom => _hasDrawingRoom;
  bool get hasDiningRoom => _hasDiningRoom;
  bool get hasGarage => _hasGarage;
  bool get hasBasement => _hasBasement;
  bool get hasGallery => _hasGallery;
  bool get hasOpenArea => _hasOpenArea;
  bool get hasServantQuarter => _hasServantQuarter;
  bool get hasStoreRoom => _hasStoreRoom;
  String get houseStyle => _houseStyle;

  // Setters for input values
  void setPlotArea(double value) {
    _plotArea = value;
    notifyListeners();
  }

  void setNumFloors(int value) {
    _numFloors = value;
    notifyListeners();
  }

  void setBedrooms(int value) {
    _bedrooms = value;
    notifyListeners();
  }

  void setBathrooms(int value) {
    _bathrooms = value;
    notifyListeners();
  }

  void setKitchen(int value) {
    _kitchen = value;
    notifyListeners();
  }

  void setDrawingRoom(bool value) {
    _hasDrawingRoom = value;
    notifyListeners();
  }

  void setDiningRoom(bool value) {
    _hasDiningRoom = value;
    notifyListeners();
  }

  void setGarage(bool value) {
    _hasGarage = value;
    notifyListeners();
  }

  void setBasement(bool value) {
    _hasBasement = value;
    notifyListeners();
  }

  void setGallery(bool value) {
    _hasGallery = value;
    notifyListeners();
  }

  void setOpenArea(bool value) {
    _hasOpenArea = value;
    notifyListeners();
  }

  void setServantQuarter(bool value) {
    _hasServantQuarter = value;
    notifyListeners();
  }

  void setStoreRoom(bool value) {
    _hasStoreRoom = value;
    notifyListeners();
  }

  void setHouseStyle(String value) {
    _houseStyle = value;
    notifyListeners();
  }

  /// Generate layout using the backend API
  Future<void> generateLayout({
    required double plotArea,
    required int numFloors,
    required int bedrooms,
    required int bathrooms,
    required int kitchen,
    required bool drawingRoom,
    required bool diningRoom,
    required bool garage,
    required bool basement,
    required bool gallery,
    required bool openArea,
    required bool servantQuarter,
    required bool storeRoom,
    required String houseStyle,
  }) async {
    // Update local values
    _plotArea = plotArea;
    _numFloors = numFloors;
    _bedrooms = bedrooms;
    _bathrooms = bathrooms;
    _kitchen = kitchen;
    _hasDrawingRoom = drawingRoom;
    _hasDiningRoom = diningRoom;
    _hasGarage = garage;
    _hasBasement = basement;
    _hasGallery = gallery;
    _hasOpenArea = openArea;
    _hasServantQuarter = servantQuarter;
    _hasStoreRoom = storeRoom;
    _houseStyle = houseStyle;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Replace with your actual backend URL
      const baseUrl = 'http://localhost:8000';

      final requestBody = {
        'plot_area': plotArea,
        'num_floors': numFloors,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'kitchen': kitchen,
        'drawing_room': drawingRoom,
        'dining_room': diningRoom,
        'garage': garage,
        'basement': basement,
        'gallery': gallery,
        'open_area': openArea,
        'servant_quarter': servantQuarter,
        'store_room': storeRoom,
        'house_style': houseStyle,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/generate-layout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['layout_data'] != null) {
          _generatedLayout = LayoutModel.fromJson(data['layout_data']);
          _isLoading = false;
          notifyListeners();
        } else {
          _errorMessage = data['message'] ?? 'Failed to generate layout';
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the generated layout
  void clearLayout() {
    _generatedLayout = null;
    notifyListeners();
  }

  /// Reset all input values to defaults
  void reset() {
    _plotArea = 2000;
    _numFloors = 2;
    _bedrooms = 3;
    _bathrooms = 2;
    _kitchen = 1;
    _hasDrawingRoom = true;
    _hasDiningRoom = true;
    _hasGarage = false;
    _hasBasement = false;
    _hasGallery = true;
    _hasOpenArea = true;
    _hasServantQuarter = false;
    _hasStoreRoom = false;
    _houseStyle = 'modern';
    _generatedLayout = null;
    _errorMessage = null;
    notifyListeners();
  }
}