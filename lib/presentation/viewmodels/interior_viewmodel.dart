import '../../core/constants/app_constants.dart';
import '../../data/models/interior_design_model.dart';
import '../../data/services/api_service.dart';
import 'base_viewmodel.dart';

class InteriorViewModel extends BaseViewModel {
  InteriorViewModel(this._api);
  final ApiService _api;

  String roomType = 'bedroom';
  String style = 'modern';
  String budget = 'standard';
  String city = 'lahore';
  double roomSize = 200;
  bool generateImage = true;
  InteriorDesign? design;

  void update({String? roomType, String? style, String? budget, String? city, double? roomSize, bool? generateImage}) {
    this.roomType = roomType ?? this.roomType;
    this.style = style ?? this.style;
    this.budget = budget ?? this.budget;
    this.city = city ?? this.city;
    this.roomSize = roomSize ?? this.roomSize;
    this.generateImage = generateImage ?? this.generateImage;
    notifyListeners();
  }

  /// Start from the project's own settings (project budget "premium" == interior "luxury").
  void syncWithProject({required String projectCity, required String projectBudget, required String houseStyle}) {
    city = AppConstants.interiorCities.contains(projectCity) ? projectCity : 'lahore';
    budget = projectBudget == 'premium' ? 'luxury' : projectBudget;
    style = houseStyle;
    notifyListeners();
  }

  /// Used by "Interior ideas" on a room of the generated floor plan.
  void prefillFromRoom(String layoutRoomType, double areaSqft) {
    final t = AppConstants.interiorTypeForRoom(layoutRoomType);
    if (t != null) roomType = t;
    roomSize = areaSqft.clamp(AppConstants.minRoomSize, AppConstants.maxRoomSize).toDouble().roundToDouble();
    design = null;
    setIdle();
    notifyListeners();
  }

  Future<void> generate() async {
    if (isLoading) return;
    await run(
          () => _api.interiorDesign(
          roomType: roomType, roomSize: roomSize, style: style, budget: budget, city: city, generateImage: generateImage),
          (d) => design = d,
    );
  }
}