/// Material Recommendation Model — matches backend response

class MaterialModel {
  final String budgetCategory;
  final List<MaterialCategory> materials;
  final double totalMaterialCost;
  final Map<String, double> summary;
  final String climateAdvice;
  final String budgetLabel;

  MaterialModel({
    required this.budgetCategory,
    required this.materials,
    required this.totalMaterialCost,
    required this.summary,
    required this.climateAdvice,
    required this.budgetLabel,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    // Backend sends flat list — group by category
    final rawMaterials = json['materials'] as List? ?? [];
    final grouped = <String, List<dynamic>>{};
    for (final m in rawMaterials) {
      final cat = m['category'] as String? ?? 'General';
      grouped.putIfAbsent(cat, () => []).add(m);
    }

    final categories = grouped.entries.map((e) {
      return MaterialCategory(
        category: e.key,
        items: e.value.map((m) => MaterialItem.fromJson(m)).toList(),
      );
    }).toList();

    final summaryRaw = json['summary'] as Map<String, dynamic>? ?? {};
    final summary = summaryRaw.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    final budgetTier = rawMaterials.isNotEmpty
        ? (rawMaterials.first['budget_tier'] as String? ?? 'medium')
        : 'medium';

    return MaterialModel(
      budgetCategory:    budgetTier,
      materials:         categories,
      totalMaterialCost: (json['total_estimated_cost'] as num?)?.toDouble() ?? 0,
      summary:           summary,
      climateAdvice:     json['climate_advice'] as String? ?? '',
      budgetLabel:       json['budget_label'] as String? ?? 'Standard Budget',
    );
  }

  List<String> get recommendations =>
      climateAdvice.isNotEmpty ? [climateAdvice] : [];
}

class MaterialCategory {
  final String category;
  final List<MaterialItem> items;

  MaterialCategory({
    required this.category,
    required this.items,
  });

  factory MaterialCategory.fromJson(Map<String, dynamic> json) {
    return MaterialCategory(
      category: json['category'] as String? ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => MaterialItem.fromJson(item))
          .toList(),
    );
  }

  double get totalCost =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Map<String, dynamic> toJson() => {
    'category': category,
    'items':    items.map((i) => i.toJson()).toList(),
  };
}

class MaterialItem {
  final String name;
  final double quantity;
  final String unit;
  final String selectedBrand;
  final double unitPrice;
  final double totalPrice;
  final String qualityTier;
  final String pros;
  final String cons;

  MaterialItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.selectedBrand,
    required this.unitPrice,
    required this.totalPrice,
    required this.qualityTier,
    required this.pros,
    required this.cons,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      name:          json['name'] as String? ?? '',
      quantity:      (json['quantity'] as num?)?.toDouble() ?? 0,
      unit:          json['unit'] as String? ?? '',
      selectedBrand: json['brand'] as String?
          ?? json['selected_brand'] as String? ?? '',
      unitPrice:     (json['unit_price_pkr'] as num?)?.toDouble()
          ?? (json['unit_price'] as num?)?.toDouble() ?? 0,
      totalPrice:    (json['total_price_pkr'] as num?)?.toDouble()
          ?? (json['total_price'] as num?)?.toDouble() ?? 0,
      qualityTier:   json['budget_tier'] as String?
          ?? json['quality_tier'] as String? ?? '',
      pros:          json['pros'] as String? ?? '',
      cons:          json['cons'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name':           name,
    'quantity':       quantity,
    'unit':           unit,
    'brand':          selectedBrand,
    'unit_price_pkr': unitPrice,
    'total_price_pkr': totalPrice,
    'budget_tier':    qualityTier,
    'pros':           pros,
    'cons':           cons,
  };

  // Compatibility helpers used by existing screens
  List<String> get brandOptions =>
      selectedBrand.isNotEmpty ? [selectedBrand] : [];

  String get notes => pros.isNotEmpty ? 'Pros: $pros' : '';
}