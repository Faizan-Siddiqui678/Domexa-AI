import 'plot_input_model.dart';
import 'layout_model.dart';
import 'material_model.dart';
import 'cost_estimation_model.dart';
import 'interior_design_model.dart';

/// Project Model for managing complete house projects

class ProjectModel {
  final String projectId;
  final String projectName;
  final DateTime createdAt;
  final DateTime lastModified;
  final String status;
  final PlotInputModel plotData;
  final LayoutModel? layoutData;
  final MaterialModel? materialsData;
  final CostEstimationModel? costEstimation;
  final List<InteriorDesignModel>? interiorDesigns;
  final String? thumbnail;

  ProjectModel({
    required this.projectId,
    required this.projectName,
    required this.createdAt,
    required this.lastModified,
    required this.status,
    required this.plotData,
    this.layoutData,
    this.materialsData,
    this.costEstimation,
    this.interiorDesigns,
    this.thumbnail,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId:   json['project_id'] as String,
      projectName: json['project_name'] as String,
      createdAt:   DateTime.parse(json['created_at']),
      lastModified: DateTime.parse(json['last_modified']),
      status:      json['status'] as String,
      plotData:    PlotInputModel.fromJson(json['plot_data']),
      layoutData:  json['layout_data'] != null
          ? LayoutModel.fromJson(json['layout_data']) : null,
      materialsData: json['materials_data'] != null
          ? MaterialModel.fromJson(json['materials_data']) : null,
      costEstimation: json['cost_estimation'] != null
          ? CostEstimationModel.fromJson(json['cost_estimation']) : null,
      interiorDesigns: json['interior_designs'] != null
          ? (json['interior_designs'] as List)
          .map((d) => InteriorDesignModel.fromJson(d)).toList()
          : null,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id':       projectId,
      'project_name':     projectName,
      'created_at':       createdAt.toIso8601String(),
      'last_modified':    lastModified.toIso8601String(),
      'status':           status,
      'plot_data':        plotData.toJson(),
      'layout_data':      layoutData?.toJson(),
      // MaterialModel and CostEstimationModel stored as simple maps
      'materials_data':   materialsData != null ? {
        'total_estimated_cost': materialsData!.totalMaterialCost,
        'budget_category':      materialsData!.budgetCategory,
        'budget_label':         materialsData!.budgetLabel,
        'climate_advice':       materialsData!.climateAdvice,
        'materials':            materialsData!.materials
            .expand((cat) => cat.items.map((i) => i.toJson()))
            .toList(),
        'summary': materialsData!.summary,
      } : null,
      'cost_estimation':  costEstimation != null ? {
        'plot_area':            costEstimation!.plotArea,
        'num_floors':           costEstimation!.numFloors,
        'total_built_area':     costEstimation!.totalBuiltArea,
        'grey_structure_cost':  costEstimation!.greyStructureCost,
        'finishing_cost':       costEstimation!.finishingCost,
        'labor_cost':           costEstimation!.laborCost,
        'total_cost':           costEstimation!.totalCost,
        'cost_per_sqft':        costEstimation!.costPerSqft,
        'budget_range':         costEstimation!.budgetRange,
        'notes':                costEstimation!.notes,
        'timeline': {
          'foundation':     costEstimation!.timeline.foundation,
          'grey_structure': costEstimation!.timeline.greyStructure,
          'finishing':      costEstimation!.timeline.finishing,
          'total_duration': costEstimation!.timeline.totalDuration,
        },
        'cost_summary': {
          'low_estimate':  costEstimation!.costSummary.lowEstimate,
          'mid_estimate':  costEstimation!.costSummary.midEstimate,
          'high_estimate': costEstimation!.costSummary.highEstimate,
        },
      } : null,
      'interior_designs': interiorDesigns?.map((d) => d.toJson()).toList(),
      'thumbnail':        thumbnail,
    };
  }

  ProjectModel copyWith({
    String? projectName,
    DateTime? lastModified,
    String? status,
    PlotInputModel? plotData,
    LayoutModel? layoutData,
    MaterialModel? materialsData,
    CostEstimationModel? costEstimation,
    List<InteriorDesignModel>? interiorDesigns,
    String? thumbnail,
  }) {
    return ProjectModel(
      projectId:      projectId,
      projectName:    projectName ?? this.projectName,
      createdAt:      createdAt,
      lastModified:   lastModified ?? DateTime.now(),
      status:         status ?? this.status,
      plotData:       plotData ?? this.plotData,
      layoutData:     layoutData ?? this.layoutData,
      materialsData:  materialsData ?? this.materialsData,
      costEstimation: costEstimation ?? this.costEstimation,
      interiorDesigns: interiorDesigns ?? this.interiorDesigns,
      thumbnail:      thumbnail ?? this.thumbnail,
    );
  }

  int get completionPercentage {
    int completed = 1;
    int total = 5;
    if (layoutData != null) completed++;
    if (materialsData != null) completed++;
    if (costEstimation != null) completed++;
    if (interiorDesigns != null && interiorDesigns!.isNotEmpty) completed++;
    return ((completed / total) * 100).round();
  }
}

// Flat getters for ProfileScreen convenience
extension ProjectModelExt on ProjectModel {
  String get id => projectId;
  double get plotArea   => plotData.plotArea;
  int    get numFloors  => plotData.numFloors;
  int    get bedrooms   => plotData.bedrooms;
  String get budgetRange=> plotData.budgetCategory;
  double get totalCost  => costEstimation?.totalCost ?? 0;
}