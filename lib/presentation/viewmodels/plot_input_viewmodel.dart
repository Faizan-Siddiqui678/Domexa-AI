import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/plot_input_model.dart';
import '../../data/models/project_model.dart';

/// The *current project*: plot form + city + budget + names.
/// Every other screen reads this, so inputs are entered once (recognition over recall).
class PlotInputViewModel extends ChangeNotifier {
  PlotInputModel plot = const PlotInputModel();
  String city = 'lahore';
  String budget = 'standard';
  String projectName = 'My House Plan';
  String ownerName = '';

  void _set(PlotInputModel p) {
    plot = p;
    notifyListeners();
  }

  void setPlotArea(double v) => _set(plot.copyWith(plotArea: v));
  void setFloors(int v) => _set(plot.copyWith(numFloors: v.clamp(AppConstants.minFloors, AppConstants.maxFloors).toInt()));
  void setBedrooms(int v) => _set(plot.copyWith(bedrooms: v.clamp(AppConstants.minBedrooms, AppConstants.maxBedrooms).toInt()));
  void setBathrooms(int v) => _set(plot.copyWith(bathrooms: v.clamp(AppConstants.minBathrooms, AppConstants.maxBathrooms).toInt()));
  void setKitchens(int v) => _set(plot.copyWith(kitchen: v.clamp(AppConstants.minKitchens, AppConstants.maxKitchens).toInt()));
  void setStyle(String v) => _set(plot.copyWith(houseStyle: v));
  void setExtra(String key, bool v) => _set(plot.withExtra(key, v));

  void setCity(String v) {
    city = v;
    notifyListeners();
  }

  void setBudget(String v) {
    budget = v;
    notifyListeners();
  }

  void setNames({String? project, String? owner}) {
    if (project != null) projectName = project;
    if (owner != null) ownerName = owner;
    notifyListeners();
  }

  /// Undoable by the user: resets everything to the defaults.
  void reset() {
    plot = const PlotInputModel();
    city = 'lahore';
    budget = 'standard';
    projectName = 'My House Plan';
    notifyListeners();
  }

  void load(ProjectModel p) {
    plot = p.plot;
    city = p.city;
    budget = p.budget;
    projectName = p.name;
    notifyListeners();
  }

  ProjectModel toProject({double? totalCost}) => ProjectModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: projectName.trim().isEmpty ? 'My House Plan' : projectName.trim(),
    city: city,
    budget: budget,
    createdAt: DateTime.now().toIso8601String(),
    plot: plot,
    totalCost: totalCost,
  );
}