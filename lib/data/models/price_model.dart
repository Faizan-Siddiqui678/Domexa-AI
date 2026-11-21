import '../../core/utils/json_utils.dart';

/// Parsed from GET /api/prices?city=
class PriceModel {
  final String city, sourceLabel, scrapedAt, warning;
  final double cement, steel, brick, sand, crush;
  const PriceModel({
    required this.city, required this.sourceLabel, required this.scrapedAt, required this.warning,
    required this.cement, required this.steel, required this.brick, required this.sand, required this.crush,
  });
  factory PriceModel.fromJson(Map<String, dynamic> j) {
    final p = jmap(j['prices']);
    double avg(String k) => jd(jmap(p[k])['average']);
    return PriceModel(
      city: js(j['city']), sourceLabel: js(j['source_label'], js(j['source'])), scrapedAt: js(j['scraped_at']),
      warning: js(j['warning']),
      cement: avg('cement'), steel: avg('steel'), brick: avg('bricks'), sand: avg('sand'), crush: avg('crush'),
    );
  }
}