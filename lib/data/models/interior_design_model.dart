// lib/data/models/interior_design_model.dart
// v3 — added imageBase64 field for Hugging Face base64 response

class InteriorDesignModel {
  final String roomType;
  final double roomSize;
  final String style;

  // ── image fields ──────────────────────────────────────────────────────────
  final String? imageUrl;        // DALL-E URL (kept for compatibility)
  final String? imageBase64;     // ← NEW: Hugging Face base64 PNG string
  final String? imageError;      // error message if generation failed
  final String? imagePrompt;     // prompt sent to HF (for debugging)

  // ── design data ───────────────────────────────────────────────────────────
  final List<ColorTheme> colorThemes;
  final List<FurnitureItem> furniture;
  final LightingDesign lighting;
  final CeilingDesign ceilingDesign;
  final List<String> recommendations;

  InteriorDesignModel({
    required this.roomType,
    required this.roomSize,
    required this.style,
    this.imageUrl,
    this.imageBase64,
    this.imageError,
    this.imagePrompt,
    required this.colorThemes,
    required this.furniture,
    required this.lighting,
    required this.ceilingDesign,
    required this.recommendations,
  });

  /// Whether we have any image to show (base64 or URL)
  bool get hasImage => imageBase64 != null || imageUrl != null;

  /// True if backend returned base64 (Hugging Face)
  bool get isBase64Image => imageBase64 != null;

  factory InteriorDesignModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return InteriorDesignModel(
      roomType:        data['room_type']     as String? ?? '',
      roomSize:        (data['room_size'] as num?)?.toDouble() ?? 200,
      style:           data['style']         as String? ?? 'modern',
      imageUrl:        data['image_url']     as String?,
      imageBase64:     data['image_base64']  as String?,
      imageError:      data['image_error']   as String?,
      imagePrompt:     data['image_prompt']  as String?,
      colorThemes: (data['color_themes'] as List? ?? [])
          .map((e) => ColorTheme.fromJson(e as Map<String, dynamic>))
          .toList(),
      furniture: (data['furniture'] as List? ?? [])
          .map((e) => FurnitureItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lighting:     LightingDesign.fromJson(
          (data['lighting']       as Map<String, dynamic>?) ?? {}),
      ceilingDesign: CeilingDesign.fromJson(
          (data['ceiling_design'] as Map<String, dynamic>?) ?? {}),
      recommendations: (data['recommendations'] as List? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'room_type':     roomType,
    'room_size':     roomSize,
    'style':         style,
    'image_url':     imageUrl,
    'image_base64':  imageBase64,
    'image_error':   imageError,
    'image_prompt':  imagePrompt,
    'color_themes':  colorThemes.map((e) => e.toJson()).toList(),
    'furniture':     furniture.map((e) => e.toJson()).toList(),
    'lighting':      lighting.toJson(),
    'ceiling_design':ceilingDesign.toJson(),
    'recommendations':recommendations,
  };
}


class ColorTheme {
  final String themeName;
  final String mood;
  final String mainWall;
  final String accentWall;
  final String ceiling;

  ColorTheme({
    required this.themeName,
    required this.mood,
    required this.mainWall,
    required this.accentWall,
    required this.ceiling,
  });

  factory ColorTheme.fromJson(Map<String, dynamic> json) => ColorTheme(
    themeName:  json['theme_name']  as String? ?? '',
    mood:       json['mood']        as String? ?? '',
    mainWall:   json['main_wall']   as String? ?? '',
    accentWall: json['accent_wall'] as String? ?? '',
    ceiling:    json['ceiling']     as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'theme_name':  themeName,
    'mood':        mood,
    'main_wall':   mainWall,
    'accent_wall': accentWall,
    'ceiling':     ceiling,
  };
}


class FurnitureItem {
  final String item;
  final String dimensions;
  final String position;
  final String priority;
  final String priceRange;

  FurnitureItem({
    required this.item,
    required this.dimensions,
    required this.position,
    required this.priority,
    required this.priceRange,
  });

  factory FurnitureItem.fromJson(Map<String, dynamic> json) => FurnitureItem(
    item:       json['item']        as String? ?? '',
    dimensions: json['dimensions']  as String? ?? '',
    position:   json['position']    as String? ?? '',
    priority:   json['priority']    as String? ?? 'optional',
    priceRange: json['price_range'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'item':        item,
    'dimensions':  dimensions,
    'position':    position,
    'priority':    priority,
    'price_range': priceRange,
  };
}


class LightingDesign {
  final String? primary;
  final List<String> secondary;
  final List<String> ambient;

  LightingDesign({this.primary, required this.secondary, required this.ambient});

  factory LightingDesign.fromJson(Map<String, dynamic> json) => LightingDesign(
    primary:   json['primary']   as String?,
    secondary: (json['secondary'] as List?)?.cast<String>() ?? [],
    ambient:   (json['ambient']   as List?)?.cast<String>() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'primary':   primary,
    'secondary': secondary,
    'ambient':   ambient,
  };
}


class CeilingDesign {
  final String type;
  final String material;
  final String cost;
  final List<String> features;

  CeilingDesign({
    required this.type,
    required this.material,
    required this.cost,
    required this.features,
  });

  factory CeilingDesign.fromJson(Map<String, dynamic> json) => CeilingDesign(
    type:     json['type']     as String? ?? '',
    material: json['material'] as String? ?? '',
    cost:     json['cost']     as String? ?? '',
    features: (json['features'] as List?)?.cast<String>() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'type':     type,
    'material': material,
    'cost':     cost,
    'features': features,
  };
}