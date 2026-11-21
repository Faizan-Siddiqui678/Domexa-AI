import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/export_model.dart';
import '../../data/models/plot_input_model.dart';
import '../../data/services/api_service.dart';
import 'base_viewmodel.dart';
import 'cost_viewmodel.dart';

class ExportViewModel extends BaseViewModel {
  ExportViewModel(this._api);
  final ApiService _api;

  ExportResult? result;
  String step = '';
  double? lastTotal;

  Future<void> export({
    required PlotInputModel plot, required String budget, required String city,
    required String projectName, required String ownerName, required CostViewModel costs,
  }) async {
    if (isLoading) return;
    result = null;
    await run(() async {
      step = 'Calculating costs...';
      notifyListeners();
      final cost = await costs.ensure(plot, city, budget);
      lastTotal = cost.total;
      step = 'Building your PDF...';
      notifyListeners();
      final r = await _api.exportPdf(projectName: projectName, ownerName: ownerName, plot: plot, cost: cost);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${r.filename}');
      await file.writeAsBytes(r.bytes);
      return ExportResult(filename: r.filename, bytes: r.bytes, savedPath: file.path);
    }, (r) => result = r);
  }

  Future<void> share() async {
    final p = result?.savedPath;
    if (p == null) return;
    await Share.shareXFiles([XFile(p, mimeType: 'application/pdf')], subject: 'Domexa house plan report');
  }
}