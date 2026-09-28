// lib/data/models/layout_model.dart
// v2 — added floorRequirements to FloorModel (per-floor breakdown from backend)

class LayoutModel {
  final double totalCoveredArea;
  final double totalOpenArea;
  final int totalRooms;
  final List<FloorModel> floors;
  final List<String> recommendations;
  final List<String> vastuNotes;

  LayoutModel({
    required this.totalCoveredArea,
    required this.totalOpenArea,
    required this.totalRooms,
    required this.floors,
    required this.recommendations,
    required this.vastuNotes,
  });

  factory LayoutModel.fromJson(Map<String, dynamic> json) {
    return LayoutModel(
      totalCoveredArea: (json['total_covered_area'] as num?)?.toDouble() ?? 0,
      totalOpenArea:    (json['total_open_area']    as num?)?.toDouble() ?? 0,
      totalRooms:       json['total_rooms']         as int?              ?? 0,
      floors: (json['floors'] as List? ?? [])
          .map((f) => FloorModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      vastuNotes:      List<String>.from(json['vastu_notes']     ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_covered_area': totalCoveredArea,
    'total_open_area':    totalOpenArea,
    'total_rooms':        totalRooms,
    'floors':             floors.map((f) => f.toJson()).toList(),
    'recommendations':    recommendations,
    'vastu_notes':        vastuNotes,
  };
}


class FloorModel {
  final int floorNumber;
  final String floorName;
  final double floorArea;
  final List<RoomModel> rooms;

  /// ← NEW: human-readable breakdown of what's on this floor
  /// comes from backend's _floor_requirements()
  /// e.g. { "floor_name": "Ground Floor",
  ///         "room_list": ["Drawing Room","Kitchen","Dining Room","Bathroom","Stairs"],
  ///         "room_count": 5,
  ///         "summary": "Drawing Room, Kitchen, Dining Room, Bathroom..." }
  final Map<String, dynamic>? floorRequirements;

  FloorModel({
    required this.floorNumber,
    required this.floorName,
    required this.floorArea,
    required this.rooms,
    this.floorRequirements,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      floorNumber:       json['floor_number']       as int?    ?? 0,
      floorName:         json['floor_name']          as String? ?? 'Floor',
      floorArea:         (json['floor_area'] as num?)?.toDouble() ?? 0,
      floorRequirements: json['floor_requirements']  as Map<String, dynamic>?,
      rooms: (json['rooms'] as List? ?? [])
          .map((r) => RoomModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'floor_number':       floorNumber,
    'floor_name':         floorName,
    'floor_area':         floorArea,
    'floor_requirements': floorRequirements,
    'rooms':              rooms.map((r) => r.toJson()).toList(),
  };

  double get totalArea =>
      rooms.fold(0.0, (sum, r) => sum + r.dimensions.area);
}


class RoomModel {
  final String roomId;
  final String roomName;
  final String roomType;
  final String color;
  final RoomDimensions dimensions;
  final RoomPosition position;
  final RoomFeatures features;

  RoomModel({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.color,
    required this.dimensions,
    required this.position,
    required this.features,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId:     json['room_id']   as String? ?? '',
      roomName:   json['room_name'] as String? ?? '',
      roomType:   json['room_type'] as String? ?? '',
      color:      json['color']     as String? ?? '#E3F2FD',
      dimensions: RoomDimensions.fromJson(
          (json['dimensions'] as Map<String, dynamic>?) ?? {}),
      position:   RoomPosition.fromJson(
          (json['position']   as Map<String, dynamic>?) ?? {}),
      features:   RoomFeatures.fromJson(
          (json['features']   as Map<String, dynamic>?) ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'room_id':    roomId,
    'room_name':  roomName,
    'room_type':  roomType,
    'color':      color,
    'dimensions': dimensions.toJson(),
    'position':   position.toJson(),
    'features':   features.toJson(),
  };
}


class RoomDimensions {
  final double length;
  final double width;
  final double area;

  RoomDimensions({
    required this.length,
    required this.width,
    required this.area,
  });

  factory RoomDimensions.fromJson(Map<String, dynamic> json) => RoomDimensions(
    length: (json['length'] as num?)?.toDouble() ?? 0,
    width:  (json['width']  as num?)?.toDouble() ?? 0,
    area:   (json['area']   as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'length': length,
    'width':  width,
    'area':   area,
  };
}


class RoomPosition {
  final double x;
  final double y;

  RoomPosition({required this.x, required this.y});

  factory RoomPosition.fromJson(Map<String, dynamic> json) => RoomPosition(
    x: (json['x'] as num?)?.toDouble() ?? 0,
    y: (json['y'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}


class RoomFeatures {
  final int windows;
  final int doors;
  final String ventilation;

  RoomFeatures({
    required this.windows,
    required this.doors,
    required this.ventilation,
  });

  factory RoomFeatures.fromJson(Map<String, dynamic> json) => RoomFeatures(
    windows:     json['windows']     as int?    ?? 1,
    doors:       json['doors']       as int?    ?? 1,
    ventilation: json['ventilation'] as String? ?? 'good',
  );

  Map<String, dynamic> toJson() => {
    'windows':     windows,
    'doors':       doors,
    'ventilation': ventilation,
  };
}