/// Plot Input Data Model

class PlotInputModel {
  final double plotArea;
  final int numFloors;
  final int bedrooms;
  final int kitchens;
  final int bathrooms;
  final bool drawingRoom;
  final bool diningRoom;
  final bool garage;
  final bool basement;
  final bool gallery;
  final bool terrace;
  final bool servantQuarter;
  final bool storeRoom;
  final String stylePreference;
  final String budgetCategory;

  PlotInputModel({
    required this.plotArea,
    required this.numFloors,
    required this.bedrooms,
    required this.kitchens,
    required this.bathrooms,
    this.drawingRoom = false,
    this.diningRoom = false,
    this.garage = false,
    this.basement = false,
    this.gallery = false,
    this.terrace = false,
    this.servantQuarter = false,
    this.storeRoom = false,
    this.stylePreference = 'modern',
    this.budgetCategory = 'medium',
  });

  /// Convert to JSON — field names match backend exactly
  Map<String, dynamic> toJson() {
    return {
      'plot_area':    plotArea,
      'num_floors':   numFloors,
      'bedrooms':     bedrooms,
      'kitchen':      kitchens,       // backend expects 'kitchen' not 'kitchens'
      'bathrooms':    bathrooms,
      'drawing_room': drawingRoom,
      'dining_room':  diningRoom,
      'garage':       garage,
      'basement':     basement,
      'gallery':      gallery,
      'open_area':       terrace,
      'servant_quarter': servantQuarter,
      'store_room':      storeRoom,
      'house_style':     stylePreference,
    };
  }

  factory PlotInputModel.fromJson(Map<String, dynamic> json) {
    return PlotInputModel(
      plotArea:        (json['plot_area'] as num).toDouble(),
      numFloors:       json['num_floors'] as int,
      bedrooms:        json['bedrooms'] as int,
      kitchens:        json['kitchen'] as int? ?? 1,
      bathrooms:       json['bathrooms'] as int,
      drawingRoom:     json['drawing_room'] ?? false,
      diningRoom:      json['dining_room'] ?? false,
      garage:          json['garage'] ?? false,
      basement:        json['basement'] ?? false,
      gallery:         json['gallery'] ?? false,
      terrace:         json['open_area'] ?? false,
      stylePreference: json['house_style'] ?? 'modern',
      budgetCategory:  json['budget_range'] ?? 'medium',
    );
  }

  int get totalRooms {
    int count = bedrooms + kitchens + bathrooms;
    if (drawingRoom) count++;
    if (diningRoom) count++;
    if (garage) count++;
    if (servantQuarter) count++;
    if (storeRoom) count++;
    return count;
  }

  PlotInputModel copyWith({
    double? plotArea,
    int? numFloors,
    int? bedrooms,
    int? kitchens,
    int? bathrooms,
    bool? drawingRoom,
    bool? diningRoom,
    bool? garage,
    bool? basement,
    bool? gallery,
    bool? terrace,
    bool? servantQuarter,
    bool? storeRoom,
    String? stylePreference,
    String? budgetCategory,
  }) {
    return PlotInputModel(
      plotArea:        plotArea ?? this.plotArea,
      numFloors:       numFloors ?? this.numFloors,
      bedrooms:        bedrooms ?? this.bedrooms,
      kitchens:        kitchens ?? this.kitchens,
      bathrooms:       bathrooms ?? this.bathrooms,
      drawingRoom:     drawingRoom ?? this.drawingRoom,
      diningRoom:      diningRoom ?? this.diningRoom,
      garage:          garage ?? this.garage,
      basement:        basement ?? this.basement,
      gallery:         gallery ?? this.gallery,
      terrace:         terrace ?? this.terrace,
      servantQuarter:  servantQuarter ?? this.servantQuarter,
      storeRoom:       storeRoom ?? this.storeRoom,
      stylePreference: stylePreference ?? this.stylePreference,
      budgetCategory:  budgetCategory ?? this.budgetCategory,
    );
  }
}