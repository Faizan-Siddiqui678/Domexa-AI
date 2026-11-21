import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../viewmodels/cost_viewmodel.dart';
import '../../viewmodels/export_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../widgets/common_widgets.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});
  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  late final TextEditingController _name;
  late final TextEditingController _owner;

  @override
  void initState() {
    super.initState();
    final p = context.read<PlotInputViewModel>();
    _name = TextEditingController(text: p.projectName);
    _owner = TextEditingController(text: p.ownerName);
  }

  @override
  void dispose() {
    _name.dispose();
    _owner.dispose();
    super.dispose();
  }

  void _generate() {
    final p = context.read<PlotInputViewModel>();
    p.setNames(project: _name.text, owner: _owner.text);
    context.read<ExportViewModel>().export(
      plot: p.plot, budget: p.budget, city: p.city,
      projectName: _name.text, ownerName: _owner.text,
      costs: context.read<CostViewModel>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlotInputViewModel>();
    final vm = context.watch<ExportViewModel>();
    final r = vm.result;

    return Scaffold(
      appBar: AppBar(title: const Text('PDF report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ProjectSummaryBar(),
          SectionCard(
            title: 'Report details',
            icon: Icons.badge_outlined,
            child: Column(children: [
              TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Project name', hintText: 'My House Plan')),
              const SizedBox(height: 12),
              TextField(controller: _owner, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Owner name (optional)')),
              const SizedBox(height: 14),
              BudgetSelector(value: p.budget, onChanged: p.setBudget),
            ]),
          ),
          SectionCard(
            title: 'What the report contains',
            icon: Icons.checklist,
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Check('Project name, owner and date'),
              _Check('Plot size, floors, bedrooms and bathrooms'),
              _Check('Total cost for the chosen budget level'),
              _Check('Grey structure, finishing and labour split'),
            ]),
          ),
          const InfoNote('The floor-plan drawing is not part of the PDF yet - use a screenshot of the plan screen if you need to share it.', tone: NoteTone.warning),
          if (vm.isLoading)
            SizedBox(height: 220, child: LoadingPanel(messages: [vm.step.isEmpty ? 'Preparing...' : vm.step], hint: 'usually 5-15 s', onCancel: vm.cancel))
          else if (vm.hasError)
            ErrorPanel(message: vm.errorMessage ?? 'Could not create the PDF.', onRetry: vm.canRetry ? _generate : null)
          else if (r != null) ...[
              InfoNote('${r.filename}  (${r.sizeLabel})${vm.lastTotal != null ? '\nTotal in report: ${Fmt.pkr(vm.lastTotal!)}' : ''}', tone: NoteTone.success, title: 'Your report is ready'),
              Row(children: [
                Expanded(child: FilledButton.icon(onPressed: vm.share, icon: const Icon(Icons.ios_share), label: const Text('Share / save PDF'))),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: _generate, child: const Text('Create again')),
              ]),
            ] else
              FilledButton.icon(onPressed: _generate, icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('Create PDF report')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [const Icon(Icons.check_circle_outline, size: 20), const SizedBox(width: 8), Expanded(child: Text(text))]),
  );
}