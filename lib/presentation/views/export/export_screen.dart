import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/export_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../viewmodels/cost_viewmodel.dart';
import '../../../core/constants/color_constants.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _projectNameCtrl = TextEditingController(text: 'My House Plan');
  final _ownerNameCtrl = TextEditingController();

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExportViewModel()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Project',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                'Generate PDF report',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        body: Consumer3<ExportViewModel, PlotInputViewModel, CostViewModel>(
          builder: (ctx, exportVm, plotVm, costVm, _) {
            if (exportVm.success) return _buildSuccess(exportVm);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildProjectDetails(plotVm, costVm),
                  const SizedBox(height: 24),
                  _buildInputSection(),
                  const SizedBox(height: 24),
                  _buildPdfContents(),
                  const SizedBox(height: 24),
                  if (exportVm.errorMessage != null) _buildError(exportVm.errorMessage!),
                  _buildExportButton(exportVm, plotVm, costVm),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Report',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                'Professional PDF with your complete house plan',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDetails(PlotInputViewModel plotVm, CostViewModel costVm) {
    final hasLayout = plotVm.generatedLayout != null;
    final hasCost = costVm.costEstimation != null;

    final items = [
      ['Plot Area', hasLayout ? '${plotVm.plotArea.toInt()} sq ft' : 'Not set'],
      ['Floors', hasLayout ? '${plotVm.numFloors}' : 'Not set'],
      ['Bedrooms', hasLayout ? '${plotVm.bedrooms}' : 'Not set'],
      ['Bathrooms', hasLayout ? '${plotVm.bathrooms}' : 'Not set'],
      ['Style', hasLayout ? plotVm.houseStyle.toUpperCase() : 'Not set'],
      ['Total Cost', hasCost ? _formatCurrency(costVm.costEstimation!.totalCost) : 'Not estimated'],
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item[0], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text(item[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Details',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _inputField(_projectNameCtrl, 'Project Name', Icons.home_outlined),
        const SizedBox(height: 12),
        _inputField(_ownerNameCtrl, 'Owner Name (Optional)', Icons.person_outlined),
      ],
    );
  }

  Widget _inputField(TextEditingController c, String hint, IconData icon) {
    return TextField(
      controller: c,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildPdfContents() {
    final sections = [
      [Icons.map_outlined, 'House Layout', '2D floor plan with room dimensions'],
      [Icons.construction_outlined, 'Material List', 'Recommended materials with PKR prices'],
      [Icons.calculate_outlined, 'Cost Breakdown', 'Grey structure, finishing & labor'],
      [Icons.palette_outlined, 'Interior Design', 'Color themes and furniture suggestions'],
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PDF Contents',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          ...sections.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s[0] as IconData, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s[1] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text(s[2] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExportButton(ExportViewModel vm, PlotInputViewModel plotVm, CostViewModel costVm) {
    final hasLayout = plotVm.generatedLayout != null;
    final hasCost = costVm.costEstimation != null;
    final canExport = hasLayout && hasCost;

    return GestureDetector(
      onTap: (vm.isLoading || !canExport) ? null : () {
        vm.exportPdf(
          projectName: _projectNameCtrl.text.trim().isEmpty ? 'My House Plan' : _projectNameCtrl.text.trim(),
          ownerName: _ownerNameCtrl.text.trim(),
          plotVm: plotVm,
          costData: costVm.costEstimation!,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: (vm.isLoading || !canExport) ? null : AppColors.primaryGradient,
          color: (vm.isLoading || !canExport) ? AppColors.border : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: (vm.isLoading || !canExport) ? null : AppColors.cardShadow,
        ),
        child: Center(
          child: vm.isLoading
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Generating PDF…', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_outlined,
                color: canExport ? Colors.white : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                canExport ? 'Export PDF Report' : 'Complete layout & cost first',
                style: TextStyle(
                  color: canExport ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(ExportViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              'PDF Exported!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Saved to:\n${vm.savedPath ?? "Documents folder"}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: vm.reset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Export Another',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(color: AppColors.error, fontSize: 13))),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)} Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)} Lac';
    return amount.toStringAsFixed(0);
  }
}