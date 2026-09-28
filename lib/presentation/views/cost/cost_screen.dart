import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/plot_input_viewmodel.dart';

class CostScreen extends StatelessWidget {
  const CostScreen({super.key});

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
          'Cost Estimator',
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

          final economyRate = 2800;
          final standardRate = 4500;
          final premiumRate = 8000;

          final economyTotal = builtArea * economyRate;
          final standardTotal = builtArea * standardRate;
          final premiumTotal = builtArea * premiumRate;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(plotArea, numFloors, builtArea),
                const SizedBox(height: 20),
                _buildCostCards(economyTotal, standardTotal, premiumTotal, builtArea),
                const SizedBox(height: 20),
                _buildBreakdownCard(standardTotal),
                const SizedBox(height: 20),
                _buildNotesCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double plotArea, int numFloors, double builtArea) {
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

  Widget _buildCostCards(double economy, double standard, double premium, double builtArea) {
    return Row(
      children: [
        Expanded(
          child: _costCard('Economy', economy, (economy / builtArea).toInt(), Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _costCard('Standard', standard, (standard / builtArea).toInt(), Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _costCard('Premium', premium, (premium / builtArea).toInt(), Colors.red),
        ),
      ],
    );
  }

  Widget _costCard(String title, double amount, int perSqft, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'PKR $perSqft/sqft',
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(double total) {
    final greyStructure = total * 0.45;
    final finishing = total * 0.30;
    final labor = total * 0.15;
    final utilities = total * 0.10;

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
            'Cost Breakdown (Standard Budget)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _breakdownRow('🏗️ Grey Structure', greyStructure, total),
          _breakdownRow('✨ Finishing', finishing, total),
          _breakdownRow('👷 Labor', labor, total),
          _breakdownRow('🔧 Utilities', utilities, total),
          const Divider(color: AppColors.border, height: 16),
          _breakdownRow('Total', total, total, isBold: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Add 15% contingency for unforeseen expenses',
                    style: TextStyle(fontSize: 12, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double amount, double total, {bool isBold = false}) {
    final percentage = (amount / total * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          Text(
            '${_formatCurrency(amount)} ($percentage%)',
            style: TextStyle(
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
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
                'Important Notes',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('• Prices are based on current market rates (March 2025)', style: TextStyle(fontSize: 12)),
          const Text('• Costs vary by city (Lahore/Karachi/Islamabad)', style: TextStyle(fontSize: 12)),
          const Text('• Add 15% contingency to total budget', style: TextStyle(fontSize: 12)),
          const Text('• WAPDA/Gas/PTCL connections billed separately', style: TextStyle(fontSize: 12)),
          const Text('• Architect fees not included (typically 3-5%)', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return 'PKR ${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      return 'PKR ${(amount / 100000).toStringAsFixed(1)} Lac';
    }
    return 'PKR ${amount.toStringAsFixed(0)}';
  }
}