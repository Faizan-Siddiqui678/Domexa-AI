import 'dart:convert';
import 'dart:typed_data';
import '../../core/utils/json_utils.dart';

class Swatch {
  final String label, color, hex, brand, product, price;
  const Swatch(this.label, this.color, this.hex, this.brand, this.product, this.price);
}

class FurnitureItem {
  final String item, description, dimensions, placement, priority, brand, price, material;
  const FurnitureItem({
    required this.item, required this.description, required this.dimensions, required this.placement,
    required this.priority, required this.brand, required this.price, required this.material,
  });
  factory FurnitureItem.fromJson(Map<String, dynamic> j) => FurnitureItem(
    item: js(j['item']), description: js(j['description']), dimensions: js(j['dimensions']),
    placement: js(j['placement']), priority: js(j['priority'], 'recommended'),
    brand: js(j['local_brand']), price: js(j['pkr_price_range']), material: js(j['material']),
  );
}

/// Parsed from the `data` object of POST /api/interior-design.
class InteriorDesign {
  final String roomType, style, theme, mood, acPlacement, imageError;
  final List<Swatch> swatches;
  final List<FurnitureItem> furniture;
  final Map<String, dynamic> flooring, lighting, ceiling, windowsDoors, estimatedCost;
  final List<String> specialFeatures, tips;
  final Uint8List? image;

  const InteriorDesign({
    required this.roomType, required this.style, required this.theme, required this.mood,
    required this.acPlacement, required this.imageError, required this.swatches, required this.furniture,
    required this.flooring, required this.lighting, required this.ceiling, required this.windowsDoors,
    required this.estimatedCost, required this.specialFeatures, required this.tips, required this.image,
  });

  factory InteriorDesign.fromJson(Map<String, dynamic> j) {
    final cs = jmap(j['color_scheme']);
    Swatch sw(String label, String key) {
      final c = jmap(cs[key]);
      return Swatch(label, js(c['color']), js(c['hex']), js(c['paint_brand']), js(c['paint_name']), js(c['pkr_price']));
    }

    Uint8List? img;
    final b64 = js(j['image_base64']);
    if (b64.isNotEmpty) {
      try {
        img = base64Decode(b64);
      } catch (_) {}
    }
    return InteriorDesign(
      roomType: js(j['room_type']), style: js(j['style']), theme: js(j['design_theme']),
      mood: js(cs['mood']), acPlacement: js(j['ac_placement']), imageError: js(j['image_error']),
      swatches: [
        if (cs['primary_wall'] != null) sw('Main wall', 'primary_wall'),
        if (cs['accent_wall'] != null) sw('Accent wall', 'accent_wall'),
        if (cs['ceiling'] != null) sw('Ceiling', 'ceiling'),
        if (cs['trim'] != null) sw('Trim', 'trim'),
      ],
      furniture: jlist(j['furniture'], FurnitureItem.fromJson),
      flooring: jmap(j['flooring']), lighting: jmap(j['lighting']), ceiling: jmap(j['ceiling']),
      windowsDoors: jmap(j['windows_doors']), estimatedCost: jmap(j['estimated_cost']),
      specialFeatures: jstrings(j['special_features']), tips: jstrings(j['design_tips']), image: img,
    );
  }
}