import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Tiny Markdown renderer for the chatbot's replies (verified against the backend's
/// real output: **bold**, *italic*, "- " / bullet lines, "#" headings and | tables |).
class ChatMarkdown extends StatelessWidget {
  const ChatMarkdown(this.text, {super.key, this.color = AppColors.text});
  final String text;
  final Color color;

  static final _inline = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
  static final _sep = RegExp(r'^[\s:|-]+$');

  List<InlineSpan> _spans(String line, {bool bold = false}) {
    final spans = <InlineSpan>[];
    var last = 0;
    final base = TextStyle(color: color, height: 1.4, fontWeight: bold ? FontWeight.w800 : FontWeight.w400);
    for (final m in _inline.allMatches(line)) {
      if (m.start > last) spans.add(TextSpan(text: line.substring(last, m.start), style: base));
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: base.copyWith(fontWeight: FontWeight.w800)));
      } else {
        spans.add(TextSpan(text: m.group(2), style: base.copyWith(fontStyle: FontStyle.italic)));
      }
      last = m.end;
    }
    if (last < line.length) spans.add(TextSpan(text: line.substring(last), style: base));
    return spans;
  }

  List<String> _cells(String row) {
    var r = row.trim();
    if (r.startsWith('|')) r = r.substring(1);
    if (r.endsWith('|')) r = r.substring(0, r.length - 1);
    return r.split('|').map((c) => c.trim()).toList();
  }

  Widget _table(List<String> rows) {
    final data = rows.where((r) => !_sep.hasMatch(r)).map(_cells).toList();
    if (data.isEmpty) return const SizedBox.shrink();
    final cols = data.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: AppColors.border),
          children: [
            for (var i = 0; i < data.length; i++)
              TableRow(
                decoration: i == 0 ? const BoxDecoration(color: AppColors.infoBg) : null,
                children: [
                  for (var c = 0; c < cols; c++)
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: RichText(text: TextSpan(children: _spans(c < data[i].length ? data[i][c] : '', bold: i == 0))),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = text.replaceAll('\r', '').split('\n');
    final out = <Widget>[];
    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final t = line.trim();
      if (t.startsWith('|')) {
        final block = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          block.add(lines[i]);
          i++;
        }
        out.add(_table(block));
        continue;
      }
      i++;
      if (t.isEmpty) {
        out.add(const SizedBox(height: 6));
      } else if (t.startsWith('#')) {
        out.add(Padding(padding: const EdgeInsets.only(top: 4, bottom: 2), child: RichText(text: TextSpan(children: _spans(t.replaceFirst(RegExp(r'^#+\s*'), ''), bold: true)))));
      } else if (t.startsWith('- ') || t.startsWith('• ') || t.startsWith('* ')) {
        out.add(Padding(
          padding: const EdgeInsets.only(left: 6, top: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: TextStyle(color: color)),
            Expanded(child: RichText(text: TextSpan(children: _spans(t.substring(2))))),
          ]),
        ));
      } else {
        out.add(Padding(padding: const EdgeInsets.symmetric(vertical: 1), child: RichText(text: TextSpan(children: _spans(t)))));
      }
    }
    return SelectionArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: out));
  }
}