// lib/data/models/layout_model.dart
// v5 — svg field + toJson() (project_model.dart needs it)

class LayoutModel {
  final double plotWidth;
  final double plotLength;
  final int totalFloors;
  final double totalCoveredArea;
  final double totalOpenArea;
  final List<FloorModel> floors;
  final List<String> recommendations;
  final List<String> vastuNotes;

  /// Lossless copy of the backend map — used by toJson() for saving projects.
  final Map<String, dynamic> raw;

  LayoutModel({
    required this.plotWidth,
    required this.plotLength,
    required this.totalFloors,
    required this.totalCoveredArea,
    required this.totalOpenArea,
    required this.floors,
    required this.recommendations,
    required this.vastuNotes,
    this.raw = const {},
  });

  factory LayoutModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LayoutModel(
      plotWidth:         (data['plot_width']          as num?)?.toDouble() ?? 0,
      plotLength:        (data['plot_length']         as num?)?.toDouble() ?? 0,
      totalFloors:       (data['total_floors']        as int?) ?? 1,
      totalCoveredArea:  (data['total_covered_area']  as num?)?.toDouble() ?? 0,
      totalOpenArea:     (data['total_open_area']     as num?)?.toDouble() ?? 0,
      floors: (data['floors'] as List? ?? [])
          .map((f) => FloorModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      recommendations: List<String>.from(data['recommendations'] ?? []),
      vastuNotes:      List<String>.from(data['vastu_notes']     ?? []),
      raw: Map<String, dynamic>.from(data),
    );
  }

  Map<String, dynamic> toJson() => raw;

  // Total rooms across all floors
  int get totalRooms =>
      floors.fold(0, (sum, f) => sum + f.rooms.length);
}


class FloorModel {
  final int floorNumber;
  final String floorName;
  final List<RoomModel> rooms;

  /// ← AutoCAD-style SVG string from backend renderer
  /// Flutter renders this directly with flutter_svg
  final String svg;

  /// Per-floor breakdown for UI card
  final Map<String, dynamic>? floorRequirements;

  FloorModel({
    required this.floorNumber,
    required this.floorName,
    required this.rooms,
    required this.svg,
    this.floorRequirements,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      floorNumber:       json['floor_number']       as int?    ?? 0,
      floorName:         json['floor_name']          as String? ?? 'Floor',
      svg:               json['svg']                 as String? ?? '',
      floorRequirements: json['floor_requirements']  as Map<String, dynamic>?,
      rooms: (json['rooms'] as List? ?? [])
          .map((r) => RoomModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  double get totalArea =>
      rooms.fold(0.0, (sum, r) => sum + r.areaSqft);

  String get roomSummary =>
      rooms.map((r) => r.roomName).take(4).join(', ') +
          (rooms.length > 4 ? '...' : '');
}


class RoomModel {
  final String roomId;
  final String roomName;
  final String roomType;
  final double x;
  final double y;
  final double width;
  final double length;
  final double areaSqft;
  final List<Map<String, dynamic>> doors;
  final List<Map<String, dynamic>> windows;

  RoomModel({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.x,
    required this.y,
    required this.width,
    required this.length,
    required this.areaSqft,
    required this.doors,
    required this.windows,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId:   json['room_id']    as String? ?? '',
      roomName: json['room_name']  as String? ?? '',
      roomType: json['room_type']  as String? ?? '',
      x:        (json['x']         as num?)?.toDouble() ?? 0,
      y:        (json['y']         as num?)?.toDouble() ?? 0,
      width:    (json['width']     as num?)?.toDouble() ?? 0,
      length:   (json['length']    as num?)?.toDouble() ?? 0,
      areaSqft: (json['area_sqft'] as num?)?.toDouble() ?? 0,
      doors:   (json['doors']   as List? ?? [])
          .map((d) => Map<String, dynamic>.from(d))
          .toList(),
      windows: (json['windows'] as List? ?? [])
          .map((w) => Map<String, dynamic>.from(w))
          .toList(),
    );
  }

  // Human-readable size
  String get sizeLabel =>
      '${width.toStringAsFixed(0)}′ × ${length.toStringAsFixed(0)}′';

  // Icon for room type
  String get icon {
    switch (roomType) {
      case 'master_bedroom': return '🛏️';
      case 'bedroom':        return '🛏️';
      case 'kitchen':        return '🍳';
      case 'bathroom':       return '🚿';
      case 'living_room':    return '🛋️';
      case 'drawing_room':   return '🪑';
      case 'dining_room':    return '🍽️';
      case 'garage':         return '🚗';
      case 'stairs':         return '🪜';
      case 'gallery':        return '🚶';
      case 'open_area':      return '🌿';
      case 'store_room':     return '📦';
      case 'servant_quarter':return '🏠';
      default:               return '🏠';
    }
  }
}