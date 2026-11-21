import '../../data/models/price_model.dart';
import '../../data/services/api_service.dart';
import 'base_viewmodel.dart';

/// Live material prices (GET /api/prices) shown on Home.
class PricesViewModel extends BaseViewModel {
  PricesViewModel(this._api);
  final ApiService _api;
  PriceModel? prices;
  String? _city;

  Future<void> load(String city, {bool force = false}) async {
    if (!force && _city == city && prices != null) return;
    _city = city;
    await run(() => _api.prices(city), (p) => prices = p);
  }
}