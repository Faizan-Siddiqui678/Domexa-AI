// lib/presentation/views/layout/layout_display_screen.dart
// v4 — renders AutoCAD-style SVG from backend using flutter_svg
//
// pubspec.yaml dependency needed:
//   flutter_svg: ^2.0.9
//
// Run: flutter pub add flutter_svg

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../../data/models/layout_model.dart';

class LayoutDisplayScreen extends StatefulWidget {
  const LayoutDisplayScreen({super.key});

  @override
  State<LayoutDisplayScreen> createState() => _LayoutDisplayScreenState();
}

class _LayoutDisplayScreenState extends State<LayoutDisplayScreen>
    with TickerProviderStateMixin {
  int _selectedFloor = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm     = Provider.of<PlotInputViewModel>(context);
    final layout = vm.generatedLayout;

    if (layout == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(context),
        body: _buildEmpty(context),
      );
    }

    // Update tab controller length when layout loaded
    if (_tabController.length != layout.floors.length) {
      _tabController.dispose();
      _tabController = TabController(
          length: layout.floors.length, vsync: this);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(context),
      body: Column(children: [
        // ── Floor tabs ──────────────────────────────────────────────────
        if (layout.floors.length > 1)
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              onTap: (i) => setState(() => _selectedFloor = i),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: layout.floors
                  .map((f) => Tab(text: f.floorName))
                  .toList(),
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(layout),
                  const SizedBox(height: 16),
                  _buildFloorCard(layout),
                  const SizedBox(height: 16),
                  _buildRoomTable(layout),
                  const SizedBox(height: 16),
                  if (layout.recommendations.isNotEmpty)
                    _buildRecommendations(layout),
                  const SizedBox(height: 16),
                  if (layout.vastuNotes.isNotEmpty)
                    _buildVastuNotes(layout),
                  const SizedBox(height: 16),
                  _buildNextSteps(context),
                ]),
          ),
        ),
      ]),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar(BuildContext context) => AppBar(
    backgroundColor: AppColors.surface,
    elevation: 0,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
      ),
    ),
    title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Floor Plan',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      Text('AI-generated • AutoCAD style',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
    actions: [
      // Share button
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.share_outlined,
              color: AppColors.primary, size: 18),
        ),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Export available in Export screen'),
              backgroundColor: AppColors.primary),
        ),
      ),
      const SizedBox(width: 8),
    ],
  );

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.home_work_outlined,
          color: AppColors.primary, size: 56),
      const SizedBox(height: 16),
      const Text('No Layout Generated',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      const SizedBox(height: 8),
      const Text('Go back and fill the form to generate a layout.',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: const Text('Go Back'),
      ),
    ]),
  );

  // ── Summary card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard(LayoutModel layout) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('Layout Generated by AI',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _statBox('${layout.plotWidth.toStringAsFixed(0)}×'
            '${layout.plotLength.toStringAsFixed(0)} ft', 'Plot Size'),
        const SizedBox(width: 8),
        _statBox('${layout.totalCoveredArea.toStringAsFixed(0)} sqft',
            'Covered'),
        const SizedBox(width: 8),
        _statBox('${layout.floors.length}', 'Floors'),
        const SizedBox(width: 8),
        _statBox('${layout.totalRooms}', 'Rooms'),
      ]),
    ]),
  );

  Widget _statBox(String val, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.3))),
      child: Column(children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13),
            textAlign: TextAlign.center),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 9),
            textAlign: TextAlign.center),
      ]),
    ),
  );

  // ── SVG Floor Plan Card ← KEY SECTION ────────────────────────────────────
  Widget _buildFloorCard(LayoutModel layout) {
    final fi    = _selectedFloor.clamp(0, layout.floors.length - 1);
    final floor = layout.floors[fi];
    final svg   = floor.svg;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16))),
          child: Row(children: [
            const Icon(Icons.architecture,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(floor.floorName,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('AutoCAD Style',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        // ── SVG Floor Plan (zoomable + pannable) ──────────────────────
        if (svg.isNotEmpty)
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,        // user can zoom up to 5x
            boundaryMargin: const EdgeInsets.all(40),
            child: Container(
              width:  double.infinity,
              height: 420,
              color:  Colors.white,
              padding: const EdgeInsets.all(8),
              child: SvgPicture.string(
                svg,
                fit: BoxFit.contain,
                semanticsLabel: '${floor.floorName} floor plan',
              ),
            ),
          )
        else
          Container(
            height: 200,
            alignment: Alignment.center,
            child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading floor plan...'),
                ]),
          ),

        // Hint text
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            const Icon(Icons.pinch_outlined,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Pinch to zoom • Drag to pan • ${floor.rooms.length} rooms',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Room table ────────────────────────────────────────────────────────────
  Widget _buildRoomTable(LayoutModel layout) {
    final fi    = _selectedFloor.clamp(0, layout.floors.length - 1);
    final floor = layout.floors[fi];

    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${floor.floorName} — Room Details',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary)),
        ),
        ...floor.rooms.map((r) => _roomRow(r)),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _roomRow(RoomModel room) => Container(
    margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Text(room.icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.roomName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text('${room.sizeLabel}  •  '
                '${room.areaSqft.toStringAsFixed(0)} sqft',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _tag('${room.windows.length}W',
            Icons.window_outlined, const Color(0xFF0284C7)),
        const SizedBox(height: 4),
        _tag('${room.doors.length}D',
            Icons.door_back_door_outlined,
            const Color(0xFFD97706)),
      ]),
    ]),
  );

  Widget _tag(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: color),
      const SizedBox(width: 3),
      Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    ]),
  );

  // ── Recommendations ───────────────────────────────────────────────────────
  Widget _buildRecommendations(LayoutModel layout) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.info.withValues(alpha: 0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb_outline,
                color: AppColors.info, size: 18),
            SizedBox(width: 8),
            Text('AI Recommendations',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.info, fontSize: 14)),
          ]),
          const SizedBox(height: 10),
          ...layout.recommendations.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(color: AppColors.info)),
                  Expanded(child: Text(r,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12, height: 1.4))),
                ]),
          )),
        ]),
  );

  // ── Vastu notes ───────────────────────────────────────────────────────────
  Widget _buildVastuNotes(LayoutModel layout) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFFFB300).withValues(alpha: 0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('☯️', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Vastu / Islamic Guidelines',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B6914),
                    fontSize: 14)),
          ]),
          const SizedBox(height: 10),
          ...layout.vastuNotes.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(color: Color(0xFFB8860B))),
                  Expanded(child: Text(n,
                      style: const TextStyle(
                          color: Color(0xFF5C4A00),
                          fontSize: 12, height: 1.4))),
                ]),
          )),
        ]),
  );

  // ── Next steps ────────────────────────────────────────────────────────────
  Widget _buildNextSteps(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's Next?",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const SizedBox(height: 14),
          _nextStep(context, Icons.inventory_2_outlined,
              'Materials', 'See materials & PKR costs', '/materials'),
          _nextStep(context, Icons.calculate_outlined,
              'Cost Estimate', 'Full budget breakdown', '/cost'),
          _nextStep(context, Icons.palette_outlined,
              'Interior Design', 'AI room styling + images', '/interior'),
          _nextStep(context, Icons.chat_bubble_outline,
              'Ask AI', 'Construction questions', '/chatbot'),
        ]),
  );

  Widget _nextStep(BuildContext ctx, IconData icon, String title,
      String desc, String route) =>
      GestureDetector(
        onTap: () => Navigator.pushNamed(ctx, route),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3))),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  Text(desc,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                ])),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 14),
          ]),
        ),
      );
}