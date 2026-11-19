// lib/presentation/views/interior/interior_screen.dart
// v4 — displays full Gemini LLM interior design response
//      Pakistani-specific fields: paint brands, PKR prices, city, budget
//      AI room image via Hugging Face (base64)

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
  String _style         = 'modern';
  String _budget        = 'standard';
  String _city          = 'lahore';
  double _roomSize      = 200;
  bool   _generateImage = true;
  final  _sizeCtrl      = TextEditingController(text: '200');

  @override
  void dispose() { _sizeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InteriorViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(),
        body: Consumer<InteriorViewModel>(
          builder: (ctx, vm, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _inputCard(vm),
              const SizedBox(height: 16),
              if (vm.isLoading)   _loadingCard()
              else if (vm.errorMessage != null) _errorCard(vm.errorMessage!)
              else if (vm.design  != null) _results(vm),
            ]),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: AppColors.surface, elevation: 0,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
      ),
    ),
    title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Interior Design', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      Text('AI-powered · Gemini + Hugging Face', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );

  // ── Input card ────────────────────────────────────────────────────────────
  Widget _inputCard(InteriorViewModel vm) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
          blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Interior Design Suggestions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
      const Text('Gemini AI · Pakistani market prices · Free room image',
          style: TextStyle(color: Colors.white70, fontSize: 11)),
      const SizedBox(height: 18),

      // Room type
      _label('Room Type'),
      Wrap(spacing: 6, runSpacing: 6, children: InteriorViewModel.roomOptions.asMap().entries.map((e) {
        final sel = _roomType == e.value;
        return GestureDetector(
          onTap: () => setState(() => _roomType = e.value),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: sel ? 1 : 0.3)),
            ),
            child: Text(InteriorViewModel.roomLabels[e.key],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: sel ? const Color(0xFF7C3AED) : Colors.white)),
          ),
        );
      }).toList()),
      const SizedBox(height: 14),

      // Style
      _label('Style'),
      Wrap(spacing: 6, runSpacing: 6, children: InteriorViewModel.styleOptions.asMap().entries.map((e) {
        final sel = _style == e.value;
        return GestureDetector(
          onTap: () => setState(() => _style = e.value),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: sel ? 1 : 0.3)),
            ),
            child: Text(InteriorViewModel.styleLabels[e.key],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: sel ? const Color(0xFF7C3AED) : Colors.white)),
          ),
        );
      }).toList()),
      const SizedBox(height: 14),

      // Budget + City row
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Budget'),
          _dropdown(
            value: _budget,
            items: List.generate(InteriorViewModel.budgetOptions.length,
                    (i) => DropdownMenuItem(value: InteriorViewModel.budgetOptions[i],
                    child: Text(InteriorViewModel.budgetLabels[i]))),
            onChanged: (v) => setState(() => _budget = v!),
          ),
        ])),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('City'),
          _dropdown(
            value: _city,
            items: List.generate(InteriorViewModel.cityOptions.length,
                    (i) => DropdownMenuItem(value: InteriorViewModel.cityOptions[i],
                    child: Text(InteriorViewModel.cityLabels[i]))),
            onChanged: (v) => setState(() => _city = v!),
          ),
        ])),
      ]),
      const SizedBox(height: 14),

      // Room size
      _label('Room Size (sqft)'),
      TextFormField(
        controller: _sizeCtrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white, isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
        ),
      ),
      const SizedBox(height: 14),

      // AI image toggle
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Generate AI Room Image', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('Free · Hugging Face Stable Diffusion · ~20-40s', style: TextStyle(color: Colors.white60, fontSize: 10)),
          ])),
          Switch(
            value: _generateImage,
            onChanged: (v) => setState(() => _generateImage = v),
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            activeTrackColor: const Color(0xFF7C3AED),
          ),
        ]),
      ),
      const SizedBox(height: 16),

      // Generate button
      GestureDetector(
        onTap: vm.isLoading ? null : () {
          _roomSize = double.tryParse(_sizeCtrl.text) ?? 200;
          vm.fetchInteriorDesign(
            roomType:        _roomType,
            roomSize:        _roomSize,
            stylePreference: _style,
            budget:          _budget,
            city:            _city,
            generateImage:   _generateImage,
          );
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Center(child: Text(
            _generateImage ? 'Generate Design + AI Image →' : 'Get Design Ideas →',
            style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w800, fontSize: 15),
          )),
        ),
      ),
    ]),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
  );

  Widget _dropdown({required String value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: DropdownButton<String>(
          value: value, isExpanded: true, underline: const SizedBox(),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
          items: items, onChanged: onChanged,
        ),
      );

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _loadingCard() => Container(
    padding: const EdgeInsets.all(36),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
    child: Column(children: [
      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF7C3AED))),
      const SizedBox(height: 16),
      Text(
        _generateImage
            ? 'Gemini AI is designing your room...\nThen generating AI image via Hugging Face.\nThis may take 20–40 seconds.'
            : 'Gemini AI is designing your room...',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, height: 1.5),
      ),
      const SizedBox(height: 8),
      const Text('🆓 Powered by Gemini 1.5 Flash + Hugging Face (both free)',
          style: TextStyle(color: Color(0xFF7C3AED), fontSize: 11),
          textAlign: TextAlign.center),
    ]),
  );

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _errorCard(String msg) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
    child: Row(children: [
      const Icon(Icons.error_outline, color: AppColors.error),
      const SizedBox(width: 12),
      Expanded(child: Text(msg, style: const TextStyle(color: AppColors.error, fontSize: 13))),
    ]),
  );

  // ── Results ───────────────────────────────────────────────────────────────
  Widget _results(InteriorViewModel vm) {
    final d = vm.design!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Design theme banner
      if (d.designTheme.isNotEmpty) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Design Theme', style: TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(d.designTheme, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Text('${d.city.toUpperCase()} · ${d.budget.toUpperCase()} BUDGET · ${d.roomSize.toStringAsFixed(0)} SQFT',
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ]),
        ),
        const SizedBox(height: 16),
      ],

      // AI room image
      if (d.hasImage || d.imageError != null) ...[
        _sectionTitle('AI-Generated Room', Icons.auto_awesome, const Color(0xFF7C3AED)),
        const SizedBox(height: 10),
        _imageSection(d),
        const SizedBox(height: 20),
      ],

      // Color scheme
      if (d.colorScheme != null) ...[
        _sectionTitle('Color Scheme', Icons.palette_outlined, const Color(0xFF7C3AED)),
        const SizedBox(height: 10),
        _colorSchemeCard(d.colorScheme!),
        const SizedBox(height: 16),
      ],

      // Furniture
      if (d.furniture.isNotEmpty) ...[
        _sectionTitle('Furniture (PKR Prices)', Icons.chair_outlined, const Color(0xFF047857)),
        const SizedBox(height: 10),
        ...d.furniture.map(_furnitureCard),
        const SizedBox(height: 16),
      ],

      // Flooring + Ceiling row
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (d.flooring != null) Expanded(child: _flooringCard(d.flooring!)),
        if (d.flooring != null && d.ceiling != null) const SizedBox(width: 10),
        if (d.ceiling  != null) Expanded(child: _ceilingCard(d.ceiling!)),
      ]),
      if (d.flooring != null || d.ceiling != null) const SizedBox(height: 16),

      // Lighting
      if (d.lighting != null) ...[
        _lightingCard(d.lighting!),
        const SizedBox(height: 16),
      ],

      // Windows & Doors
      if (d.windowsDoors != null) ...[
        _windowsDoorsCard(d.windowsDoors!),
        const SizedBox(height: 16),
      ],

      // AC placement
      if (d.acPlacement.isNotEmpty) ...[
        _infoCard('❄️', 'AC Placement (Pakistan Essential)',
            [['Placement', d.acPlacement]], const Color(0xFF0284C7)),
        const SizedBox(height: 16),
      ],

      // Special features
      if (d.specialFeatures.isNotEmpty) ...[
        _bulletCard('⭐', 'Special Features', d.specialFeatures, const Color(0xFFD97706)),
        const SizedBox(height: 16),
      ],

      // Design tips
      if (d.designTips.isNotEmpty) ...[
        _bulletCard('💡', 'Design Tips (Pakistani Context)', d.designTips, const Color(0xFF7C3AED)),
        const SizedBox(height: 16),
      ],

      // Estimated cost
      if (d.estimatedCost != null) ...[
        _costCard(d.estimatedCost!),
        const SizedBox(height: 16),
      ],
    ]);
  }

  // ── Image ─────────────────────────────────────────────────────────────────
  Widget _imageSection(InteriorDesignModel d) {
    if (d.imageBase64 != null) {
      try {
        final bytes = base64Decode(d.imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(bytes, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imgError('Failed to decode image')),
        );
      } catch (_) {
        return _imgError('Invalid image data');
      }
    }
    return _imgError(d.imageError ?? 'Image not generated');
  }

  Widget _imgError(String msg) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2))),
    child: Column(children: [
      const Icon(Icons.image_not_supported_outlined, color: Color(0xFF7C3AED), size: 36),
      const SizedBox(height: 8),
      Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      const Text('Add HF_API_TOKEN to .env for free AI images\nhuggingface.co/settings/tokens',
          style: TextStyle(color: AppColors.textMuted, fontSize: 10), textAlign: TextAlign.center),
    ]),
  );

  // ── Color scheme ──────────────────────────────────────────────────────────
  Widget _colorSchemeCard(DesignColorScheme cs) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (cs.mood.isNotEmpty) Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('Mood: ${cs.mood}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
      ),
      _paintRow('Primary Wall', cs.primaryWall),
      const SizedBox(height: 10),
      _paintRow('Accent Wall', cs.accentWall),
      const SizedBox(height: 10),
      Row(children: [
        _colorDot(cs.ceiling.hex),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ceiling', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text(cs.ceiling.color, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ]),
        const Spacer(),
        _colorDot(cs.trim.hex),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Trim', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text(cs.trim.color, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ]),
      ]),
    ]),
  );

  Widget _paintRow(String label, PaintColor p) => Row(children: [
    _colorDot(p.hex),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
      Text(p.color, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      if (p.paintBrand.isNotEmpty)
        Text('${p.paintBrand} — ${p.paintName}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ])),
    if (p.pkrPrice.isNotEmpty)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
        child: Text(p.pkrPrice, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ),
  ]);

  Widget _colorDot(String hex) {
    Color c = Colors.grey;
    try {
      final h = hex.replaceAll('#', '');
      c = Color(int.parse('FF$h', radix: 16));
    } catch (_) {}
    return Container(width: 36, height: 36, decoration: BoxDecoration(
        color: c, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.5)));
  }

  // ── Furniture ─────────────────────────────────────────────────────────────
  Widget _furnitureCard(FurnitureItem f) {
    final isEss = f.priority == 'essential';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.chair_outlined, color: Color(0xFF7C3AED), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(f.item, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isEss ? AppColors.errorLight : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(f.priority.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: isEss ? AppColors.error : AppColors.primary)),
          ),
        ]),
        if (f.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(f.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4)),
        ],
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: [
          if (f.dimensions.isNotEmpty)   _chip('📐 ${f.dimensions}'),
          if (f.placement.isNotEmpty)    _chip('📍 ${f.placement}'),
          if (f.material.isNotEmpty)     _chip('🪵 ${f.material}'),
          if (f.localBrand.isNotEmpty)   _chip('🏪 ${f.localBrand}'),
        ]),
        if (f.pkrPriceRange.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text('💰 ${f.pkrPriceRange}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w700)),
          ),
        ],
      ]),
    );
  }

  // ── Flooring ──────────────────────────────────────────────────────────────
  Widget _flooringCard(FlooringDesign f) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Flooring', Icons.grid_on, const Color(0xFFD97706)),
      const SizedBox(height: 10),
      _row('Type',   f.type),
      _row('Brand',  f.brand),
      _row('Color',  f.color),
      _row('Price',  '${f.pkrPerSqft}/sqft'),
    ]),
  );

  // ── Ceiling ───────────────────────────────────────────────────────────────
  Widget _ceilingCard(CeilingDesign c) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Ceiling', Icons.roofing_outlined, const Color(0xFF4B5563)),
      const SizedBox(height: 10),
      _row('Type',     c.type),
      _row('Material', c.material),
      _row('Design',   c.design),
      _row('Cost',     '${c.pkrPerSqft}/sqft'),
      if (c.features.isNotEmpty) ...[
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 4,
            children: c.features.map((f) => _chip(f)).toList()),
      ],
    ]),
  );

  // ── Lighting ──────────────────────────────────────────────────────────────
  Widget _lightingCard(LightingDesign l) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Lighting Design', Icons.wb_sunny_outlined, const Color(0xFFD97706)),
      const SizedBox(height: 10),
      if (l.main != null) ...[
        _row('Main Light', '${l.main!.type} — ${l.main!.description}'),
        if (l.main!.pkrPrice.isNotEmpty) _row('Price', l.main!.pkrPrice),
      ],
      if (l.colorTemperature.isNotEmpty) _row('Color Temp', l.colorTemperature),
      if (l.ambient.isNotEmpty)          _row('Ambient', l.ambient),
      if (l.secondary.isNotEmpty) ...[
        const SizedBox(height: 6),
        const Text('Secondary Lights:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 4),
        ...l.secondary.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            const Text('  • ', style: TextStyle(color: Color(0xFF7C3AED))),
            Expanded(child: Text('${s.type} — ${s.description}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
          ]),
        )),
      ],
    ]),
  );

  // ── Windows & Doors ───────────────────────────────────────────────────────
  Widget _windowsDoorsCard(WindowsDoors w) => _infoCard(
    '🪟', 'Windows & Doors',
    [
      ['Curtain Type',     w.curtainType],
      ['Curtain Color',    w.curtainColor],
      ['Curtain Material', w.curtainMaterial],
      ['Door Style',       w.doorStyle],
      ['Door Material',    w.doorMaterial],
    ],
    const Color(0xFF4B5563),
  );

  // ── Cost estimate ─────────────────────────────────────────────────────────
  Widget _costCard(EstimatedCost c) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF047857), Color(0xFF065F46)]),
        borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Estimated Total Cost (PKR)', style: TextStyle(color: Colors.white70, fontSize: 11)),
      const SizedBox(height: 10),
      Row(children: [
        _costBox('Economy',  c.economy,  '🟢'),
        const SizedBox(width: 8),
        _costBox('Standard', c.standard, '🟡'),
        const SizedBox(width: 8),
        _costBox('Luxury',   c.luxury,   '🔴'),
      ]),
    ]),
  );

  Widget _costBox(String label, String value, String emoji) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
      ]),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon, Color color) => Row(children: [
    Icon(icon, color: color, size: 18),
    const SizedBox(width: 8),
    Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
  ]);

  Widget _infoCard(String emoji, String title, List<List<String>> rows, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
      ]),
      const SizedBox(height: 10),
      ...rows.where((r) => r[1].isNotEmpty).map((r) => _row(r[0], r[1])),
    ]),
  );

  Widget _bulletCard(String emoji, String title, List<String> items, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
      ]),
      const SizedBox(height: 10),
      ...items.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          Expanded(child: Text(t, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4))),
        ]),
      )),
    ]),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 95, child: Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))),
      Expanded(child: Text(value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary))),
    ]),
  );

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border)),
    child: Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  );
}