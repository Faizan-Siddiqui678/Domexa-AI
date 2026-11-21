import '../../core/constants/app_constants.dart';
import '../../core/utils/json_utils.dart';
import 'material_model.dart';

class CostResult {
  final double plotArea, builtArea, grey, finishing, labor, total, perSqft;
  final int floors;
  final String budgetRange; // backend value: low / medium / high
  final double greyPct, finishingPct, labourPct, contingency, totalWithContingency;
  final Map<String, dynamic> materialBreakdown;
  final LiveRates? rates;
  final Map<String, String> timeline;
  final List<String> notes;

  const CostResult({
    required this.plotArea, required this.builtArea, required this.grey, required this.finishing,
    required this.labor, required this.total, required this.perSqft, required this.floors,
    required this.budgetRange, required this.greyPct, required this.finishingPct, required this.labourPct,
    required this.contingency, required this.totalWithContingency, required this.materialBreakdown,
    required this.rates, required this.timeline, required this.notes,
  });

  String get budgetKey => AppConstants.budgetKeyFromBackend(budgetRange);

  factory CostResult.fromJson(Map<String, dynamic> j) {
    final s = jmap(j['cost_summary']);
    final total = jd(j['total_cost']);
    return CostResult(
      plotArea: jd(j['plot_area']), builtArea: jd(j['total_built_area']),
      grey: jd(j['grey_structure_cost']), finishing: jd(j['finishing_cost']),
      labor: jd(j['labor_cost']), total: total, perSqft: jd(j['cost_per_sqft']),
      floors: ji(j['num_floors'], 1), budgetRange: js(j['budget_range'], 'medium'),
      greyPct: jd(s['grey_structure_pct']), finishingPct: jd(s['finishing_pct']), labourPct: jd(s['labour_pct']),
      contingency: jd(s['contingency_10pct'], total * 0.10),
      totalWithContingency: jd(s['total_with_contingency'], total * 1.10),
      materialBreakdown: jmap(j['material_breakdown']),
      rates: j['live_rates_used'] is Map ? LiveRates.fromJson(jmap(j['live_rates_used'])) : null,
      timeline: jmap(j['timeline']).map((k, v) => MapEntry(k, '$v')),
      notes: jstrings(j['notes']),
    );
  }
}