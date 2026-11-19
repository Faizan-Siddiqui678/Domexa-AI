// lib/data/models/interior_design_model.dart
// v5 — toJson() added; ColorScheme renamed DesignColorScheme (clashed with Flutter's)
// v4 — full Gemini LLM response model with Pakistani-specific fields

class InteriorDesignModel {
  final String roomType;
  final double roomSize;
  final String style;
  final String city;
  final String budget;

  // ── Design data from Gemini ───────────────────────────────────────────────
  final String designTheme;
  final DesignColorScheme? colorScheme;
  final List<FurnitureItem> furniture;
  final FlooringDesign? flooring;
  final LightingDesign? lighting;
  final CeilingDesign? ceiling;
  final WindowsDoors? windowsDoors;
  final String acPlacement;
  final List<String> specialFeatures;
  final List<String> designTips;
  final EstimatedCost? estimatedCost;

  // ── Image from Hugging Face ───────────────────────────────────────────────
  final String? imageBase64;
  final String? imageError;
  final String? imagePrompt;

  /// Lossless copy of the backend map (without the image) for toJson().
  final Map<String, dynamic> raw;

  InteriorDesignModel({
    required this.roomType,
    required this.roomSize,
    required this.style,
    required this.city,
    required this.budget,
    required this.designTheme,
    this.colorScheme,
    required this.furniture,
    this.flooring,
    this.lighting,
    this.ceiling,
    this.windowsDoors,
    required this.acPlacement,
    required this.specialFeatures,
    required this.designTips,
    this.estimatedCost,
    this.imageBase64,
    this.imageError,
    this.imagePrompt,
    this.raw = const {},
  });

  bool get hasImage => imageBase64 != null;

  factory InteriorDesignModel.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>? ?? json;
    return InteriorDesignModel(
      roomType:        d['room_type']         as String? ?? '',
      roomSize:        (d['room_size'] as num?)?.toDouble() ?? 200,
      style:           d['style']             as String? ?? 'modern',
      city:            d['city']              as String? ?? 'lahore',
      budget:          d['budget']            as String? ?? 'standard',
      designTheme:     d['design_theme']      as String? ?? '',
      colorScheme:     d['color_scheme']   != null
          ? DesignColorScheme.fromJson(d['color_scheme'] as Map<String, dynamic>)
          : null,
      furniture: (d['furniture'] as List? ?? [])
          .map((e) => FurnitureItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      flooring: d['flooring'] != null
          ? FlooringDesign.fromJson(d['flooring'] as Map<String, dynamic>)
          : null,
      lighting: d['lighting'] != null
          ? LightingDesign.fromJson(d['lighting'] as Map<String, dynamic>)
          : null,
      ceiling: d['ceiling'] != null
          ? CeilingDesign.fromJson(d['ceiling'] as Map<String, dynamic>)
          : null,
      windowsDoors: d['windows_doors'] != null
          ? WindowsDoors.fromJson(d['windows_doors'] as Map<String, dynamic>)
          : null,
      acPlacement:     d['ac_placement']      as String? ?? '',
      specialFeatures: List<String>.from(d['special_features'] ?? []),
      designTips:      List<String>.from(d['design_tips']      ?? []),
      estimatedCost: d['estimated_cost'] != null
          ? EstimatedCost.fromJson(d['estimated_cost'] as Map<String, dynamic>)
          : null,
      imageBase64:  d['image_base64']   as String?,
      imageError:   d['image_error']    as String?,
      imagePrompt:  d['image_prompt']   as String?,
      raw: Map<String, dynamic>.from(d)..remove('image_base64'),
    );
  }

  /// Saved with the project. The base64 image is deliberately NOT stored:
  /// it is large and Firestore documents are limited to 1 MB.
  Map<String, dynamic> toJson() => raw;
}


class DesignColorScheme {
  final PaintColor primaryWall;
  final PaintColor accentWall;
  final SimpleColor ceiling;
  final SimpleColor trim;
  final String mood;

  DesignColorScheme({
    required this.primaryWall,
    required this.accentWall,
    required this.ceiling,
    required this.trim,
    required this.mood,
  });

  factory DesignColorScheme.fromJson(Map<String, dynamic> j) => DesignColorScheme(
    primaryWall: PaintColor.fromJson(
        (j['primary_wall'] as Map<String, dynamic>?) ?? {}),
    accentWall:  PaintColor.fromJson(
        (j['accent_wall']  as Map<String, dynamic>?) ?? {}),
    ceiling:     SimpleColor.fromJson(
        (j['ceiling']      as Map<String, dynamic>?) ?? {}),
    trim:        SimpleColor.fromJson(
        (j['trim']         as Map<String, dynamic>?) ?? {}),
    mood:        j['mood']   as String? ?? '',
  );
}


class PaintColor {
  final String color;
  final String hex;
  final String paintBrand;
  final String paintName;
  final String pkrPrice;

  PaintColor({
    required this.color,
    required this.hex,
    required this.paintBrand,
    required this.paintName,
    required this.pkrPrice,
  });

  factory PaintColor.fromJson(Map<String, dynamic> j) => PaintColor(
    color:      j['color']       as String? ?? '',
    hex:        j['hex']         as String? ?? '#F8F8F8',
    paintBrand: j['paint_brand'] as String? ?? '',
    paintName:  j['paint_name']  as String? ?? '',
    pkrPrice:   j['pkr_price']   as String? ?? '',
  );
}


class SimpleColor {
  final String color;
  final String hex;

  SimpleColor({required this.color, required this.hex});

  factory SimpleColor.fromJson(Map<String, dynamic> j) => SimpleColor(
    color: j['color'] as String? ?? '',
    hex:   j['hex']   as String? ?? '#FFFFFF',
  );
}


class FurnitureItem {
  final String item;
  final String description;
  final String dimensions;
  final String placement;
  final String priority;
  final String localBrand;
  final String pkrPriceRange;
  final String material;

  FurnitureItem({
    required this.item,
    required this.description,
    required this.dimensions,
    required this.placement,
    required this.priority,
    required this.localBrand,
    required this.pkrPriceRange,
    required this.material,
  });

  factory FurnitureItem.fromJson(Map<String, dynamic> j) => FurnitureItem(
    item:          j['item']            as String? ?? '',
    description:   j['description']     as String? ?? '',
    dimensions:    j['dimensions']      as String? ?? '',
    placement:     j['placement']       as String? ?? '',
    priority:      j['priority']        as String? ?? 'optional',
    localBrand:    j['local_brand']     as String? ?? '',
    pkrPriceRange: j['pkr_price_range'] as String? ?? '',
    material:      j['material']        as String? ?? '',
  );
}


class FlooringDesign {
  final String type;
  final String description;
  final String brand;
  final String pkrPerSqft;
  final String color;

  FlooringDesign({
    required this.type,
    required this.description,
    required this.brand,
    required this.pkrPerSqft,
    required this.color,
  });

  factory FlooringDesign.fromJson(Map<String, dynamic> j) => FlooringDesign(
    type:        j['type']          as String? ?? '',
    description: j['description']   as String? ?? '',
    brand:       j['brand']         as String? ?? '',
    pkrPerSqft:  j['pkr_per_sqft']  as String? ?? '',
    color:       j['color']         as String? ?? '',
  );
}


class LightingDesign {
  final LightingItem? main;
  final List<LightingItem> secondary;
  final String ambient;
  final String colorTemperature;

  LightingDesign({
    this.main,
    required this.secondary,
    required this.ambient,
    required this.colorTemperature,
  });

  factory LightingDesign.fromJson(Map<String, dynamic> j) => LightingDesign(
    main: j['main'] != null
        ? LightingItem.fromJson(j['main'] as Map<String, dynamic>)
        : null,
    secondary: (j['secondary'] as List? ?? [])
        .map((e) => LightingItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    ambient:          j['ambient']           as String? ?? '',
    colorTemperature: j['color_temperature'] as String? ?? '',
  );
}


class LightingItem {
  final String type;
  final String description;
  final String pkrPrice;

  LightingItem({
    required this.type,
    required this.description,
    required this.pkrPrice,
  });

  factory LightingItem.fromJson(Map<String, dynamic> j) => LightingItem(
    type:        j['type']        as String? ?? '',
    description: j['description'] as String? ?? '',
    pkrPrice:    j['pkr_price']   as String? ?? '',
  );
}


class CeilingDesign {
  final String type;
  final String material;
  final String design;
  final String pkrPerSqft;
  final List<String> features;

  CeilingDesign({
    required this.type,
    required this.material,
    required this.design,
    required this.pkrPerSqft,
    required this.features,
  });

  factory CeilingDesign.fromJson(Map<String, dynamic> j) => CeilingDesign(
    type:       j['type']         as String? ?? '',
    material:   j['material']     as String? ?? '',
    design:     j['design']       as String? ?? '',
    pkrPerSqft: j['pkr_per_sqft'] as String? ?? '',
    features:   List<String>.from(j['features'] ?? []),
  );
}


class WindowsDoors {
  final String curtainType;
  final String curtainColor;
  final String curtainMaterial;
  final String doorStyle;
  final String doorMaterial;

  WindowsDoors({
    required this.curtainType,
    required this.curtainColor,
    required this.curtainMaterial,
    required this.doorStyle,
    required this.doorMaterial,
  });

  factory WindowsDoors.fromJson(Map<String, dynamic> j) => WindowsDoors(
    curtainType:     j['curtain_type']     as String? ?? '',
    curtainColor:    j['curtain_color']    as String? ?? '',
    curtainMaterial: j['curtain_material'] as String? ?? '',
    doorStyle:       j['door_style']       as String? ?? '',
    doorMaterial:    j['door_material']    as String? ?? '',
  );
}


class EstimatedCost {
  final String economy;
  final String standard;
  final String luxury;

  EstimatedCost({
    required this.economy,
    required this.standard,
    required this.luxury,
  });

  factory EstimatedCost.fromJson(Map<String, dynamic> j) => EstimatedCost(
    economy:  j['economy']  as String? ?? '',
    standard: j['standard'] as String? ?? '',
    luxury:   j['luxury']   as String? ?? '',
  );
}