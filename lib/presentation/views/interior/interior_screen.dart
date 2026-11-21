import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/interior_design_model.dart';
import '../../viewmodels/interior_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../widgets/common_widgets.dart';

class InteriorScreen extends StatefulWidget {
  const InteriorScreen({super.key});
  @override
  State<InteriorScreen> createState() => _InteriorScreenState();
}

class _InteriorScreenState extends State<InteriorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _size;
  final _scroll = ScrollController();
  final _resultKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final vm = context.read<InteriorViewModel>();
    _size = TextEditingController(text: vm.roomSize.round().toString());
    if (vm.design == null) {
      final p = context.read<PlotInputViewModel>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.syncWithProject(projectCity: p.city, projectBudget: p.budget, houseStyle: p.plot.houseStyle);
      });
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final vm = context.read<InteriorViewModel>();
    vm.update(roomSize: double.parse(_size.text));
    await vm.generate();
    // Bring the new result into view (visibility of the outcome).
    if (mounted && _resultKey.currentContext != null) {
      Scrollable.ensureVisible(_resultKey.currentContext!, duration: const Duration(milliseconds: 400));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InteriorViewModel>();
    final d = vm.design;

    return Scaffold(
      appBar: AppBar(title: const Text('Interior design')),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _form,
            child: SectionCard(
              title: 'Describe the room',
              icon: Icons.chair_outlined,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Room type', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                OptionChips(options: AppConstants.roomTypes, selected: vm.roomType, onSelected: (v) => vm.update(roomType: v)),
                const SizedBox(height: 16),
                const Text('Style', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                OptionChips(
                  options: {for (final s in AppConstants.styles) s: Fmt.title(s)},
                  selected: vm.style,
                  onSelected: (v) => vm.update(style: v),
                ),
                const SizedBox(height: 16),
                const Text('Budget', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                BudgetSelector(value: vm.budget, keys: AppConstants.interiorBudgetKeys, onChanged: (v) => vm.update(budget: v)),
                const SizedBox(height: 16),
                CityDropdown(value: vm.city, cities: AppConstants.interiorCities, onChanged: (v) => vm.update(city: v)),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _size,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Room size', suffixText: 'sqft'),
                  validator: (v) => Validators.number(v, AppConstants.minRoomSize, AppConstants.maxRoomSize, 'Room size', 'sqft'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Also create a room picture', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('AI image - adds roughly 20-40 seconds. Turn off for a faster text-only design.'),
                  value: vm.generateImage,
                  onChanged: (v) => vm.update(generateImage: v),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: vm.isLoading ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(vm.isLoading ? 'Designing...' : 'Generate design'),
                ),
              ]),
            ),
          ),
          Container(key: _resultKey),
          if (vm.isLoading)
            SizedBox(
              height: 260,
              child: LoadingPanel(
                messages: vm.generateImage
                    ? const ['Choosing colours and furniture...', 'Pricing items in PKR...', 'Painting the room picture (slowest step)...']
                    : const ['Choosing colours and furniture...', 'Pricing items in PKR...'],
                hint: vm.generateImage ? 'up to ~60 s' : 'about 10-20 s',
                onCancel: vm.cancel,
              ),
            )
          else if (vm.hasError)
            ErrorPanel(message: vm.errorMessage ?? 'Could not create the design.', onRetry: vm.canRetry ? vm.generate : null)
          else if (d != null)
              ..._result(context, d),
        ],
      ),
    );
  }

  List<Widget> _result(BuildContext context, InteriorDesign d) => [
    if (d.image != null)
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.memory(d.image!, fit: BoxFit.cover, gaplessPlayback: true, semanticLabel: 'AI generated picture of the ${Fmt.title(d.roomType)}'),
        ),
      )
    else if (d.imageError.isNotEmpty)
      InfoNote('${d.imageError}. Your written design is ready below; you can try the picture again later.', tone: NoteTone.warning, title: 'Room picture unavailable'),
    SectionCard(
      title: d.theme.isEmpty ? '${Fmt.title(d.style)} ${Fmt.title(d.roomType)}' : d.theme,
      icon: Icons.auto_awesome,
      subtitle: d.mood.isEmpty ? null : d.mood,
      child: Wrap(spacing: 12, runSpacing: 12, children: [for (final s in d.swatches) _SwatchTile(s)]),
    ),
    if (d.furniture.isNotEmpty)
      SectionCard(
        title: 'Furniture',
        icon: Icons.weekend_outlined,
        child: Column(children: [
          for (var i = 0; i < d.furniture.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            _FurnitureRow(item: d.furniture[i]),
          ],
        ]),
      ),
    _MapSection('Flooring', Icons.grid_view, d.flooring),
    _MapSection('Lighting', Icons.light_outlined, d.lighting),
    _MapSection('Ceiling', Icons.vertical_align_top, d.ceiling),
    _MapSection('Windows and doors', Icons.sensor_door_outlined, d.windowsDoors),
    if (d.acPlacement.isNotEmpty) InfoNote(d.acPlacement, title: 'AC placement'),
    if (d.specialFeatures.isNotEmpty)
      SectionCard(title: 'Special features', icon: Icons.stars_outlined, child: _Bullets(d.specialFeatures)),
    if (d.tips.isNotEmpty) SectionCard(title: 'Design tips', icon: Icons.lightbulb_outline, child: _Bullets(d.tips)),
    if (d.estimatedCost.isNotEmpty)
      SectionCard(
        title: 'Estimated cost to furnish and finish',
        icon: Icons.payments_outlined,
        child: Column(children: [for (final e in d.estimatedCost.entries) KeyValueRow(Fmt.title(e.key), '${e.value}')]),
      ),
    const SizedBox(height: 24),
  ];
}

Color? _hex(String h) {
  final t = h.replaceAll('#', '').trim();
  if (t.length != 6) return null;
  final v = int.tryParse(t, radix: 16);
  return v == null ? null : Color(0xFF000000 | v);
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile(this.s);
  final Swatch s;
  @override
  Widget build(BuildContext context) {
    final c = _hex(s.hex);
    return SizedBox(
      width: 150,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: c ?? AppColors.border, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('${s.color}${s.hex.isNotEmpty ? ' ${s.hex}' : ''}', style: Theme.of(context).textTheme.bodySmall),
            if (s.brand.isNotEmpty) Text('${s.brand}${s.price.isNotEmpty ? ' - ${s.price}' : ''}', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ]),
    );
  }
}

class _FurnitureRow extends StatelessWidget {
  const _FurnitureRow({required this.item});
  final FurnitureItem item;
  @override
  Widget build(BuildContext context) {
    final label = Fmt.title(item.priority);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(item.item, style: const TextStyle(fontWeight: FontWeight.w800))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: item.priority == 'essential' ? AppColors.warningBg : AppColors.infoBg, borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: item.priority == 'essential' ? AppColors.warning : AppColors.info)),
        ),
      ]),
      if (item.description.isNotEmpty) Text(item.description),
      if (item.price.isNotEmpty) Text(item.price, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text([
        if (item.dimensions.isNotEmpty) item.dimensions,
        if (item.material.isNotEmpty) item.material,
        if (item.brand.isNotEmpty) item.brand,
        if (item.placement.isNotEmpty) 'Place: ${item.placement}',
      ].join('  -  '), style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<String> items;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [for (final t in items) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('-  $t'))],
  );
}

/// Renders a free-form map (flooring, lighting, ...) as label/value rows.
class _MapSection extends StatelessWidget {
  const _MapSection(this.title, this.icon, this.data);
  final String title;
  final IconData icon;
  final Map<String, dynamic> data;

  List<MapEntry<String, String>> _rows(Map<String, dynamic> m, [String prefix = '']) {
    final out = <MapEntry<String, String>>[];
    m.forEach((k, v) {
      final label = '$prefix${Fmt.title(k)}';
      if (v is Map) {
        out.addAll(_rows(Map<String, dynamic>.from(v), '$label: '));
      } else if (v is List) {
        final parts = v.map((e) => e is Map ? e.values.join(', ') : '$e').where((e) => e.isNotEmpty).join('\n');
        if (parts.isNotEmpty) out.add(MapEntry(label, parts));
      } else if ('$v'.isNotEmpty && v != null) {
        out.add(MapEntry(label, '$v'));
      }
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows(data);
    if (rows.isEmpty) return const SizedBox.shrink();
    return SectionCard(title: title, icon: icon, child: Column(children: [for (final r in rows) KeyValueRow(r.key, r.value)]));
  }
}