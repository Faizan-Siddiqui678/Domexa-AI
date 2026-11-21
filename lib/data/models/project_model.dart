import 'plot_input_model.dart';

/// A saved project (Firestore: users/{uid}/projects/{id}).
class ProjectModel {
  final String id, name, city, budget, createdAt;
  final PlotInputModel plot;
  final double? totalCost;
  const ProjectModel({
    required this.id, required this.name, required this.city, required this.budget,
    required this.createdAt, required this.plot, this.totalCost,
  });

  Map<String, dynamic> toMap() => {
    'name': name, 'city': city, 'budget': budget, 'created_at': createdAt,
    'plot': plot.toJson(), 'total_cost': totalCost,
  };

  factory ProjectModel.fromMap(String id, Map<String, dynamic> m) => ProjectModel(
    id: id,
    name: (m['name'] as String?) ?? 'My House Plan',
    city: (m['city'] as String?) ?? 'lahore',
    budget: (m['budget'] as String?) ?? 'standard',
    createdAt: (m['created_at'] as String?) ?? '',
    plot: PlotInputModel.fromJson(Map<String, dynamic>.from((m['plot'] as Map?) ?? {})),
    totalCost: (m['total_cost'] as num?)?.toDouble(),
  );
}