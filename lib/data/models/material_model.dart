import '../../core/utils/json_utils.dart';

class LiveRates {
  final double cement, steel, brick;
  final String source, scrapedAt;
  const LiveRates({required this.cement, required this.steel, required this.brick, required this.source, required this.scrapedAt});
  // Materials endpoint uses cement_per_bag_pkr, cost endpoint uses cement_pkr_per_bag.
  factory LiveRates.fromJson(Map<String, dynamic> j) => LiveRates(
    cement: jd(j['cement_per_bag_pkr'] ?? j['cement_pkr_per_bag']),
    steel: jd(j['steel_per_kg_pkr'] ?? j['steel_pkr_per_kg']),
    brick: jd(j['brick_per_piece_pkr'] ?? j['brick_pkr_per_piece']),
    source: js(j['source'], 'fallback'),
    scrapedAt: js(j['scraped_at']),
  );
  bool get isFallback => source.toLowerCase().contains('fallback');
}

class MaterialItem {
  final String name, category, unit, brand, note;
  final double quantity, unitPrice, totalPrice;
  const MaterialItem({
    required this.name, required this.category, required this.unit, required this.brand, required this.note,
    required this.quantity, required this.unitPrice, required this.totalPrice,
  });
  factory MaterialItem.fromJson(Map<String, dynamic> j) => MaterialItem(
    name: js(j['name']), category: js(j['category'], 'Other'), unit: js(j['unit']),
    brand: js(j['brand']), note: js(j['note']),
    quantity: jd(j['quantity']), unitPrice: jd(j['unit_price_pkr']), totalPrice: jd(j['total_price_pkr']),
  );
}

class MaterialResult {
  final List<MaterialItem> items;
  final double total;
  final Map<String, double> summary;
  final String climateAdvice, budgetLabel;
  final LiveRates? rates;
  const MaterialResult({
    required this.items, required this.total, required this.summary,
    required this.climateAdvice, required this.budgetLabel, required this.rates,
  });

  factory MaterialResult.fromJson(Map<String, dynamic> j) => MaterialResult(
    items: jlist(j['materials'], MaterialItem.fromJson),
    total: jd(j['total_estimated_cost']),
    summary: jmap(j['summary']).map((k, v) => MapEntry(k, jd(v))),
    climateAdvice: js(j['climate_advice']),
    budgetLabel: js(j['budget_label'], 'Standard Budget'),
    rates: j['live_rates'] is Map ? LiveRates.fromJson(jmap(j['live_rates'])) : null,
  );

  /// Items grouped by category, preserving backend order.
  Map<String, List<MaterialItem>> get byCategory {
    final m = <String, List<MaterialItem>>{};
    for (final i in items) {
      (m[i.category] ??= []).add(i);
    }
    return m;
  }
}