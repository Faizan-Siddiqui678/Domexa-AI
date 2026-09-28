import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/models/layout_model.dart';

class PlotInputViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  LayoutModel? _generatedLayout;

  double _plotWidth = 50;
  double _plotLength = 65;
  double _plotArea = 2250;
  int _numFloors = 2;
  int _bedrooms = 4;
  int _bathrooms = 3;
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

  final List<String> _availableStyles = ['modern', 'traditional', 'luxury', 'minimalist'];
  final Map<String, double> _marlaPresets = {
    '5 Marla':  1125,
    '8 Marla':  1800,
    '10 Marla': 2250,
    '1 Kanal':  4500,
    '2 Kanal':  9000,
  };
  String _selectedPreset = '10 Marla';

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LayoutModel? get generatedLayout => _generatedLayout;
  double get plotWidth => _plotWidth;
  double get plotLength => _plotLength;
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
  List<String> get availableStyles => _availableStyles;
  Map<String, double> get marlaPresets => _marlaPresets;
  String get selectedPreset => _selectedPreset;
  double get builtArea => _plotArea * 0.7 * _numFloors;
  double get plotMarla => _plotArea / 225;
  double get plotKanal => _plotArea / 4500;

  // ── Setters ────────────────────────────────────────────────────────────────
  void setPlotArea(double value) {
    _plotArea = value;
    _updatePlotDimensions();
    _selectedPreset = _findPreset(value);
    notifyListeners();
  }

  void setNumFloors(int value)        { _numFloors = value;          notifyListeners(); }
  void setBedrooms(int value)         { _bedrooms = value;           notifyListeners(); }
  void setBathrooms(int value)        { _bathrooms = value;          notifyListeners(); }
  void setKitchen(int value)          { _kitchen = value;            notifyListeners(); }
  void setDrawingRoom(bool value)     { _hasDrawingRoom = value;     notifyListeners(); }
  void setDiningRoom(bool value)      { _hasDiningRoom = value;      notifyListeners(); }
  void setGarage(bool value)         { _hasGarage = value;          notifyListeners(); }
  void setBasement(bool value)        { _hasBasement = value;        notifyListeners(); }
  void setGallery(bool value)         { _hasGallery = value;         notifyListeners(); }
  void setOpenArea(bool value)        { _hasOpenArea = value;        notifyListeners(); }
  void setServantQuarter(bool value)  { _hasServantQuarter = value;  notifyListeners(); }
  void setStoreRoom(bool value)       { _hasStoreRoom = value;       notifyListeners(); }
  void setHouseStyle(String value)    { _houseStyle = value;         notifyListeners(); }

  void setSelectedPreset(String preset) {
    _selectedPreset = preset;
    _plotArea = _marlaPresets[preset]!;
    _updatePlotDimensions();
    notifyListeners();
  }

  // ── Internal helpers ───────────────────────────────────────────────────────
  void _updatePlotDimensions() {
    const double ratio = 1.3;
    _plotWidth  = math.sqrt(_plotArea / ratio);
    _plotLength = _plotWidth * ratio;
  }

  String _findPreset(double area) {
    for (final entry in _marlaPresets.entries) {
      if ((entry.value - area).abs() < 100) return entry.key;
    }
    return 'Custom';
  }

  /// ✅ Fix: resolve the correct host for each platform so the API call
  /// actually reaches the backend whether you're on a physical device,
  /// Android emulator, or iOS simulator.
  ///
  /// - Android emulator → 10.0.2.2  (loopback alias for the host machine)
  /// - iOS simulator    → 127.0.0.1 (shares the Mac's network stack)
  /// - Physical device  → replace with your machine's LAN IP or deployed URL
  String get _baseUrl {
    // TODO: replace with your deployed server URL for production builds.
    // e.g. 'https://api.yourdomain.com'
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      if (Platform.isIOS)     return 'http://127.0.0.1:8000';
    } catch (_) {
      // Platform not available (e.g. web) — fall through
    }
    return 'http://localhost:8000';
  }

  // ── API call ───────────────────────────────────────────────────────────────
  Future<void> generateLayout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate-layout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'plot_area':       _plotArea,
          'num_floors':      _numFloors,
          'bedrooms':        _bedrooms,
          'bathrooms':       _bathrooms,
          'kitchen':         _kitchen,
          'drawing_room':    _hasDrawingRoom,
          'dining_room':     _hasDiningRoom,
          'garage':          _hasGarage,
          'basement':        _hasBasement,
          'gallery':         _hasGallery,
          'open_area':       _hasOpenArea,
          'servant_quarter': _hasServantQuarter,
          'store_room':      _hasStoreRoom,
          'house_style':     _houseStyle,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['layout_data'] != null) {
          _generatedLayout = LayoutModel.fromJson(
              data['layout_data'] as Map<String, dynamic>);
          _errorMessage = null;
        } else {
          _errorMessage = data['message'] as String? ?? 'Failed to generate layout';
          _generatedLayout = null;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _generatedLayout = null;
      }
    } on http.ClientException catch (e) {
      _errorMessage = 'Network error: ${e.message}';
      _generatedLayout = null;
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _generatedLayout = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void clearLayout() {
    _generatedLayout = null;
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _plotArea        = 2250;
    _numFloors       = 2;
    _bedrooms        = 4;
    _bathrooms       = 3;
    _kitchen         = 1;
    _hasDrawingRoom  = true;
    _hasDiningRoom   = true;
    _hasGarage       = false;
    _hasBasement     = false;
    _hasGallery      = true;
    _hasOpenArea     = true;
    _hasServantQuarter = false;
    _hasStoreRoom    = false;
    _houseStyle      = 'modern';
    _selectedPreset  = '10 Marla';
    _generatedLayout = null;
    _errorMessage    = null;
    _updatePlotDimensions();
    notifyListeners();
  }
}