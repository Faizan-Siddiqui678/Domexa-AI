import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/plot_input_viewmodel.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          'Material Guide',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<PlotInputViewModel>(
        builder: (context, vm, child) {
          final plotArea = vm.plotArea;
          final numFloors = vm.numFloors;
          final builtArea = plotArea * 0.7 * numFloors;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(plotArea, numFloors, builtArea),
                const SizedBox(height: 20),
                _buildMaterialTable(builtArea),
                const SizedBox(height: 20),
                _buildTipsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(double plotArea, int numFloors, double builtArea) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _infoRow('Plot Area', '${plotArea.toInt()} sqft (${(plotArea / 225).toStringAsFixed(1)} Marla)'),
          _infoRow('Number of Floors', '$numFloors'),
          _infoRow('Built Area', '${builtArea.toInt()} sqft'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMaterialTable(double builtArea) {
    final List<Map<String, dynamic>> materials = [
      {'name': '🧱 Cement', 'unit': 'bags', 'quantity': (builtArea * 0.45).toInt()},
      {'name': '⚙️ Steel', 'unit': 'kg', 'quantity': (builtArea * 3.5).toInt()},
      {'name': '🧱 Bricks', 'unit': 'pieces', 'quantity': (builtArea * 22.5).toInt()},
      {'name': '🏖️ Sand', 'unit': 'cft', 'quantity': (builtArea * 0.8).toInt()},
      {'name': '🪨 Crush', 'unit': 'cft', 'quantity': (builtArea * 0.6).toInt()},
      {'name': '🪨 Floor Tiles', 'unit': 'sqft', 'quantity': (builtArea * 1.1).toInt()},
      {'name': '🎨 Paint', 'unit': 'gallons', 'quantity': (builtArea * 0.03).toInt()},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Estimated Material Quantities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const Divider(height: 0, color: AppColors.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: materials.length,
            separatorBuilder: (_, __) => const Divider(height: 0, color: AppColors.border),
            itemBuilder: (context, index) {
              final material = materials[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(material['name'] as String, style: const TextStyle(color: AppColors.textPrimary)),
                    Text(
                      '${material['quantity']} ${material['unit']}',
                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outlined, color: AppColors.info, size: 20),
              SizedBox(width: 8),
              Text(
                'Material Tips',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('• Add 10-15% extra for wastage and breakage', style: TextStyle(fontSize: 12)),
          const Text('• Buy PSQCA certified materials only', style: TextStyle(fontSize: 12)),
          const Text('• Prices vary by city and season', style: TextStyle(fontSize: 12)),
          const Text('• Get multiple quotes before purchasing', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}