/// Cost Estimation Model — matches backend flat response exactly.
///
/// Backend sends:
/// { plot_area, num_floors, total_built_area, grey_structure_cost,
///   finishing_cost, labor_cost, total_cost, cost_per_sqft,
///   budget_range, cost_summary{}, material_breakdown{},
///   timeline{}, notes[] }

class CostEstimationModel {
  final double plotArea;
  final int    numFloors;
  final double totalBuiltArea;
  final double greyStructureCost;
  final double finishingCost;
  final double laborCost;
  final double totalCost;
  final double costPerSqft;
  final String budgetRange;
  final CostSummary      costSummary;
  final MaterialBreakdown materialBreakdown;
  final Timeline         timeline;
  final List<String>     notes;

  CostEstimationModel({
    required this.plotArea,
    required this.numFloors,
    required this.totalBuiltArea,
    required this.greyStructureCost,
    required this.finishingCost,
    required this.laborCost,
    required this.totalCost,
    required this.costPerSqft,
    required this.budgetRange,
    required this.costSummary,
    required this.materialBreakdown,
    required this.timeline,
    required this.notes,
  });

  factory CostEstimationModel.fromJson(Map<String, dynamic> json) {
    final total  = (json['total_cost']          as num?)?.toDouble() ?? 0;
    final grey   = (json['grey_structure_cost'] as num?)?.toDouble() ?? 0;
    final fin    = (json['finishing_cost']      as num?)?.toDouble() ?? 0;
    final labour = (json['labor_cost']          as num?)?.toDouble() ?? 0;

    return CostEstimationModel(
      plotArea:          (json['plot_area']        as num?)?.toDouble() ?? 0,
      numFloors:          json['num_floors']        as int?              ?? 1,
      totalBuiltArea:    (json['total_built_area'] as num?)?.toDouble() ?? 0,
      greyStructureCost: grey,
      finishingCost:     fin,
      laborCost:         labour,
      totalCost:         total,
      costPerSqft:       (json['cost_per_sqft']    as num?)?.toDouble() ?? 0,
      budgetRange:        json['budget_range']      as String?           ?? 'medium',
      costSummary:       CostSummary.fromJson(
        json['cost_summary'] as Map<String, dynamic>? ?? {},
        totalCost: total, greyCost: grey, finCost: fin, labCost: labour,
      ),
      materialBreakdown: MaterialBreakdown.fromJson(
        json['material_breakdown'] as Map<String, dynamic>? ?? {},
      ),
      timeline: Timeline.fromJson(
        json['timeline'] as Map<String, dynamic>? ?? {},
      ),
      notes: List<String>.from(json['notes'] ?? []),
    );
  }

  // Helpers used by UI progress bars
  double get structurePct => totalCost > 0 ? (greyStructureCost / totalCost) * 100 : 0;
  double get finishingPct => totalCost > 0 ? (finishingCost     / totalCost) * 100 : 0;
  double get laborPct     => totalCost > 0 ? (laborCost         / totalCost) * 100 : 0;
}

// ─── CostSummary ──────────────────────────────────────────────────────────────
class CostSummary {
  final double greyStructurePct;
  final double finishingPct;
  final double labourPct;
  final double contingency10Pct;
  final double totalWithContingency;

  // Legacy aliases used by cost_screen.dart range boxes
  final double lowEstimate;
  final double midEstimate;
  final double highEstimate;

  CostSummary({
    required this.greyStructurePct,
    required this.finishingPct,
    required this.labourPct,
    required this.contingency10Pct,
    required this.totalWithContingency,
    required this.lowEstimate,
    required this.midEstimate,
    required this.highEstimate,
  });

  factory CostSummary.fromJson(
      Map<String, dynamic> json, {
        double totalCost = 0,
        double greyCost  = 0,
        double finCost   = 0,
        double labCost   = 0,
      }) {
    final contingency     = (json['contingency_10pct']        as num?)?.toDouble() ?? totalCost * 0.10;
    final withContingency = (json['total_with_contingency']   as num?)?.toDouble() ?? totalCost * 1.10;
    return CostSummary(
      greyStructurePct:     (json['grey_structure_pct'] as num?)?.toDouble() ?? 0,
      finishingPct:         (json['finishing_pct']      as num?)?.toDouble() ?? 0,
      labourPct:            (json['labour_pct']         as num?)?.toDouble() ?? 0,
      contingency10Pct:     contingency,
      totalWithContingency: withContingency,
      lowEstimate:          greyCost,
      midEstimate:          totalCost,
      highEstimate:         withContingency,
    );
  }
}

// ─── MaterialBreakdown ────────────────────────────────────────────────────────
class MaterialBreakdown {
  final int    bricksQty;
  final double bricksCost;
  final int    cementQty;
  final double cementCost;
  final int    steelQty;
  final double steelCost;
  final double sandCrushCost;
  final String note;

  // Legacy list used by screens that loop over structural items
  final List<MaterialBreakdownItem> structural;
  final List<MaterialBreakdownItem> finishing;
  final List<MaterialBreakdownItem> plumbing;
  final List<MaterialBreakdownItem> electrical;

  MaterialBreakdown({
    required this.bricksQty,
    required this.bricksCost,
    required this.cementQty,
    required this.cementCost,
    required this.steelQty,
    required this.steelCost,
    required this.sandCrushCost,
    required this.note,
    this.structural = const [],
    this.finishing  = const [],
    this.plumbing   = const [],
    this.electrical = const [],
  });

  factory MaterialBreakdown.fromJson(Map<String, dynamic> json) {
    final bricksQty  = (json['bricks_qty']     as num?)?.toInt()    ?? 0;
    final bricksCost = (json['bricks_cost']    as num?)?.toDouble() ?? 0;
    final cementQty  = (json['cement_qty']     as num?)?.toInt()    ?? 0;
    final cementCost = (json['cement_cost']    as num?)?.toDouble() ?? 0;
    final steelQty   = (json['steel_qty']      as num?)?.toInt()    ?? 0;
    final steelCost  = (json['steel_cost']     as num?)?.toDouble() ?? 0;
    final sandCrush  = (json['sand_crush_cost'] as num?)?.toDouble() ?? 0;

    final structural = <MaterialBreakdownItem>[
      if (bricksQty > 0) MaterialBreakdownItem(
          item: 'Bricks (A Class)', quantity: bricksQty, unit: 'pieces',
          unitPrice: bricksQty > 0 ? bricksCost / bricksQty : 0, totalPkr: bricksCost),
      if (cementQty > 0) MaterialBreakdownItem(
          item: 'Cement OPC (50kg bags)', quantity: cementQty, unit: 'bags',
          unitPrice: cementQty > 0 ? cementCost / cementQty : 0, totalPkr: cementCost),
      if (steelQty > 0) MaterialBreakdownItem(
          item: 'Steel Sariya Grade 60', quantity: steelQty, unit: 'kg',
          unitPrice: steelQty > 0 ? steelCost / steelQty : 0, totalPkr: steelCost),
      if (sandCrush > 0) MaterialBreakdownItem(
          item: 'Sand & Crush', quantity: 1, unit: 'lot',
          unitPrice: sandCrush, totalPkr: sandCrush),
    ];

    return MaterialBreakdown(
      bricksQty:     bricksQty,
      bricksCost:    bricksCost,
      cementQty:     cementQty,
      cementCost:    cementCost,
      steelQty:      steelQty,
      steelCost:     steelCost,
      sandCrushCost: sandCrush,
      note:          json['note'] as String? ?? '',
      structural:    structural,
    );
  }
}

class MaterialBreakdownItem {
  final String item;
  final int    quantity;
  final String unit;
  final double unitPrice;
  final double totalPkr;
  MaterialBreakdownItem({
    required this.item, required this.quantity,
    required this.unit, required this.unitPrice, required this.totalPkr,
  });
}

// ─── Timeline ─────────────────────────────────────────────────────────────────
class Timeline {
  final String surveyLayout;
  final String excavationFoundation;
  final String greyStructure;
  final String plaster;
  final String finishing;
  final String total;

  // Aliases used by cost_screen.dart _buildTimelineCard
  final String foundation;
  final String totalDuration;

  Timeline({
    required this.surveyLayout,
    required this.excavationFoundation,
    required this.greyStructure,
    required this.plaster,
    required this.finishing,
    required this.total,
    required this.foundation,
    required this.totalDuration,
  });

  factory Timeline.fromJson(Map<String, dynamic> json) {
    final excavation = json['excavation_foundation'] as String? ?? '3–4 weeks';
    final total      = json['total']          as String?
        ?? json['total_duration'] as String?
        ?? json['total_months']   as String?
        ?? '6–8 months';
    final grey      = json['grey_structure']  as String? ?? '10–14 weeks';
    final finishing = json['finishing']       as String? ?? '6–8 weeks';
    return Timeline(
      surveyLayout:         json['survey_layout'] as String? ?? '1–2 weeks',
      excavationFoundation: excavation,
      greyStructure:        grey,
      plaster:              json['plaster']   as String? ?? '3–4 weeks',
      finishing:            finishing,
      total:                total,
      foundation:           excavation,
      totalDuration:        total,
    );
  }
}
