import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

/// Extra-room toggles, keyed exactly like PlotInputRequest in the backend.
class ExtraRoom {
  final String key, label, hint;
  const ExtraRoom(this.key, this.label, this.hint);
}

const List<ExtraRoom> kExtraRooms = [
  ExtraRoom('drawing_room', 'Drawing room', 'Formal guest seating'),
  ExtraRoom('dining_room', 'Dining room', 'Separate dining space'),
  ExtraRoom('garage', 'Garage', 'Covered car parking'),
  ExtraRoom('basement', 'Basement', 'Adds ~50% of plot area to cost'),
  ExtraRoom('gallery', 'Gallery / corridor', 'Wide passage between rooms'),
  ExtraRoom('open_area', 'Open area / terrace', 'Lawn or roof terrace'),
  ExtraRoom('servant_quarter', 'Servant quarter', 'Separate staff room'),
  ExtraRoom('store_room', 'Store room', 'Storage space'),
];

/// Request body for POST /api/generate-layout (snake_case, see PlotInputRequest).
class PlotInputModel {
  final double plotArea;
  final int numFloors, bedrooms, bathrooms, kitchen;
  final bool drawingRoom, diningRoom, garage, basement, gallery, openArea, servantQuarter, storeRoom;
  final String houseStyle;

  const PlotInputModel({
    this.plotArea = 2250,
    this.numFloors = 2,
    this.bedrooms = 4,
    this.bathrooms = 3,
    this.kitchen = 1,
    this.drawingRoom = true,
    this.diningRoom = true,
    this.garage = false,
    this.basement = false,
    this.gallery = false,
    this.openArea = true,
    this.servantQuarter = false,
    this.storeRoom = false,
    this.houseStyle = 'modern',
  });

  double get marla => plotArea / AppConstants.sqftPerMarla;
  // Same formula as material_service / cost_service: plot x 70% coverage x floors
  double get builtArea => plotArea * AppConstants.coverage * numFloors;

  bool extra(String key) {
    switch (key) {
      case 'drawing_room': return drawingRoom;
      case 'dining_room': return diningRoom;
      case 'garage': return garage;
      case 'basement': return basement;
      case 'gallery': return gallery;
      case 'open_area': return openArea;
      case 'servant_quarter': return servantQuarter;
      case 'store_room': return storeRoom;
    }
    return false;
  }

  PlotInputModel withExtra(String key, bool v) {
    switch (key) {
      case 'drawing_room': return copyWith(drawingRoom: v);
      case 'dining_room': return copyWith(diningRoom: v);
      case 'garage': return copyWith(garage: v);
      case 'basement': return copyWith(basement: v);
      case 'gallery': return copyWith(gallery: v);
      case 'open_area': return copyWith(openArea: v);
      case 'servant_quarter': return copyWith(servantQuarter: v);
      case 'store_room': return copyWith(storeRoom: v);
    }
    return this;
  }

  PlotInputModel copyWith({
    double? plotArea, int? numFloors, int? bedrooms, int? bathrooms, int? kitchen,
    bool? drawingRoom, bool? diningRoom, bool? garage, bool? basement, bool? gallery,
    bool? openArea, bool? servantQuarter, bool? storeRoom, String? houseStyle,
  }) =>
      PlotInputModel(
        plotArea: plotArea ?? this.plotArea,
        numFloors: numFloors ?? this.numFloors,
        bedrooms: bedrooms ?? this.bedrooms,
        bathrooms: bathrooms ?? this.bathrooms,
        kitchen: kitchen ?? this.kitchen,
        drawingRoom: drawingRoom ?? this.drawingRoom,
        diningRoom: diningRoom ?? this.diningRoom,
        garage: garage ?? this.garage,
        basement: basement ?? this.basement,
        gallery: gallery ?? this.gallery,
        openArea: openArea ?? this.openArea,
        servantQuarter: servantQuarter ?? this.servantQuarter,
        storeRoom: storeRoom ?? this.storeRoom,
        houseStyle: houseStyle ?? this.houseStyle,
      );

  String? get areaError => (plotArea < AppConstants.minPlotArea || plotArea > AppConstants.maxPlotArea)
      ? 'Plot area must be ${Fmt.number(AppConstants.minPlotArea)}-${Fmt.number(AppConstants.maxPlotArea)} sqft'
      : null;

  bool get isValid => areaError == null;

  /// Soft, non-blocking advice (heuristic: help users foresee problems).
  List<String> get warnings {
    final w = <String>[];
    final rooms = bedrooms + bathrooms + kitchen + 2 +
        kExtraRooms.where((e) => e.key != 'basement' && e.key != 'open_area' && extra(e.key)).length;
    if (builtArea / rooms < 95) {
      w.add('That is a lot of rooms for this plot - rooms may come out very small. '
          'Try a bigger plot, more floors or fewer rooms.');
    }
    if (bathrooms > bedrooms + 3) w.add('You have many more bathrooms than bedrooms.');
    if (numFloors >= 3) w.add('3+ floors need a structural engineer and soil test.');
    return w;
  }

  String get summary => '${Fmt.marla(plotArea)} Marla - $numFloors floor${numFloors > 1 ? 's' : ''}';

  Map<String, dynamic> toJson() => {
    'plot_area': plotArea,
    'num_floors': numFloors,
    'bedrooms': bedrooms,
    'kitchen': kitchen,
    'bathrooms': bathrooms,
    'drawing_room': drawingRoom,
    'dining_room': diningRoom,
    'garage': garage,
    'basement': basement,
    'gallery': gallery,
    'open_area': openArea,
    'servant_quarter': servantQuarter,
    'store_room': storeRoom,
    'house_style': houseStyle,
  };

  factory PlotInputModel.fromJson(Map<String, dynamic> j) => PlotInputModel(
    plotArea: (j['plot_area'] as num?)?.toDouble() ?? 2250,
    numFloors: (j['num_floors'] as num?)?.toInt() ?? 2,
    bedrooms: (j['bedrooms'] as num?)?.toInt() ?? 4,
    bathrooms: (j['bathrooms'] as num?)?.toInt() ?? 3,
    kitchen: (j['kitchen'] as num?)?.toInt() ?? 1,
    drawingRoom: j['drawing_room'] == true,
    diningRoom: j['dining_room'] == true,
    garage: j['garage'] == true,
    basement: j['basement'] == true,
    gallery: j['gallery'] == true,
    openArea: j['open_area'] == true,
    servantQuarter: j['servant_quarter'] == true,
    storeRoom: j['store_room'] == true,
    houseStyle: (j['house_style'] as String?) ?? 'modern',
  );

  @override
  bool operator ==(Object o) => o is PlotInputModel && o.toJson().toString() == toJson().toString();
  @override
  int get hashCode => toJson().toString().hashCode;
}