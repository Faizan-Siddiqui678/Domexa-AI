import '../../data/models/material_model.dart';
import '../../data/models/plot_input_model.dart';
import '../../data/services/api_service.dart';
import 'base_viewmodel.dart';

class MaterialViewModel extends BaseViewModel {
  MaterialViewModel(this._api);
  final ApiService _api;

  MaterialResult? result;
  String? _key;

  Future<void> load(PlotInputModel plot, String budget, String city, {bool force = false}) async {
    final key = '${plot.plotArea}|${plot.numFloors}|$budget|$city';
    if (!force && key == _key && result != null) return;
    _key = key;
    await run(
          () => _api.recommendMaterials(plotArea: plot.plotArea, floors: plot.numFloors, budget: budget, city: city),
          (r) => result = r,
    );
    if (hasError) _key = null; // allow retry
  }
}