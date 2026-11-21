import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/plot_input_model.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../widgets/common_widgets.dart';
import '../layout/layout_display_screen.dart';

/// [editOnly] = opened from "Edit" on another screen: just changes the project and returns.
class PlotInputScreen extends StatefulWidget {
  const PlotInputScreen({super.key, this.editOnly = false});
  final bool editOnly;
  @override
  State<PlotInputScreen> createState() => _PlotInputScreenState();
}

class _PlotInputScreenState extends State<PlotInputScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _area;

  @override
  void initState() {
    super.initState();
    _area = TextEditingController(text: context.read<PlotInputViewModel>().plot.plotArea.round().toString());
  }

  @override
  void dispose() {
    _area.dispose();
    super.dispose();
  }

  void _syncArea(double v) => _area.text = v.round().toString();

  Future<void> _reset() async {
    final vm = context.read<PlotInputViewModel>();
    final prev = vm.toProject();
    final messenger = ScaffoldMessenger.of(context);
    vm.reset();
    _syncArea(vm.plot.plotArea);
    messenger.showSnackBar(SnackBar(
      content: const Text('Reset to defaults'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          vm.load(prev);
          _syncArea(prev.plot.plotArea);
        },
      ),
    ));
  }

  void _continue() {
    if (!(_form.currentState?.validate() ?? false)) return;
    if (widget.editOnly) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LayoutDisplayScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlotInputViewModel>();
    final p = vm.plot;
    final styleOptions = {for (final s in AppConstants.styles) s: Fmt.title(s)};

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editOnly ? 'Project details' : 'Design your home'),
        actions: [TextButton(onPressed: _reset, child: const Text('Reset'))],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: p.isValid ? _continue : null,
            icon: Icon(widget.editOnly ? Icons.check : Icons.auto_awesome),
            label: Text(widget.editOnly ? 'Done' : 'Generate layout'),
          ),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final w in p.warnings) InfoNote(w, tone: NoteTone.warning),

            SectionCard(
              title: 'Plot size',
              icon: Icons.crop_square,
              subtitle: 'Pick a common size or type your own.',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final pr in AppConstants.plotPresets)
                    ChoiceChip(
                      label: Text(pr.label),
                      selected: p.plotArea == pr.sqft,
                      onSelected: (_) {
                        _syncArea(pr.sqft);
                        vm.setPlotArea(pr.sqft);
                      },
                    ),
                ]),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _area,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Plot area',
                    suffixText: 'sqft',
                    helperText: '= ${Fmt.marla(p.plotArea)} Marla  -  about ${Fmt.sqft(p.builtArea)} built across ${p.numFloors} floor${p.numFloors > 1 ? 's' : ''}',
                  ),
                  validator: (v) => Validators.number(v, AppConstants.minPlotArea, AppConstants.maxPlotArea, 'Plot area', 'sqft'),
                  onChanged: (v) {
                    final n = double.tryParse(v);
                    if (n != null && n >= AppConstants.minPlotArea && n <= AppConstants.maxPlotArea) vm.setPlotArea(n);
                  },
                ),
              ]),
            ),

            SectionCard(
              title: 'Structure',
              icon: Icons.apartment,
              child: Column(children: [
                StepperField(label: 'Floors', value: p.numFloors, min: AppConstants.minFloors, max: AppConstants.maxFloors, onChanged: vm.setFloors),
                const Divider(height: 18),
                StepperField(label: 'Bedrooms', value: p.bedrooms, min: AppConstants.minBedrooms, max: AppConstants.maxBedrooms, onChanged: vm.setBedrooms),
                const Divider(height: 18),
                StepperField(label: 'Bathrooms', value: p.bathrooms, min: AppConstants.minBathrooms, max: AppConstants.maxBathrooms, onChanged: vm.setBathrooms),
                const Divider(height: 18),
                StepperField(label: 'Kitchens', value: p.kitchen, min: AppConstants.minKitchens, max: AppConstants.maxKitchens, onChanged: vm.setKitchens),
              ]),
            ),

            SectionCard(
              title: 'Design style',
              icon: Icons.palette_outlined,
              child: OptionChips(options: styleOptions, selected: p.houseStyle, onSelected: vm.setStyle),
            ),

            SectionCard(
              title: 'Additional rooms',
              icon: Icons.add_circle_outline,
              child: Column(children: [
                for (final e in kExtraRooms)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(e.hint),
                    value: p.extra(e.key),
                    onChanged: (v) => vm.setExtra(e.key, v),
                  ),
              ]),
            ),

            SectionCard(
              title: 'Location and budget',
              icon: Icons.location_on_outlined,
              subtitle: 'Used for live prices in Materials, Cost and the PDF report.',
              child: Column(children: [
                CityDropdown(value: vm.city, onChanged: vm.setCity),
                const SizedBox(height: 14),
                BudgetSelector(value: vm.budget, onChanged: vm.setBudget),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}