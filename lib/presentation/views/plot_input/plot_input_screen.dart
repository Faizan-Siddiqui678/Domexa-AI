import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/plot_input_viewmodel.dart';

class PlotInputScreen extends StatefulWidget {
  const PlotInputScreen({super.key});

  @override
  State<PlotInputScreen> createState() => _PlotInputScreenState();
}

class _PlotInputScreenState extends State<PlotInputScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PlotInputViewModel>(context);

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
          'Design Your Home',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlotSection(vm),
            const SizedBox(height: 20),
            _buildStructureSection(vm),
            const SizedBox(height: 20),
            _buildStyleSection(vm),
            const SizedBox(height: 20),
            _buildAdditionalRoomsSection(vm),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => _generateLayout(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: vm.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Generate Layout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlotSection(PlotInputViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.crop_free, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Plot Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Plot Area (sqft)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.plotArea.toInt()} sqft',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      '≈ ${vm.plotMarla.toStringAsFixed(1)} Marla',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Built Area', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.builtArea.toInt()} sqft',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      '≈ ${(vm.builtArea / 225).toStringAsFixed(1)} Marla built',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: vm.marlaPresets.keys.map((preset) {
              return FilterChip(
                label: Text(preset),
                selected: vm.selectedPreset == preset,
                onSelected: (_) => vm.setSelectedPreset(preset),
                backgroundColor: AppColors.bgInput,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: vm.selectedPreset == preset ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Slider(
            value: vm.plotArea,
            min: 500,
            max: 10000,
            divisions: 19,
            label: '${vm.plotArea.toInt()} sqft',
            onChanged: vm.setPlotArea,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStructureSection(PlotInputViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apartment, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Structure',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSlider('Floors', vm.numFloors, 1, 4, vm.setNumFloors),
          _buildSlider('Bedrooms', vm.bedrooms, 1, 8, vm.setBedrooms),
          _buildSlider('Bathrooms', vm.bathrooms, 1, 6, vm.setBathrooms),
          _buildSlider('Kitchens', vm.kitchen, 1, 2, vm.setKitchen),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, int value, int min, int max, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.toInt()),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSection(PlotInputViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Design Style',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: vm.availableStyles.map((style) {
              return ChoiceChip(
                label: Text(style.toUpperCase()),
                selected: vm.houseStyle == style,
                onSelected: (_) => vm.setHouseStyle(style),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.bgInput,
                labelStyle: TextStyle(
                  color: vm.houseStyle == style ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalRoomsSection(PlotInputViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Additional Rooms',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSwitchTile('Drawing Room', vm.hasDrawingRoom, vm.setDrawingRoom),
          _buildSwitchTile('Dining Room', vm.hasDiningRoom, vm.setDiningRoom),
          _buildSwitchTile('Garage', vm.hasGarage, vm.setGarage),
          _buildSwitchTile('Basement', vm.hasBasement, vm.setBasement),
          _buildSwitchTile('Gallery/Corridor', vm.hasGallery, vm.setGallery),
          _buildSwitchTile('Open Area/Terrace', vm.hasOpenArea, vm.setOpenArea),
          _buildSwitchTile('Servant Quarter', vm.hasServantQuarter, vm.setServantQuarter),
          _buildSwitchTile('Store Room', vm.hasStoreRoom, vm.setStoreRoom),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  void _generateLayout(PlotInputViewModel vm) async {
    FocusScope.of(context).unfocus();
    await vm.generateLayout();
    if (vm.generatedLayout != null && mounted) {
      Navigator.pushReplacementNamed(context, '/layout');
    }
  }
}