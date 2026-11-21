import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cost_estimation_model.dart';
import '../../viewmodels/cost_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../widgets/common_widgets.dart';
import '../export/export_screen.dart';

class CostScreen extends StatelessWidget {
  const CostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlotInputViewModel>();
    final vm = context.watch<CostViewModel>();
    if (!vm.isLoading && !vm.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.read<CostViewModel>().load(p.plot, p.city, p.budget);
      });
    }
    final cur = vm.results[p.budget];

    return Scaffold(
      appBar: AppBar(title: const Text('Cost estimator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ProjectSummaryBar(showBudget: false),
          CityDropdown(
            value: p.city,
            onChanged: (c) {
              p.setCity(c);
              context.read<CostViewModel>().load(p.plot, c, p.budget, force: true, userAction: true);
            },
          ),
          const SizedBox(height: 14),
          Semantics(header: true, child: Text('Choose a budget level', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 8),
          Row(children: [
            for (final b in AppConstants.budgetKeys)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _BudgetCard(
                    budgetKey: b,
                    result: vm.results[b],
                    loading: vm.pending.contains(b) || (vm.isLoading && p.budget == b),
                    failed: vm.failed.contains(b),
                    selected: p.budget == b,
                    onTap: () {
                      p.setBudget(b);
                      context.read<CostViewModel>().load(p.plot, p.city, b, userAction: true);
                    },
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 14),
          if (cur == null && vm.isLoading)
            SizedBox(
              height: 280,
              child: LoadingPanel(
                messages: const ['Reading live cement, steel and brick prices...', 'Pricing the grey structure...', 'Adding finishing and labour...'],
                hint: 'usually 5-20 s',
                onCancel: vm.cancel,
              ),
            ),
          if (cur == null && vm.hasError)
            ErrorPanel(message: vm.errorMessage ?? 'Could not estimate the cost.', onRetry: () => vm.load(p.plot, p.city, p.budget, force: true, userAction: true)),
          if (cur != null) ..._detail(context, cur),
        ],
      ),
    );
  }

  List<Widget> _detail(BuildContext context, CostResult c) {
    final rates = c.rates;
    return [
      SectionCard(
        title: 'Project summary',
        icon: Icons.home_outlined,
        child: Column(children: [
          KeyValueRow('Plot area', '${Fmt.sqft(c.plotArea)} (${Fmt.marla(c.plotArea)} Marla)'),
          KeyValueRow('Floors', '${c.floors}'),
          KeyValueRow('Total built area', Fmt.sqft(c.builtArea)),
          KeyValueRow('Cost per sqft', 'PKR ${Fmt.number(c.perSqft)}'),
        ]),
      ),
      SectionCard(
        title: 'Cost breakdown - ${Fmt.title(c.budgetKey)}',
        icon: Icons.stacked_bar_chart,
        child: Column(children: [
          _Bar('Grey structure', c.grey, c.greyPct),
          _Bar('Finishing', c.finishing, c.finishingPct),
          _Bar('Labour', c.labor, c.labourPct),
          const Divider(height: 24),
          KeyValueRow('Total', Fmt.pkr(c.total), bold: true),
          const SizedBox(height: 6),
          InfoNote('Keep about 10% (${Fmt.pkr(c.contingency)}) aside for surprises. Budget with contingency: ${Fmt.pkr(c.totalWithContingency)}.', tone: NoteTone.warning, title: 'Contingency'),
        ]),
      ),
      if (c.materialBreakdown.isNotEmpty)
        SectionCard(
          title: 'Main materials',
          icon: Icons.construction,
          subtitle: (c.materialBreakdown['note'] ?? '').toString(),
          child: Column(children: [
            for (final m in const [('Bricks', 'bricks'), ('Cement bags', 'cement'), ('Steel (kg)', 'steel')])
              KeyValueRow(m.$1, '${Fmt.number(num.tryParse('${c.materialBreakdown['${m.$2}_qty']}') ?? 0)}  -  ${Fmt.pkr(num.tryParse('${c.materialBreakdown['${m.$2}_cost']}') ?? 0)}'),
            KeyValueRow('Sand and crush', Fmt.pkr(num.tryParse('${c.materialBreakdown['sand_crush_cost']}') ?? 0)),
          ]),
        ),
      if (c.timeline.isNotEmpty)
        SectionCard(
          title: 'Expected timeline',
          icon: Icons.schedule,
          child: Column(children: [for (final e in c.timeline.entries) KeyValueRow(Fmt.title(e.key), e.value, bold: e.key == 'total')]),
        ),
      if (rates != null)
        InfoNote(
          'Based on cement PKR ${Fmt.number(rates.cement)}/bag, steel PKR ${Fmt.number(rates.steel)}/kg, bricks PKR ${Fmt.number(rates.brick)} each. '
              '${rates.isFallback ? 'Live prices were unavailable - saved reference prices used.' : 'Source: ${rates.source}${rates.scrapedAt.isNotEmpty ? ', updated ${Fmt.when(rates.scrapedAt)}' : ''}.'}',
          tone: rates.isFallback ? NoteTone.warning : NoteTone.info,
          title: 'Price basis',
        ),
      if (c.notes.isNotEmpty)
        SectionCard(
          title: 'Important notes',
          icon: Icons.sticky_note_2_outlined,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final n in c.notes) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('-  $n')),
          ]),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExportScreen())),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Create PDF report'),
        ),
      ),
    ];
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budgetKey, required this.result, required this.loading, required this.failed, required this.selected, required this.onTap});
  final String budgetKey;
  final CostResult? result;
  final bool loading, failed, selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = AppConstants.budgetLabels[budgetKey]!;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label budget${result != null ? ', ${Fmt.pkr(result!.total)}' : ''}${selected ? ', selected' : ''}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? AppColors.infoBg : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2.5 : 1),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (selected) const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
              if (selected) const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            if (result != null) ...[
              Text(Fmt.pkr(result!.total), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 2),
              Text('PKR ${Fmt.number(result!.perSqft)}/sqft', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ] else if (loading)
              const Padding(padding: EdgeInsets.only(top: 6), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)))
            else
              Text(failed ? 'Failed - tap to retry' : 'Tap to calculate', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.value, this.pct);
  final String label;
  final double value, pct;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text('${Fmt.pkr(value)}  (${pct.toStringAsFixed(1)}%)', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: (pct / 100).clamp(0.0, 1.0).toDouble(), minHeight: 8, backgroundColor: AppColors.border.withAlpha(90)),
      ),
    ]),
  );
}