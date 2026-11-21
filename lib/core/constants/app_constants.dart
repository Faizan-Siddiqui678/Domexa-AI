/// Limits mirror app/models/requests.py so invalid input is prevented
/// on the device instead of failing on the server (HCI: error prevention).
class PlotPreset {
  final String label;
  final double sqft;
  const PlotPreset(this.label, this.sqft);
}

class AppConstants {
  static const double sqftPerMarla = 225; // same constant as cost_service._get_notes
  static const double coverage = 0.70; // same coverage as cost/material services

  static const double minPlotArea = 500, maxPlotArea = 20000;
  static const int minFloors = 1, maxFloors = 4;
  static const int minBedrooms = 1, maxBedrooms = 10;
  static const int minBathrooms = 1, maxBathrooms = 8;
  static const int minKitchens = 1, maxKitchens = 2;
  static const double minRoomSize = 50, maxRoomSize = 5000;

  static const List<PlotPreset> plotPresets = [
    PlotPreset('5 Marla', 1125),
    PlotPreset('8 Marla', 1800),
    PlotPreset('10 Marla', 2250),
    PlotPreset('1 Kanal', 4500),
    PlotPreset('2 Kanal', 9000),
  ];

  static const List<String> cities = ['lahore', 'karachi', 'islamabad'];
  static const List<String> interiorCities = ['lahore', 'karachi', 'islamabad', 'rawalpindi'];
  static const List<String> styles = ['modern', 'traditional', 'minimalist', 'luxury'];

  /// Cost + materials budgets (backend maps these to low/medium/high).
  static const List<String> budgetKeys = ['economy', 'standard', 'premium'];
  static const Map<String, String> budgetLabels = {
    'economy': 'Economy',
    'standard': 'Standard',
    'premium': 'Premium',
  };

  /// Interior endpoint uses economy / standard / luxury.
  static const List<String> interiorBudgetKeys = ['economy', 'standard', 'luxury'];

  static const Map<String, String> roomTypes = {
    'bedroom': 'Bedroom',
    'living_room': 'Living Room',
    'kitchen': 'Kitchen',
    'bathroom': 'Bathroom',
    'drawing_room': 'Drawing Room',
    'dining_room': 'Dining Room',
  };

  /// Backend returns budget_range normalised to low/medium/high.
  static String budgetKeyFromBackend(String v) {
    switch (v.toLowerCase()) {
      case 'low':
      case 'economy':
        return 'economy';
      case 'high':
      case 'premium':
        return 'premium';
      default:
        return 'standard';
    }
  }

  /// Layout room types -> interior endpoint room types.
  static String? interiorTypeForRoom(String layoutType) {
    switch (layoutType) {
      case 'master_bedroom':
      case 'bedroom':
        return 'bedroom';
      case 'living_room':
      case 'kitchen':
      case 'bathroom':
      case 'drawing_room':
      case 'dining_room':
        return layoutType;
      default:
        return null;
    }
  }
}