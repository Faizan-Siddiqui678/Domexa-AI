import '../../core/utils/json_utils.dart';

class RoomModel {
  final String id, name, type;
  final double x, y, width, length, areaSqft;
  final int doors, windows;
  const RoomModel({
    required this.id, required this.name, required this.type, required this.x, required this.y,
    required this.width, required this.length, required this.areaSqft,
    required this.doors, required this.windows,
  });
  factory RoomModel.fromJson(Map<String, dynamic> j) => RoomModel(
    id: js(j['room_id']),
    name: js(j['room_name'], 'Room'),
    type: js(j['room_type']),
    x: jd(j['x']), y: jd(j['y']),
    width: jd(j['width']), length: jd(j['length']),
    areaSqft: jd(j['area_sqft'], jd(j['width']) * jd(j['length'])),
    doors: (j['doors'] is List) ? (j['doors'] as List).length : 0,
    windows: (j['windows'] is List) ? (j['windows'] as List).length : 0,
  );
}

class FloorModel {
  final int number;
  final String name, svg;
  final double area;
  final List<RoomModel> rooms;
  const FloorModel({required this.number, required this.name, required this.svg, required this.area, required this.rooms});
  factory FloorModel.fromJson(Map<String, dynamic> j) => FloorModel(
    number: ji(j['floor_number']),
    name: js(j['floor_name'], 'Floor'),
    svg: js(j['svg']),
    area: jd(j['floor_area']),
    rooms: jlist(j['rooms'], RoomModel.fromJson),
  );
}

/// Parsed from LayoutResponse.layout_data
class LayoutModel {
  final double plotWidth, plotLength, coveredArea, openArea;
  final int totalRooms;
  final List<FloorModel> floors;
  final List<String> recommendations, vastuNotes;
  const LayoutModel({
    required this.plotWidth, required this.plotLength, required this.coveredArea,
    required this.openArea, required this.totalRooms, required this.floors,
    required this.recommendations, required this.vastuNotes,
  });
  factory LayoutModel.fromResponse(Map<String, dynamic> json) {
    final d = jmap(json['layout_data']);
    return LayoutModel(
      plotWidth: jd(d['plot_width']),
      plotLength: jd(d['plot_length']),
      coveredArea: jd(d['total_covered_area']),
      openArea: jd(d['total_open_area']),
      totalRooms: ji(d['total_rooms']),
      floors: jlist(d['floors'], FloorModel.fromJson),
      recommendations: jstrings(d['recommendations']),
      vastuNotes: jstrings(d['vastu_notes']),
    );
  }
}