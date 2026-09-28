import 'package:flutter/material.dart';
import '../../data/models/cost_estimation_model.dart';
import '../../data/services/api_service.dart';

class CostViewModel extends ChangeNotifier {
  final ApiService _apiService;
  CostViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  CostEstimationModel? _costEstimation;
  bool    _isLoading    = false;
  String? _errorMessage;

  CostEstimationModel? get costEstimation => _costEstimation;
  bool    get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchCostEstimation({
    required double plotArea,
    required int    numFloors,
    required double coveredArea,
    String budgetCategory  = 'medium',
    String city            = 'lahore',
    bool   includeBasement = false,
    bool   includeGarage   = false,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _costEstimation = await _apiService.estimateCost(
        plotArea:        plotArea,
        numFloors:       numFloors,
        coveredArea:     coveredArea,
        budgetCategory:  budgetCategory,
        city:            city,
        includeBasement: includeBasement,
        includeGarage:   includeGarage,
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

  String formatCurrency(double amount) =>
      'PKR ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
      )}';

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
