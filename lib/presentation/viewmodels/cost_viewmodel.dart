import '../../core/constants/app_constants.dart';
import '../../data/models/cost_estimation_model.dart';
import '../../data/models/plot_input_model.dart';
import '../../data/services/api_service.dart';
import 'base_viewmodel.dart';

/// Backend returns one budget per call, so the three comparison cards are filled
/// by up to three calls: the selected budget first, the others afterwards.
class CostViewModel extends BaseViewModel {
  CostViewModel(this._api);
  final ApiService _api;

  final Map<String, CostResult> results = {};
  final Set<String> pending = {};
  final Set<String> failed = {}; // not retried automatically; the user taps the card
  String? _key;

  String _k(PlotInputModel p, String city) => '${p.plotArea}|${p.numFloors}|${p.basement}|${p.garage}|$city';

  /// Safe to call from build(): does nothing (and does not notify) when nothing changed.
  Future<void> load(PlotInputModel plot, String city, String budget, {bool force = false, bool userAction = false}) async {
    final key = _k(plot, city);
    if (force || key != _key) {
      results.clear();
      pending.clear();
      failed.clear();
      _key = key;
    }
    if (userAction) failed.remove(budget);

    if (results[budget] == null && !failed.contains(budget) && !isLoading) {
      await run(() => _api.estimateCost(plot: plot, budget: budget, city: city), (r) => results[budget] = r);
      if (hasError) {
        failed.add(budget);
        _key = null;
        return;
      }
    }
    _fillOthers(plot, city, key);
  }

  Future<void> _fillOthers(PlotInputModel plot, String city, String key) async {
    for (final b in AppConstants.budgetKeys) {
      if (key != _key) return;
      if (results[b] != null || pending.contains(b) || failed.contains(b)) continue;
      pending.add(b);
      notifyListeners();
      try {
        final r = await _api.estimateCost(plot: plot, budget: b, city: city);
        if (key != _key) return; // inputs changed meanwhile
        results[b] = r;
      } catch (_) {
        failed.add(b); // the card stays empty and offers "Tap to retry"
      } finally {
        pending.remove(b);
        notifyListeners();
      }
    }
  }

  /// Returns the estimate for [budget], fetching it if needed (used by export too).
  Future<CostResult> ensure(PlotInputModel plot, String city, String budget) async {
    if (_key == _k(plot, city) && results[budget] != null) return results[budget]!;
    final r = await _api.estimateCost(plot: plot, budget: budget, city: city);
    if (_key == _k(plot, city)) results[budget] = r;
    return r;
  }
}