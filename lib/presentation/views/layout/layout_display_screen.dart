// lib/presentation/views/layout/layout_display_screen.dart
// v2 — architectural floor plan painter (thick walls, furniture, door arcs, windows)

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../../data/models/layout_model.dart';

class LayoutDisplayScreen extends StatefulWidget {
  const LayoutDisplayScreen({super.key});

  @override
  State<LayoutDisplayScreen> createState() => _LayoutDisplayScreenState();
}

class _LayoutDisplayScreenState extends State<LayoutDisplayScreen> {
  int _selectedFloor = 0;

  @override
  Widget build(BuildContext context) {
    final vm     = Provider.of<PlotInputViewModel>(context);
    final layout = vm.generatedLayout;

    if (layout == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.info_outline, color: AppColors.warning, size: 40),
            const SizedBox(height: 16),
            const Text('No Layout Generated',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Please go back and generate a layout first.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Go Back'),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(),
      body: Column(children: [
        // ── Floor selector ────────────────────────────────────────────────
        if (layout.floors.length > 1)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                const Text('Floor: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(width: 8),
                ...layout.floors.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(e.value.floorName),
                    selected: _selectedFloor == e.key,
                    onSelected: (_) => setState(() => _selectedFloor = e.key),
                    backgroundColor: AppColors.bgInput,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: _selectedFloor == e.key ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                )),
              ]),
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _summaryCard(layout),
              const SizedBox(height: 20),
              // ── Per-floor requirements card ────────────────────────────
              _floorRequirementsCard(layout),
              const SizedBox(height: 20),
              if (layout.recommendations.isNotEmpty) ...[
                _recommendationsCard(layout.recommendations),
                const SizedBox(height: 20),
              ],
              // ── Architectural floor plan ───────────────────────────────
              _floorPlanCard(layout),
              const SizedBox(height: 20),
              _roomDetailsTable(layout),
              const SizedBox(height: 20),
              _nextStepsCard(context),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
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
      Text('Generated Layout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      Text('Architectural floor plan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
    actions: [
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.share_outlined, color: AppColors.primary, size: 18),
        ),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export in Export Project screen'), backgroundColor: AppColors.primary),
        ),
      ),
      const SizedBox(width: 8),
    ],
  );

  // ── Summary card ───────────────────────────────────────────────────────────
  Widget _summaryCard(LayoutModel layout) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
        SizedBox(width: 10),
        Text('Layout Generated Successfully!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        _statChip('${layout.totalCoveredArea.toStringAsFixed(0)} sqft', 'Covered'),
        const SizedBox(width: 10),
        _statChip('${layout.totalOpenArea.toStringAsFixed(0)} sqft', 'Open Area'),
        const SizedBox(width: 10),
        _statChip('${layout.floors.length}', 'Floors'),
        const SizedBox(width: 10),
        _statChip('${layout.totalRooms}', 'Rooms'),
      ]),
    ]),
  );

  Widget _statChip(String val, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
      child: Column(children: [
        Text(val,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 9),
            textAlign: TextAlign.center),
      ]),
    ),
  );

  // ── Per-floor requirements card ← NEW ────────────────────────────────────
  Widget _floorRequirementsCard(LayoutModel layout) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.layers_outlined, color: AppColors.primary, size: 20),
        SizedBox(width: 8),
        Text('Floor-by-Floor Breakdown',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 14),
      ...layout.floors.asMap().entries.map((e) {
        final f   = e.value;
        final req = f.floorRequirements; // Map<String,dynamic>
        final isSelected = _selectedFloor == e.key;
        return GestureDetector(
          onTap: () => setState(() => _selectedFloor = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySurface : AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text('${e.key + 1}',
                      style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.floorName,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  req != null ? (req['summary'] as String? ?? '') : '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                ),
              ])),
              if (isSelected)
                const Icon(Icons.visibility, color: AppColors.primary, size: 16),
            ]),
          ),
        );
      }),
    ]),
  );

  // ── Architectural floor plan ← UPGRADED ───────────────────────────────────
  Widget _floorPlanCard(LayoutModel layout) {
    final fi    = _selectedFloor.clamp(0, layout.floors.length - 1);
    final floor = layout.floors[fi];
    final rooms = floor.rooms;

    double maxX = 0, maxY = 0;
    for (final r in rooms) {
      if (r.position.x + r.dimensions.width  > maxX) maxX = r.position.x + r.dimensions.width;
      if (r.position.y + r.dimensions.length > maxY) maxY = r.position.y + r.dimensions.length;
    }

    const scale = 10.0;
    final cw = (maxX + 4) * scale;
    final ch = (maxY + 4) * scale;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            const Icon(Icons.home_work, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(floor.floorName,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
            const Spacer(),
            const Text('1 unit = 1 ft',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ]),
        ),
        // canvas
        SizedBox(
          height: 380,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: CustomPaint(
                size: Size(cw, ch),
                painter: _ArchitecturalPainter(rooms: rooms, scale: scale),
              ),
            ),
          ),
        ),
        // legend
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Wrap(spacing: 12, runSpacing: 6, children: [
            _leg('Master BR',  const Color(0xFF0D47A1)),
            _leg('Bedroom',    const Color(0xFF1565C0)),
            _leg('Living',     const Color(0xFF059669)),
            _leg('Drawing',    const Color(0xFF047857)),
            _leg('Kitchen',    const Color(0xFFD97706)),
            _leg('Bathroom',   const Color(0xFF0284C7)),
            _leg('Dining',     const Color(0xFF7C3AED)),
            _leg('Garage',     const Color(0xFF6B7280)),
            _leg('Stairs',     const Color(0xFF4B5563)),
            _leg('Gallery',    const Color(0xFF8B5CF6)),
            _leg('Open Area',  const Color(0xFF10B981)),
          ]),
        ),
      ]),
    );
  }

  Widget _leg(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 12, height: 12,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
  ]);

  // ── Room details table ────────────────────────────────────────────────────
  Widget _roomDetailsTable(LayoutModel layout) {
    final fi    = _selectedFloor.clamp(0, layout.floors.length - 1);
    final floor = layout.floors[fi];
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${floor.floorName} — Room Details',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
        ),
        ...floor.rooms.map(_roomItem),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _roomItem(RoomModel room) {
    const colors = {
      'bedroom': Color(0xFF1565C0), 'master_bedroom': Color(0xFF0D47A1),
      'living_room': Color(0xFF059669), 'drawing_room': Color(0xFF047857),
      'kitchen': Color(0xFFD97706), 'bathroom': Color(0xFF0284C7),
      'dining_room': Color(0xFF7C3AED), 'garage': Color(0xFF6B7280),
      'stairs': Color(0xFF4B5563), 'gallery': Color(0xFF8B5CF6),
      'open_area': Color(0xFF10B981),
    };
    final col = colors[room.roomType] ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.bgInput, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: col.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(_icon(room.roomType), color: col, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(room.roomName,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(
            '${room.dimensions.width.toStringAsFixed(1)} × '
                '${room.dimensions.length.toStringAsFixed(1)} ft  •  '
                '${room.dimensions.area.toStringAsFixed(0)} sqft',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _chip('${room.features.windows}W', Icons.window_outlined,         const Color(0xFF0284C7)),
          const SizedBox(height: 4),
          _chip('${room.features.doors}D',   Icons.door_back_door_outlined, const Color(0xFFD97706)),
        ]),
      ]),
    );
  }

  Widget _chip(String l, IconData ic, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(ic, size: 10, color: c),
      const SizedBox(width: 3),
      Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
    ]),
  );

  IconData _icon(String t) {
    switch (t) {
      case 'bedroom': case 'master_bedroom': return Icons.bed_outlined;
      case 'kitchen':      return Icons.kitchen_outlined;
      case 'bathroom':     return Icons.bathtub_outlined;
      case 'living_room':  return Icons.weekend_outlined;
      case 'dining_room':  return Icons.dining_outlined;
      case 'drawing_room': return Icons.chair_outlined;
      case 'garage':       return Icons.garage_outlined;
      case 'stairs':       return Icons.stairs_outlined;
      case 'gallery':      return Icons.straighten_outlined;
      default:             return Icons.room_outlined;
    }
  }

  // ── Recommendations ───────────────────────────────────────────────────────
  Widget _recommendationsCard(List<String> recs) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: AppColors.infoLight, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.lightbulb_outlined, color: AppColors.info, size: 20),
        SizedBox(width: 8),
        Text('AI Recommendations',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.info, fontSize: 14)),
      ]),
      const SizedBox(height: 10),
      ...recs.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ', style: TextStyle(color: AppColors.info)),
          Expanded(child: Text(r,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4))),
        ]),
      )),
    ]),
  );

  // ── Next steps ────────────────────────────────────────────────────────────
  Widget _nextStepsCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("What's Next?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 14),
      _next(Icons.inventory_2_outlined, 'Get Material List',  'See materials & costs',       '/materials', context),
      _next(Icons.calculate_outlined,   'Estimate Total Cost','Full PKR budget breakdown',   '/cost',      context),
      _next(Icons.palette_outlined,     'Design Interiors',   'AI room styling + images',    '/interior',  context),
      _next(Icons.chat_bubble_outline,  'Ask AI Expert',      'Civil engineering questions', '/chatbot',   context),
    ]),
  );

  Widget _next(IconData ic, String title, String desc, String route, BuildContext ctx) =>
      GestureDetector(
        onTap: () => Navigator.pushNamed(ctx, route),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
          child: Row(children: [
            Icon(ic, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              Text(desc,  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
          ]),
        ),
      );
}


// ══════════════════════════════════════════════════════════════════════════════
// ARCHITECTURAL PAINTER
// Draws: thick black walls, white room fills, furniture symbols,
//        door arcs, window notches, ALL-CAPS labels + dimensions
// ══════════════════════════════════════════════════════════════════════════════
class _ArchitecturalPainter extends CustomPainter {
  final List<RoomModel> rooms;
  final double scale;
  const _ArchitecturalPainter({required this.rooms, required this.scale});

  // wall paints
  static final _wallPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7
    ..color = const Color(0xFF111111);

  static final _wallFill = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  static final _thinLine = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8
    ..color = const Color(0xFF666666);

  static final _veryThin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5
    ..color = const Color(0xFFAAAAAA);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. white fill for every room (so rooms are white not transparent)
    for (final r in rooms) {
      final rect = _rect(r);
      canvas.drawRect(rect, _wallFill);
    }

    // 2. furniture symbols inside each room
    for (final r in rooms) {
      _drawFurniture(canvas, r);
    }

    // 3. thick walls + window notches
    for (final r in rooms) {
      final rect = _rect(r);
      // windows cut into top wall
      _drawWindowNotch(canvas, rect);
      // thick wall border
      canvas.drawRect(rect, _wallPaint);
      // door arc
      _drawDoor(canvas, r, rect);
    }

    // 4. labels
    for (final r in rooms) {
      _drawLabel(canvas, r, _rect(r));
    }
  }

  Rect _rect(RoomModel r) => Rect.fromLTWH(
    r.position.x * scale,
    r.position.y * scale,
    r.dimensions.width * scale,
    r.dimensions.length * scale,
  );

  // ── Window notch ──────────────────────────────────────────────────────────
  void _drawWindowNotch(Canvas canvas, Rect rect) {
    if (rect.width < 40) return;
    final wl = math.min(rect.width * 0.35, 55.0);
    final wx = rect.left + rect.width / 2 - wl / 2;
    final wy = rect.top;

    // erase wall section
    canvas.drawRect(
      Rect.fromLTWH(wx, wy - 3, wl, 13),
      Paint()..color = Colors.white,
    );
    // window frame — 3 lines (frame + centre divider)
    final winPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF333333);
    canvas.drawRect(Rect.fromLTWH(wx, wy, wl, 7), winPaint);
    canvas.drawLine(Offset(wx + wl / 2, wy), Offset(wx + wl / 2, wy + 7), winPaint);
  }

  // ── Door arc ──────────────────────────────────────────────────────────────
  void _drawDoor(Canvas canvas, RoomModel r, Rect rect) {
    if (r.roomType == 'stairs' || r.roomType == 'gallery' || r.roomType == 'open_area') return;
    final ds = math.min<double>(rect.width * 0.22, r.roomType == 'bathroom' ? 28 : 38);
    final dx = rect.left;
    final dy = rect.bottom;

    // clear wall gap
    canvas.drawRect(
      Rect.fromLTWH(dx, dy - 4, ds, 8),
      Paint()..color = Colors.white,
    );
    // door swing line
    canvas.drawLine(Offset(dx, dy), Offset(dx + ds, dy), _thinLine);
    // door arc
    canvas.drawArc(
      Rect.fromLTWH(dx, dy - ds, ds * 2, ds * 2),
      -math.pi / 2,
      math.pi / 2,
      false,
      _thinLine,
    );
  }

  // ── Furniture ─────────────────────────────────────────────────────────────
  void _drawFurniture(Canvas canvas, RoomModel r) {
    final rect = _rect(r);
    switch (r.roomType) {
      case 'living_room':
      case 'drawing_room': _sofa(canvas, rect); _coffeeTable(canvas, rect); break;
      case 'dining_room':  _diningTable(canvas, rect); break;
      case 'master_bedroom': _bed(canvas, rect, master: true); _wardrobe(canvas, rect); break;
      case 'bedroom':      _bed(canvas, rect, master: false); _wardrobe(canvas, rect); break;
      case 'bathroom':     _bathroom(canvas, rect); break;
      case 'kitchen':      _kitchen(canvas, rect); break;
      case 'stairs':       _stairs(canvas, rect); break;
      case 'garage':       _garage(canvas, rect); break;
    }
  }

  Paint get _furnitureFill => Paint()..color = const Color(0xFFEEEEEE)..style = PaintingStyle.fill;

  void _sofa(Canvas canvas, Rect r) {
    final sw = r.width * .54, sh = r.height * .22;
    final sx = r.left + r.width * .08, sy = r.top + r.height * .14;
    // back
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(sx, sy, sw, sh * .3), const Radius.circular(3)), _furnitureFill);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(sx, sy, sw, sh * .3), const Radius.circular(3)), _thinLine);
    // seat
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(sx, sy + sh * .3, sw, sh * .65), const Radius.circular(3)), _furnitureFill);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(sx, sy + sh * .3, sw, sh * .65), const Radius.circular(3)), _thinLine);
    // arms
    canvas.drawRect(Rect.fromLTWH(sx - sh * .18, sy, sh * .18, sh), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(sx - sh * .18, sy, sh * .18, sh), _thinLine);
    canvas.drawRect(Rect.fromLTWH(sx + sw, sy, sh * .18, sh), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(sx + sw, sy, sh * .18, sh), _thinLine);
    // cushion lines
    final cw = (sw - 6) / 3;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(sx + 3 + i * cw, sy + sh * .35, cw - 2, sh * .58), _veryThin);
    }
  }

  void _coffeeTable(Canvas canvas, Rect r) {
    final tw = r.width * .28, th = r.height * .08;
    final tx = r.left + r.width * .2, ty = r.top + r.height * .42;
    canvas.drawRect(Rect.fromLTWH(tx, ty, tw, th), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(tx, ty, tw, th), _thinLine);
    canvas.drawRect(Rect.fromLTWH(tx + 2, ty + 2, tw - 4, th - 4), _veryThin);
  }

  void _diningTable(Canvas canvas, Rect r) {
    final tw = r.width * .46, th = r.height * .42;
    final tx = r.left + r.width * .27, ty = r.top + r.height * .2;
    // ellipse table
    final tablePaint = Paint()..color = const Color(0xFFE8E8E8)..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(tx, ty, tw, th), tablePaint);
    canvas.drawOval(Rect.fromLTWH(tx, ty, tw, th), _thinLine);
    // chairs (6)
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi * 2 / 6) * i - math.pi / 2;
      final cr    = math.max(tw, th) / 2 + 12;
      final cx2   = tx + tw / 2 + math.cos(angle) * cr;
      final cy2   = ty + th / 2 + math.sin(angle) * cr;
      canvas.save();
      canvas.translate(cx2, cy2);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(-7, -7, 14, 12), const Radius.circular(2)), _furnitureFill);
      canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(-7, -7, 14, 12), const Radius.circular(2)), _veryThin);
      canvas.restore();
    }
  }

  void _bed(Canvas canvas, Rect r, {required bool master}) {
    final bw = math.min<double>(r.width * .55, master ? 90 : 72);
    final bh = math.min<double>(r.height * .52, master ? 110 : 88);
    final bx = r.left + r.width / 2 - bw / 2 + 8;
    final by = r.top + r.height * .08;
    // mattress
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh), const Radius.circular(4)), _furnitureFill);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh), const Radius.circular(4)), _thinLine);
    // headboard
    final headPaint = Paint()..color = const Color(0xFFCCCCCC)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh * .18), const Radius.circular(3)), headPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh * .18), const Radius.circular(3)), _thinLine);
    // pillow(s)
    final pillowPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final pw2 = bw * (master ? .36 : .7), ph = bh * .13;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + bw * .06, by + bh * .20, pw2, ph), const Radius.circular(3)), pillowPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + bw * .06, by + bh * .20, pw2, ph), const Radius.circular(3)), _veryThin);
    if (master) {
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(bx + bw * .56, by + bh * .20, pw2, ph), const Radius.circular(3)), pillowPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(bx + bw * .56, by + bh * .20, pw2, ph), const Radius.circular(3)), _veryThin);
    }
    // blanket fold line
    canvas.drawLine(Offset(bx + 4, by + bh * .40), Offset(bx + bw - 4, by + bh * .40), _veryThin);
    // bedside table
    canvas.drawRect(Rect.fromLTWH(bx - 16, by + bh * .20, 13, 13), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(bx - 16, by + bh * .20, 13, 13), _thinLine);
  }

  void _wardrobe(Canvas canvas, Rect r) {
    final ww = 15.0, wh = math.min<double>(r.height * .38, 65);
    final wx = r.left + r.width - ww - 3, wy = r.top + r.height * .14;
    canvas.drawRect(Rect.fromLTWH(wx, wy, ww, wh), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(wx, wy, ww, wh), _thinLine);
    // hatch lines
    var y = wy;
    while (y < wy + wh) {
      canvas.drawLine(Offset(wx, y), Offset(wx + ww, y), _veryThin);
      y += 4.5;
    }
    // centre divide
    canvas.drawLine(Offset(wx + ww / 2, wy), Offset(wx + ww / 2, wy + wh), _thinLine);
  }

  void _bathroom(Canvas canvas, Rect r) {
    // shower hatch
    final hx = r.left + r.width * .06, hy = r.top + r.height * .08;
    final hw = r.width * .84, hh = r.height * .38;
    canvas.drawRect(Rect.fromLTWH(hx, hy, hw, hh), _furnitureFill);
    var xi = hx;
    while (xi < hx + hw) { canvas.drawLine(Offset(xi, hy), Offset(xi, hy + hh), _veryThin); xi += 6; }
    var yi = hy;
    while (yi < hy + hh) { canvas.drawLine(Offset(hx, yi), Offset(hx + hw, yi), _veryThin); yi += 6; }
    canvas.drawRect(Rect.fromLTWH(hx, hy, hw, hh), _thinLine);
    // shower head
    canvas.drawCircle(Offset(hx + hw * .8, hy + hh * .15), 4, _thinLine);

    // toilet
    final tw2 = math.min<double>(r.width * .38, 28);
    final th  = math.min<double>(r.height * .38, 36);
    final tx2 = r.left + r.width * .54, ty2 = r.top + r.height * .52;
    // tank
    canvas.drawRect(Rect.fromLTWH(tx2, ty2, tw2, th * .33), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(tx2, ty2, tw2, th * .33), _thinLine);
    // bowl
    canvas.drawOval(Rect.fromLTWH(tx2 + tw2 * .05, ty2 + th * .30, tw2 * .9, th * .68), _furnitureFill);
    canvas.drawOval(Rect.fromLTWH(tx2 + tw2 * .05, ty2 + th * .30, tw2 * .9, th * .68), _thinLine);

    // sink/vanity
    final sw2 = math.min<double>(r.width * .5, 34);
    final sh2 = math.min<double>(r.height * .26, 24);
    final sx2 = r.left + r.width * .06, sy2 = r.top + r.height * .6;
    canvas.drawRect(Rect.fromLTWH(sx2, sy2, sw2, sh2), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(sx2, sy2, sw2, sh2), _thinLine);
    canvas.drawCircle(Offset(sx2 + sw2 / 2, sy2 + sh2 / 2), math.min(sw2, sh2) * .28, _thinLine);
  }

  void _kitchen(Canvas canvas, Rect r) {
    // countertop top wall
    final ch2 = 16.0;
    canvas.drawRect(Rect.fromLTWH(r.left + 3, r.top + 3, r.width - 6, ch2), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(r.left + 3, r.top + 3, r.width - 6, ch2), _thinLine);
    // sink
    canvas.drawRect(Rect.fromLTWH(r.left + 5, r.top + 5, 18, 12), Paint()..color = const Color(0xFFD8D8D8)..style = PaintingStyle.fill);
    canvas.drawRect(Rect.fromLTWH(r.left + 5, r.top + 5, 18, 12), _thinLine);
    canvas.drawCircle(Offset(r.left + 14, r.top + 11), 3.5, _thinLine);
    // stove
    final by2 = r.top + r.height * .34;
    canvas.drawRect(Rect.fromLTWH(r.left + 3, by2, r.width - 6, r.height * .28), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(r.left + 3, by2, r.width - 6, r.height * .28), _thinLine);
    for (final pos in [
      [.22, .35], [.68, .35], [.22, .68], [.68, .68]
    ]) {
      final cx2 = r.left + 3 + (r.width - 6) * pos[0];
      final cy2 = by2 + r.height * .28 * pos[1];
      canvas.drawCircle(Offset(cx2, cy2), 6, _thinLine);
      canvas.drawCircle(Offset(cx2, cy2), 2.5, _thinLine);
    }
    // side counter
    canvas.drawRect(Rect.fromLTWH(r.left + 3, r.top + 3 + ch2, 11, r.height * .28), _furnitureFill);
    canvas.drawRect(Rect.fromLTWH(r.left + 3, r.top + 3 + ch2, 11, r.height * .28), _thinLine);
  }

  void _stairs(Canvas canvas, Rect r) {
    const steps = 8;
    final sw = r.width - 8, sh = (r.height - 8) / steps;
    for (int i = 0; i < steps; i++) {
      final fill = Paint()..color = i.isEven ? const Color(0xFFF0F0F0) : const Color(0xFFE4E4E4)..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(r.left + 4, r.top + 4 + i * sh, sw, sh), fill);
      canvas.drawRect(Rect.fromLTWH(r.left + 4, r.top + 4 + i * sh, sw, sh), _veryThin);
    }
  }

  void _garage(Canvas canvas, Rect r) {
    const cols = 4;
    final cw2 = (r.width - 6) / cols;
    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(
          Offset(r.left + 3 + i * cw2, r.top + 4),
          Offset(r.left + 3 + i * cw2, r.bottom - 4), _veryThin);
    }
    // car silhouette
    final carW = r.width * .6, carH = r.height * .44;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(r.left + (r.width - carW) / 2, r.top + (r.height - carH) / 2, carW, carH),
          const Radius.circular(6)),
      _furnitureFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(r.left + (r.width - carW) / 2, r.top + (r.height - carH) / 2, carW, carH),
          const Radius.circular(6)),
      _thinLine,
    );
  }

  // ── Label ─────────────────────────────────────────────────────────────────
  void _drawLabel(Canvas canvas, RoomModel r, Rect rect) {
    final name = r.roomName.toUpperCase();
    final dim  = '${r.dimensions.width.toStringAsFixed(0)}×${r.dimensions.length.toStringAsFixed(0)}ft';
    final fs   = math.max(7.0, math.min(10.5, rect.width / name.length * .85));

    void paintText(String text, Offset offset, double size, {bool bold = false}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: size,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: bold ? .5 : 0,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: rect.width - 6);
      tp.paint(canvas, offset + Offset(-tp.width / 2, -tp.height / 2));
    }

    final cx = rect.left + rect.width / 2;
    final cy = rect.top  + rect.height / 2;

    paintText(name, Offset(cx, cy - fs * .6), fs, bold: true);
    paintText(dim,  Offset(cx, cy + fs * .8), fs * .78);
  }

  @override
  bool shouldRepaint(covariant _ArchitecturalPainter old) =>
      old.rooms != rooms || old.scale != scale;
}