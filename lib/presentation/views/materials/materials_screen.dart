import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/material_model.dart';
import '../../viewmodels/material_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../widgets/common_widgets.dart';
import '../cost/cost_screen.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlotInputViewModel>();
    final vm = context.watch<MaterialViewModel>();
    // load() de-duplicates identical inputs, so this only fetches when something changed.
    if (!vm.isLoading && !vm.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.read<MaterialViewModel>().load(p.plot, p.budget, p.city);
      });
    }
    final r = vm.result;

    return Scaffold(
      appBar: AppBar(title: const Text('Material guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ProjectSummaryBar(),
          SectionCard(
            title: 'Options',
            icon: Icons.tune,
            child: Column(children: [
              BudgetSelector(
                value: p.budget,
                onChanged: (b) {
                  p.setBudget(b);
                  context.read<MaterialViewModel>().load(p.plot, b, p.city, force: true);
                },
              ),
              const SizedBox(height: 12),
              CityDropdown(
                value: p.city,
                onChanged: (c) {
                  p.setCity(c);
                  context.read<MaterialViewModel>().load(p.plot, p.budget, c, force: true);
                },
              ),
            ]),
          ),
          if (vm.isLoading && r != null) const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator()),
          if (vm.hasError)
            InfoNote(vm.errorMessage ?? 'Could not load materials.', tone: NoteTone.error, title: 'Could not update'),
          if (r == null && vm.isLoading)
            SizedBox(
              height: 300,
              child: LoadingPanel(
                messages: const ["Fetching today's market prices...", 'Calculating quantities...', 'Choosing brands for your budget...'],
                hint: 'usually 5-20 s',
                onCancel: vm.cancel,
              ),
            ),
          if (r == null && vm.hasError)
            ErrorPanel(message: vm.errorMessage ?? 'Could not load materials.', onRetry: () => vm.load(p.plot, p.budget, p.city, force: true)),
          if (r != null) ..._content(context, r, p),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, MaterialResult r, PlotInputViewModel p) {
    final rates = r.rates;
    return [
      Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.budgetLabel, style: const TextStyle(color: Colors.white70)),
          Text(Fmt.pkr(r.total), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          const Text('estimated cost of all materials', style: TextStyle(color: Colors.white70)),
        ]),
      ),
      if (rates != null)
        InfoNote(
          'Cement PKR ${Fmt.number(rates.cement)}/bag  -  Steel PKR ${Fmt.number(rates.steel)}/kg  -  Bricks PKR ${Fmt.number(rates.brick)} each. '
              '${rates.isFallback ? 'Live prices were unavailable, so saved reference prices were used.' : 'Source: ${rates.source}${rates.scrapedAt.isNotEmpty ? ', updated ${Fmt.when(rates.scrapedAt)}' : ''}.'}',
          tone: rates.isFallback ? NoteTone.warning : NoteTone.success,
          title: rates.isFallback ? 'Reference prices' : 'Live market prices',
        ),
      SectionCard(
        title: 'Cost by group',
        icon: Icons.pie_chart_outline,
        child: Column(children: [
          for (final e in r.summary.entries) KeyValueRow(Fmt.title(e.key.replaceAll('_cost', '')), Fmt.pkr(e.value)),
        ]),
      ),
      for (final entry in r.byCategory.entries)
        SectionCard(
          title: entry.key,
          subtitle: Fmt.pkr(entry.value.fold<double>(0, (s, i) => s + i.totalPrice)),
          child: Column(children: [
            for (var i = 0; i < entry.value.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _ItemRow(item: entry.value[i]),
            ],
          ]),
        ),
      if (r.climateAdvice.trim().isNotEmpty) InfoNote(r.climateAdvice.trim(), title: 'Climate advice for Pakistan'),
      const InfoNote('Add 10-15% extra for wastage and breakage. Buy PSQCA-certified materials and compare at least three quotes.', tone: NoteTone.warning, title: 'Buying tips'),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CostScreen())),
          icon: const Icon(Icons.calculate_outlined),
          label: const Text('See full cost estimate'),
        ),
      ),
    ];
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final MaterialItem item;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700))),
      Text(Fmt.pkr(item.totalPrice), style: const TextStyle(fontWeight: FontWeight.w800)),
    ]),
    const SizedBox(height: 2),
    Text('${Fmt.number(item.quantity)} ${item.unit}  x  PKR ${Fmt.number(item.unitPrice)}', style: const TextStyle(fontWeight: FontWeight.w600)),
    if (item.brand.isNotEmpty) Text('Brand: ${item.brand}', style: Theme.of(context).textTheme.bodySmall),
    if (item.note.isNotEmpty) Text(item.note, style: Theme.of(context).textTheme.bodySmall),
  ]);
}