import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../viewmodels/plot_input_viewmodel.dart';
import '../views/plot_input/plot_input_screen.dart';

/// White rounded section with a clear heading.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.icon, this.trailing, this.subtitle});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border.withAlpha(120)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        if (icon != null) ...[Icon(icon, color: AppColors.primary, size: 22), const SizedBox(width: 8)],
        Expanded(child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleMedium))),
        if (trailing != null) trailing!,
      ]),
      if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

enum NoteTone { info, warning, success, error }

/// Coloured note: icon + text, never colour alone, always AA contrast.
class InfoNote extends StatelessWidget {
  const InfoNote(this.text, {super.key, this.tone = NoteTone.info, this.title});
  final String text;
  final String? title;
  final NoteTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (tone) {
      NoteTone.info => (AppColors.infoBg, AppColors.info, Icons.info_outline),
      NoteTone.warning => (AppColors.warningBg, AppColors.warning, Icons.warning_amber_rounded),
      NoteTone.success => (AppColors.successBg, AppColors.success, Icons.check_circle_outline),
      NoteTone.error => (AppColors.errorBg, AppColors.error, Icons.error_outline),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: fg, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null) Text(title!, style: TextStyle(color: fg, fontWeight: FontWeight.w800)),
            Text(text, style: TextStyle(color: fg, height: 1.35)),
          ]),
        ),
      ]),
    );
  }
}

/// Spinner + rotating status text + elapsed time + Cancel (visibility of system status, user control).
class LoadingPanel extends StatefulWidget {
  const LoadingPanel({super.key, required this.messages, this.onCancel, this.hint});
  final List<String> messages;
  final VoidCallback? onCancel;
  final String? hint;
  @override
  State<LoadingPanel> createState() => _LoadingPanelState();
}

class _LoadingPanelState extends State<LoadingPanel> {
  Timer? _t;
  int _sec = 0;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _sec++));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.messages[(_sec ~/ 4) % widget.messages.length];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Semantics(
          liveRegion: true,
          label: '$msg $_sec seconds',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 4)),
            const SizedBox(height: 20),
            Text(msg, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('$_sec s${widget.hint != null ? '  -  ${widget.hint}' : ''}', style: Theme.of(context).textTheme.bodySmall),
            if (widget.onCancel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: widget.onCancel, icon: const Icon(Icons.close), label: const Text('Cancel')),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Plain-language error with a way out.
class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, this.onRetry, this.secondaryLabel, this.onSecondary});
  final String message;
  final VoidCallback? onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.error),
        const SizedBox(height: 12),
        Text('That did not work', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
          if (onRetry != null) FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          if (onSecondary != null) OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel ?? 'Back')),
        ]),
      ]),
    ),
  );
}

/// Label + - / + stepper with enforced limits.
class StepperField extends StatelessWidget {
  const StepperField({super.key, required this.label, required this.value, required this.min, required this.max, required this.onChanged, this.hint});
  final String label;
  final String? hint;
  final int value, min, max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (hint != null) Text(hint!, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
      IconButton.filledTonal(
        tooltip: 'Decrease $label',
        onPressed: value > min ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove),
      ),
      Semantics(
        label: '$label: $value',
        child: SizedBox(width: 44, child: Text('$value', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
      ),
      IconButton.filledTonal(
        tooltip: 'Increase $label',
        onPressed: value < max ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add),
      ),
    ]),
  );
}

/// Single-select chips; selected chip shows a check mark (not colour only).
class OptionChips extends StatelessWidget {
  const OptionChips({super.key, required this.options, required this.selected, required this.onSelected});
  final Map<String, String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final e in options.entries)
        ChoiceChip(label: Text(e.value), selected: selected == e.key, onSelected: (_) => onSelected(e.key)),
    ],
  );
}

class BudgetSelector extends StatelessWidget {
  const BudgetSelector({super.key, required this.value, required this.onChanged, this.keys = AppConstants.budgetKeys});
  final String value;
  final ValueChanged<String> onChanged;
  final List<String> keys;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: SegmentedButton<String>(
      showSelectedIcon: true,
      segments: [for (final k in keys) ButtonSegment(value: k, label: Text(Fmt.title(k)))],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    ),
  );
}

class CityDropdown extends StatelessWidget {
  const CityDropdown({super.key, required this.value, required this.onChanged, this.cities = AppConstants.cities, this.label = 'City'});
  final String value, label;
  final ValueChanged<String> onChanged;
  final List<String> cities;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: cities.contains(value) ? value : cities.first,
    decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.location_city)),
    items: [for (final c in cities) DropdownMenuItem(value: c, child: Text(Fmt.title(c)))],
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.label, this.value, {super.key, this.bold = false});
  final String label, value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 4, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      const SizedBox(width: 8),
      Expanded(flex: 5, child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600))),
    ]),
  );
}

class StatTile extends StatelessWidget {
  const StatTile(this.label, this.value, {super.key});
  final String label, value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.info), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.info), textAlign: TextAlign.center),
      ]),
    ),
  );
}

/// "Working on: 10.0 Marla - 2 floors - Lahore - Standard   [Edit]"
/// Shown on every result screen so users never have to remember their inputs.
class ProjectSummaryBar extends StatelessWidget {
  const ProjectSummaryBar({super.key, this.showBudget = true});
  final bool showBudget;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlotInputViewModel>();
    final parts = [
      '${Fmt.marla(p.plot.plotArea)} Marla (${Fmt.sqft(p.plot.plotArea)})',
      '${p.plot.numFloors} floor${p.plot.numFloors > 1 ? 's' : ''}',
      Fmt.title(p.city),
      if (showBudget) Fmt.title(p.budget),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Icon(Icons.home_work_outlined, color: AppColors.info),
        const SizedBox(width: 10),
        Expanded(child: Text(parts.join('  -  '), style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700))),
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlotInputScreen(editOnly: true))),
          child: const Text('Edit'),
        ),
      ]),
    );
  }
}