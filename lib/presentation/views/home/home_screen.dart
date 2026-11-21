import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/project_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cost_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../viewmodels/prices_viewmodel.dart';
import '../../viewmodels/projects_viewmodel.dart';
import '../../widgets/common_widgets.dart';
import '../chatbot/chatbot_screen.dart';
import '../cost/cost_screen.dart';
import '../export/export_screen.dart';
import '../interior/interior_screen.dart';
import '../materials/materials_screen.dart';
import '../plot_input/plot_input_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _priceCity;

  void _go(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final plot = context.watch<PlotInputViewModel>();
    final auth = context.watch<AuthViewModel>();
    // Load live prices for the project's city (and again when the city changes).
    if (_priceCity != plot.city) {
      _priceCity = plot.city;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<PricesViewModel>().load(plot.city);
      });
    }

    final features = <_Feature>[
      _Feature('AI Layout', 'Floor plans for every floor', Icons.dashboard_customize_outlined, const Color(0xFF4F46E5), () => _go(const PlotInputScreen())),
      _Feature('Materials', 'Quantities and live prices', Icons.inventory_2_outlined, const Color(0xFF047857), () => _go(const MaterialsScreen())),
      _Feature('Cost', 'Budget in PKR', Icons.calculate_outlined, const Color(0xFFC2410C), () => _go(const CostScreen())),
      _Feature('Interior', 'Colours, furniture, image', Icons.palette_outlined, const Color(0xFF7E22CE), () => _go(const InteriorScreen())),
      _Feature('PDF Report', 'Share your plan', Icons.picture_as_pdf_outlined, const Color(0xFFB45309), () => _go(const ExportScreen())),
      _Feature('Ask AI', 'Civil engineering help', Icons.smart_toy_outlined, AppColors.primary, () => _go(const ChatbotScreen())),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.home_work_rounded, color: AppColors.primary), SizedBox(width: 8), Text('Domexa')]),
        actions: [
          IconButton(tooltip: 'Profile and settings', icon: const Icon(Icons.account_circle_outlined, size: 28), onPressed: () => _go(const ProfileScreen())),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _go(const ChatbotScreen()),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Ask AI'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, ${auth.isSignedIn ? auth.displayName.split(' ').first : 'there'}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              const Text('Plan your dream home', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Layouts, materials and PKR costs - built for Pakistan.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                onPressed: () {
                  context.read<PlotInputViewModel>().reset();
                  _go(const PlotInputScreen());
                },
                icon: const Icon(Icons.add_home_work_outlined),
                label: const Text('Start new project'),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          const ProjectSummaryBar(),

          Semantics(header: true, child: Text('Tools', style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [for (final f in features) _FeatureCard(f)],
          ),
          const SizedBox(height: 18),

          _PricesCard(city: plot.city),
          _SavedProjects(onOpen: (p) {
            context.read<PlotInputViewModel>().load(p);
            _go(const PlotInputScreen(editOnly: true));
          }),
        ],
      ),
    );
  }
}

class _Feature {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _Feature(this.title, this.subtitle, this.icon, this.color, this.onTap);
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(this.f);
  final _Feature f;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${f.title}. ${f.subtitle}',
    child: Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: f.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border.withAlpha(120))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: f.color.withAlpha(28), borderRadius: BorderRadius.circular(12)),
              child: Icon(f.icon, color: f.color, size: 26),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(f.subtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ]),
        ),
      ),
    ),
  );
}

class _PricesCard extends StatelessWidget {
  const _PricesCard({required this.city});
  final String city;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PricesViewModel>();
    final p = vm.prices;
    return SectionCard(
      title: 'Live prices - ${Fmt.title(city)}',
      icon: Icons.trending_up,
      trailing: vm.isLoading
          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)))
          : IconButton(tooltip: 'Refresh prices', icon: const Icon(Icons.refresh), onPressed: () => vm.load(city, force: true)),
      child: vm.hasError && p == null
          ? Text(vm.errorMessage ?? 'Prices unavailable.', style: const TextStyle(color: AppColors.error))
          : p == null
          ? const Text('Fetching today\'s market prices...')
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Price('Cement', 'PKR ${Fmt.number(p.cement)}', 'per bag'),
          _Price('Steel', 'PKR ${Fmt.number(p.steel)}', 'per kg'),
          _Price('Bricks', 'PKR ${Fmt.number(p.brick)}', 'each'),
        ]),
        const SizedBox(height: 8),
        Text('Source: ${p.sourceLabel}${p.scrapedAt.isNotEmpty ? '  -  updated ${Fmt.when(p.scrapedAt)}' : ''}', style: Theme.of(context).textTheme.bodySmall),
        if (p.warning.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: InfoNote(p.warning, tone: NoteTone.warning)),
      ]),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price(this.name, this.value, this.unit);
  final String name, value, unit;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: Theme.of(context).textTheme.bodySmall),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      Text(unit, style: Theme.of(context).textTheme.bodySmall),
    ]),
  );
}

class _SavedProjects extends StatelessWidget {
  const _SavedProjects({required this.onOpen});
  final void Function(ProjectModel) onOpen;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<ProjectsViewModel>();

    if (!auth.isSignedIn) {
      return SectionCard(
        title: 'Saved projects',
        icon: Icons.folder_open,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sign in to save projects and open them on any device.'),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: () => context.read<AuthViewModel>().signOut(), child: const Text('Sign in or create account')),
        ]),
      );
    }

    return SectionCard(
      title: 'Saved projects',
      icon: Icons.folder_open,
      trailing: TextButton.icon(
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save current'),
        onPressed: () async {
          final costs = context.read<CostViewModel>();
          final plot = context.read<PlotInputViewModel>();
          final ok = await context.read<ProjectsViewModel>().save(plot.toProject(totalCost: costs.results[plot.budget]?.total));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Project saved' : (vm.error ?? 'Could not save the project'))));
          }
        },
      ),
      child: vm.projects.isEmpty
          ? const Text('Nothing saved yet. Set up a project, then tap "Save current".')
          : Column(children: [
        for (final p in vm.projects)
          ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 8,
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${p.plot.summary} - ${Fmt.title(p.city)} - ${Fmt.title(p.budget)}${p.totalCost != null ? '\n${Fmt.pkr(p.totalCost!)}' : ''}'),
            isThreeLine: p.totalCost != null,
            onTap: () => onOpen(p),
            trailing: IconButton(
              tooltip: 'Delete ${p.name}',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final vmr = context.read<ProjectsViewModel>();
                final messenger = ScaffoldMessenger.of(context);
                await vmr.delete(p);
                messenger.showSnackBar(SnackBar(
                  content: Text('"${p.name}" deleted'),
                  action: SnackBarAction(label: 'Undo', onPressed: vmr.undoDelete),
                ));
              },
            ),
          ),
      ]),
    );
  }
}