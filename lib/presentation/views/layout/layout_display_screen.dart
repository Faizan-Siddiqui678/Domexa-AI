import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/layout_model.dart';
import '../../viewmodels/interior_viewmodel.dart';
import '../../viewmodels/layout_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../widgets/common_widgets.dart';
import '../cost/cost_screen.dart';
import '../interior/interior_screen.dart';
import '../materials/materials_screen.dart';

class LayoutDisplayScreen extends StatefulWidget {
  const LayoutDisplayScreen({super.key});
  @override
  State<LayoutDisplayScreen> createState() => _LayoutDisplayScreenState();
}

class _LayoutDisplayScreenState extends State<LayoutDisplayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  void _generate({bool force = false}) =>
      context.read<LayoutViewModel>().generate(context.read<PlotInputViewModel>().plot, force: force);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LayoutViewModel>();
    final layout = vm.layout;

    Widget body;
    if (vm.isLoading) {
      body = LoadingPanel(
        messages: const ['Planning room sizes...', 'Placing rooms on each floor...', 'Drawing doors and windows...', 'Finishing the floor plan...'],
        hint: 'usually 15-40 s',
        onCancel: () {
          vm.cancel();
          Navigator.of(context).pop();
        },
      );
    } else if (layout == null || (vm.hasError && vm.generatedFor == null)) {
      body = vm.hasError
          ? ErrorPanel(
        message: vm.errorMessage ?? 'Could not create the layout.',
        onRetry: vm.canRetry ? () => _generate(force: true) : null,
        secondaryLabel: 'Change details',
        onSecondary: () => Navigator.of(context).pop(),
      )
          : const SizedBox.shrink();
    } else {
      body = _Result(layout: layout);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your floor plan'),
        actions: [
          if (layout != null && !vm.isLoading)
            IconButton(tooltip: 'Generate a different layout', icon: const Icon(Icons.refresh), onPressed: () => _generate(force: true)),
        ],
      ),
      body: body,
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.layout});
  final LayoutModel layout;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LayoutViewModel>();
    final floor = vm.currentFloor;
    final stale = vm.generatedFor != null && vm.generatedFor != context.watch<PlotInputViewModel>().plot;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vm.hasError) InfoNote(vm.errorMessage ?? 'Could not update the plan.', tone: NoteTone.error, title: 'Could not refresh the plan'),
        if (stale)
          InfoNote('Your details changed after this plan was made. Tap the refresh icon to update it.', tone: NoteTone.warning, title: 'Plan is out of date'),
        Row(children: [
          StatTile('Plot', '${layout.plotWidth.toStringAsFixed(0)} x ${layout.plotLength.toStringAsFixed(0)} ft'),
          StatTile('Covered', Fmt.sqft(layout.coveredArea)),
          StatTile('Open', Fmt.sqft(layout.openArea)),
          StatTile('Rooms', '${layout.totalRooms}'),
        ]),
        const SizedBox(height: 14),

        if (layout.floors.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(spacing: 8, children: [
              for (var i = 0; i < layout.floors.length; i++)
                ChoiceChip(label: Text(layout.floors[i].name), selected: vm.floorIndex == i, onSelected: (_) => vm.selectFloor(i)),
            ]),
          ),

        if (floor != null) ...[
          SectionCard(
            title: floor.name,
            subtitle: 'Pinch to zoom, drag to move',
            icon: Icons.architecture,
            trailing: IconButton(
              tooltip: 'Open full screen',
              icon: const Icon(Icons.fullscreen),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _FullPlan(floor: floor))),
            ),
            child: floor.svg.isEmpty
                ? const InfoNote('The drawing is not available for this floor, but the room list below is complete.', tone: NoteTone.warning)
                : SizedBox(height: 380, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: PlanView(svg: floor.svg))),
          ),
          SectionCard(
            title: 'Rooms on this floor (${floor.rooms.length})',
            subtitle: 'Total ${Fmt.sqft(floor.area)}',
            icon: Icons.meeting_room_outlined,
            child: Column(children: [
              for (final r in floor.rooms) _RoomTile(room: r),
            ]),
          ),
        ],

        if (layout.recommendations.isNotEmpty)
          SectionCard(
            title: 'Design recommendations',
            icon: Icons.lightbulb_outline,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final t in layout.recommendations) _Bullet(t)]),
          ),
        if (layout.vastuNotes.isNotEmpty)
          SectionCard(
            title: 'Orientation notes',
            icon: Icons.explore_outlined,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final t in layout.vastuNotes) _Bullet(t)]),
          ),

        SectionCard(
          title: 'Next step',
          icon: Icons.arrow_forward,
          child: Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MaterialsScreen())),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Materials'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CostScreen())),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Cost estimate'),
            ),
          ]),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.only(top: 6, right: 8), child: Icon(Icons.circle, size: 6, color: AppColors.primary)),
      Expanded(child: Text(text)),
    ]),
  );
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room});
  final RoomModel room;
  @override
  Widget build(BuildContext context) {
    final canDesign = room.type != 'stairs' && room.type != 'gallery' && room.type != 'garage';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${room.width.toStringAsFixed(0)} x ${room.length.toStringAsFixed(0)} ft  -  ${Fmt.sqft(room.areaSqft)}'),
      trailing: canDesign
          ? TextButton(
        onPressed: () {
          final p = context.read<PlotInputViewModel>();
          final i = context.read<InteriorViewModel>();
          i.syncWithProject(projectCity: p.city, projectBudget: p.budget, houseStyle: p.plot.houseStyle);
          i.prefillFromRoom(room.type, room.areaSqft);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InteriorScreen()));
        },
        child: const Text('Interior ideas'),
      )
          : null,
    );
  }
}

/// Renders the backend's SVG (it contains <text> labels, which flutter_svg cannot draw).
class PlanView extends StatefulWidget {
  const PlanView({super.key, required this.svg});
  final String svg;
  @override
  State<PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends State<PlanView> {
  late final WebViewController _c;

  String _html(String svg) => '''<!DOCTYPE html><html><head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=0.5, maximum-scale=6.0, user-scalable=yes">
<style>html,body{margin:0;padding:0;background:#fff}svg{width:100%;height:auto;display:block}</style>
</head><body>$svg</body></html>''';

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..loadHtmlString(_html(widget.svg));
  }

  @override
  void didUpdateWidget(PlanView old) {
    super.didUpdateWidget(old);
    if (old.svg != widget.svg) _c.loadHtmlString(_html(widget.svg));
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Floor plan drawing. Room names and sizes are listed below the drawing.',
    child: WebViewWidget(
      controller: _c,
      // Let the drawing take pinch/drag gestures inside the scrolling page.
      gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
    ),
  );
}

class _FullPlan extends StatelessWidget {
  const _FullPlan({required this.floor});
  final FloorModel floor;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(floor.name)),
    body: PlanView(svg: floor.svg),
  );
}