// lib/presentation/views/interior/interior_screen.dart
// v3 — supports Hugging Face base64 images via Image.memory()
//      also supports DALL-E URL images via Image.network()

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/interior_viewmodel.dart';
import '../../../data/models/interior_design_model.dart';

class InteriorScreen extends StatefulWidget {
  const InteriorScreen({super.key});

  @override
  State<InteriorScreen> createState() => _InteriorScreenState();
}

class _InteriorScreenState extends State<InteriorScreen> {
  String _roomType      = 'bedroom';
  double _roomSize      = 200;
  String _style         = 'modern';
  bool   _generateImage = true;
  final  _sizeCtrl      = TextEditingController(text: '200');

  @override
  void dispose() {
    _sizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InteriorViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(),
        body: Consumer<InteriorViewModel>(
          builder: (ctx, vm, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputCard(vm),
                const SizedBox(height: 20),
                if (vm.isLoading)
                  _buildLoading()
                else if (vm.errorMessage != null)
                  _buildError(vm.errorMessage!)
                else if (vm.interiorDesign != null)
                    _buildResults(vm),
              ],
            ),
          ),
        ),
      ),
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
      Text('Interior Design',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      Text('AI-powered room styling',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );

  // ── Input card ────────────────────────────────────────────────────────────
  Widget _buildInputCard(InteriorViewModel vm) {
    final roomTypes = {
      'bedroom':      'Bedroom',
      'living_room':  'Living Room',
      'kitchen':      'Kitchen',
      'bathroom':     'Bathroom',
      'drawing_room': 'Drawing Room',
      'dining_room':  'Dining Room',
    };
    final styles = ['modern', 'traditional', 'minimalist', 'luxury'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
            blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Interior Design Suggestions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 4),
        const Text('Room styling + FREE AI image via Hugging Face',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 20),

        // Room type chips
        const Text('Room Type',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: roomTypes.entries.map((e) {
            final sel = _roomType == e.key;
            return GestureDetector(
              onTap: () => setState(() => _roomType = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: sel ? 1 : 0.3)),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: sel ? const Color(0xFF7C3AED) : Colors.white)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Size + style row
        Row(children: [
          Expanded(child: _whiteField('Room Size (sqft)', _sizeCtrl)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Style',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: DropdownButton<String>(
                value: _style, isExpanded: true, underline: const SizedBox(),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                items: styles.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s[0].toUpperCase() + s.substring(1)),
                )).toList(),
                onChanged: (v) => setState(() => _style = v!),
              ),
            ),
          ])),
        ]),
        const SizedBox(height: 14),

        // AI image toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Generate AI room image',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('Free · Hugging Face Stable Diffusion',
                    style: TextStyle(color: Colors.white60, fontSize: 10)),
              ]),
            ),
            Switch(
              value: _generateImage,
              onChanged: (v) => setState(() => _generateImage = v),
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF7C3AED),
            ),
          ]),
        ),
        const SizedBox(height: 18),

        // Generate button
        GestureDetector(
          onTap: vm.isLoading ? null : () {
            _roomSize = double.tryParse(_sizeCtrl.text) ?? 200;
            vm.fetchInteriorDesign(
              roomType:        _roomType,
              roomSize:        _roomSize,
              stylePreference: _style,
              generateImage:   _generateImage,
            );
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text(
              _generateImage ? 'Generate Design + AI Image →' : 'Get Design Ideas →',
              style: const TextStyle(
                  color: Color(0xFF7C3AED), fontWeight: FontWeight.w800, fontSize: 15),
            )),
          ),
        ),
      ]),
    );
  }

  Widget _whiteField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white, isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
        ),
      ),
    ],
  );

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoading() => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow),
    child: Column(children: [
      const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF7C3AED))),
      const SizedBox(height: 16),
      Text(
        _generateImage
            ? 'Generating AI room image...\nHugging Face may take 15–30 seconds.'
            : 'Generating design ideas...',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
      if (_generateImage) ...[
        const SizedBox(height: 8),
        const Text('FREE via Hugging Face Stable Diffusion',
            style: TextStyle(color: Color(0xFF7C3AED), fontSize: 11)),
      ],
    ]),
  );

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildError(String msg) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.errorLight,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.wifi_off, color: AppColors.error, size: 22),
      const SizedBox(width: 12),
      Expanded(child: Text(msg,
          style: const TextStyle(color: AppColors.error, fontSize: 13))),
    ]),
  );

  // ── Results ───────────────────────────────────────────────────────────────
  Widget _buildResults(InteriorViewModel vm) {
    final design = vm.interiorDesign!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── AI image section ──────────────────────────────────────────────────
      if (design.hasImage || design.imageError != null) ...[
        Row(children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 18),
          const SizedBox(width: 6),
          const Text('AI-Generated Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('Hugging Face · Free',
                style: TextStyle(fontSize: 10, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        _buildImageWidget(design),
        const SizedBox(height: 20),
      ],

      // ── Color themes ──────────────────────────────────────────────────────
      const Text('Color Themes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: design.colorThemes.length,
          itemBuilder: (ctx, i) {
            final t = design.colorThemes[i];
            final sel = vm.selectedThemeIndex == i;
            return GestureDetector(
              onTap: () => vm.setSelectedTheme(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: sel ? const Color(0xFF7C3AED) : AppColors.border,
                      width: sel ? 2 : 1),
                  boxShadow: sel ? AppColors.cardShadow : null,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _colorDot(t.mainWall), const SizedBox(width: 4),
                    _colorDot(t.accentWall), const SizedBox(width: 4),
                    _colorDot(t.ceiling),
                    if (sel) ...[const Spacer(),
                      const Icon(Icons.check_circle, color: Color(0xFF7C3AED), size: 16)],
                  ]),
                  const SizedBox(height: 10),
                  Text(t.themeName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(t.mood,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),

      // ── Furniture ─────────────────────────────────────────────────────────
      const Text('Furniture Recommendations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      ...design.furniture.map(_buildFurnitureCard),
      const SizedBox(height: 20),

      // ── Lighting ──────────────────────────────────────────────────────────
      _buildInfoCard('☀️', 'Lighting Design', AppColors.cardCost, [
        ['Primary',   design.lighting.primary ?? ''],
        ['Secondary', design.lighting.secondary.take(2).join(', ')],
        ['Ambient',   design.lighting.ambient.take(2).join(', ')],
      ]),
      const SizedBox(height: 12),

      // ── Ceiling ───────────────────────────────────────────────────────────
      _buildInfoCard('🏠', 'Ceiling Design', AppColors.cardLayout, [
        ['Type',     design.ceilingDesign.type],
        ['Material', design.ceilingDesign.material],
        ['Cost',     design.ceilingDesign.cost],
        ['Features', design.ceilingDesign.features.take(3).join(', ')],
      ]),
      const SizedBox(height: 12),

      // ── Tips ──────────────────────────────────────────────────────────────
      if (design.recommendations.isNotEmpty)
        _buildTipsCard(design.recommendations),
      const SizedBox(height: 20),
    ]);
  }

  // ── Image widget — handles BOTH base64 (HF) and URL (DALL-E) ─────────────
  Widget _buildImageWidget(InteriorDesignModel design) {
    // Hugging Face: base64 PNG
    if (design.imageBase64 != null) {
      try {
        final bytes = base64Decode(design.imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.memory(
            bytes,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, _, __) =>
                _imageErrorBox('Failed to decode image'),
          ),
        );
      } catch (_) {
        return _imageErrorBox('Invalid image data from server');
      }
    }

    // DALL-E: URL
    if (design.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          design.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF7C3AED)))),
            );
          },
          errorBuilder: (ctx, _, __) => _imageErrorBox('Image failed to load'),
        ),
      );
    }

    // Error / no image
    return _imageErrorBox(design.imageError ?? 'Image could not be generated');
  }

  Widget _imageErrorBox(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
    ),
    child: Column(children: [
      const Icon(Icons.image_not_supported_outlined,
          color: Color(0xFF7C3AED), size: 36),
      const SizedBox(height: 10),
      Text(message,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          textAlign: TextAlign.center),
      const SizedBox(height: 6),
      const Text('Add HF_API_TOKEN to .env to enable AI images\nGet free token at huggingface.co',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          textAlign: TextAlign.center),
    ]),
  );

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _colorDot(String colorName) {
    final colorMap = {
      'white': Colors.white, 'cream': const Color(0xFFFFFDD0),
      'beige': const Color(0xFFF5F5DC), 'grey': Colors.grey,
      'blue': Colors.blue, 'navy': const Color(0xFF001F5B),
      'green': Colors.green, 'brown': Colors.brown,
      'charcoal': const Color(0xFF424242), 'gold': const Color(0xFFF9A825),
      'terracotta': const Color(0xFFCC4E2A), 'ivory': const Color(0xFFFFFFF0),
    };
    final c = colorMap.entries
        .where((e) => colorName.toLowerCase().contains(e.key))
        .map((e) => e.value)
        .firstOrNull ?? Colors.blueGrey;
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle,
          border: Border.all(color: AppColors.border)),
    );
  }

  Widget _buildFurnitureCard(FurnitureItem f) {
    final isEssential = f.priority == 'essential';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.chair_outlined, color: Color(0xFF7C3AED), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.item,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('${f.dimensions} • ${f.position}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isEssential ? AppColors.errorLight : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isEssential ? 'Essential' : f.priority == 'recommended' ? 'Recommended' : 'Optional',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: isEssential ? AppColors.error : AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(f.priceRange,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _buildInfoCard(String icon, String title, Color iconColor,
      List<List<String>> rows) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
                color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 12),
      ...rows.where((r) => r[1].isNotEmpty).map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(width: 80,
              child: Text(r[0],
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          Expanded(child: Text(r[1],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                  color: AppColors.textPrimary))),
        ]),
      )),
    ]),
  );

  Widget _buildTipsCard(List<String> tips) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.lightbulb_outlined, color: Color(0xFF7C3AED), size: 20),
        SizedBox(width: 8),
        Text('Design Tips',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14,
                color: Color(0xFF7C3AED))),
      ]),
      const SizedBox(height: 10),
      ...tips.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ', style: TextStyle(color: Color(0xFF7C3AED))),
          Expanded(child: Text(t,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4))),
        ]),
      )),
    ]),
  );
}