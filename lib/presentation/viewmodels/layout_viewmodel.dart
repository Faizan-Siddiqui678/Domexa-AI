import '../../data/models/layout_model.dart';
import '../../data/models/plot_input_model.dart';
import '../../data/services/api_service.dart';
import 'base_viewmodel.dart';

class LayoutViewModel extends BaseViewModel {
  LayoutViewModel(this._api);
  final ApiService _api;

  LayoutModel? layout;
  PlotInputModel? generatedFor;
  int floorIndex = 0;

  FloorModel? get currentFloor =>
      (layout == null || layout!.floors.isEmpty) ? null : layout!.floors[floorIndex.clamp(0, layout!.floors.length - 1).toInt()];

  void selectFloor(int i) {
    floorIndex = i;
    notifyListeners();
  }

  /// Ignores duplicate taps while a request is running (error prevention).
  Future<void> generate(PlotInputModel plot, {bool force = false}) async {
    if (isLoading) return;
    if (!force && layout != null && generatedFor == plot) return;
    await run(() => _api.generateLayout(plot), (l) {
      layout = l;
      generatedFor = plot;
      floorIndex = 0;
    });
  }
}