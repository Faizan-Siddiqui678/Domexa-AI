import 'package:flutter/material.dart';
import '../../data/models/material_model.dart';
import '../../data/services/api_service.dart';

class MaterialViewModel extends ChangeNotifier {
  final ApiService _apiService;
  MaterialViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  MaterialModel? _materialData;
  bool    _isLoading              = false;
  String? _errorMessage;
  String  _selectedBudgetCategory = 'medium';
  String  _selectedCity           = 'lahore';

  MaterialModel? get materialData            => _materialData;
  bool    get isLoading                      => _isLoading;
  String? get errorMessage                   => _errorMessage;
  String  get selectedBudgetCategory         => _selectedBudgetCategory;
  String  get selectedCity                   => _selectedCity;

  void setBudgetCategory(String v) { _selectedBudgetCategory = v; notifyListeners(); }
  void setCity(String v)           { _selectedCity = v.toLowerCase(); notifyListeners(); }

  Future<bool> fetchMaterials({
    required double plotArea,
    required int    numFloors,
    String? budgetCategory,
    String? city,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    if (budgetCategory != null) _selectedBudgetCategory = budgetCategory;
    if (city != null)           _selectedCity           = city.toLowerCase();
    notifyListeners();
    try {
      _materialData = await _apiService.recommendMaterials(
        plotArea:       plotArea,
        numFloors:      numFloors,
        budgetCategory: _selectedBudgetCategory,
        city:           _selectedCity,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading    = false;
      _errorMessage = e is ApiException
          ? e.message
          : 'Could not connect. Make sure python main.py is running '
          'and your phone is on the same WiFi as your PC.';
      notifyListeners();
      return false;
    }
  }

  List<MaterialItem> getMaterialsByCategory(String category) {
    if (_materialData == null) return [];
    return _materialData!.materials
        .firstWhere((c) => c.category == category,
        orElse: () => MaterialCategory(category: category, items: []))
        .items;
  }

  double getCategoryCost(String category) {
    if (_materialData == null) return 0.0;
    return _materialData!.materials
        .firstWhere((c) => c.category == category,
        orElse: () => MaterialCategory(category: category, items: []))
        .totalCost;
  }

  List<String> getCategoryNames() =>
      _materialData?.materials.map((c) => c.category).toList() ?? [];

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
