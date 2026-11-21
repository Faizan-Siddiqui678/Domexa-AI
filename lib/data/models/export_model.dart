import 'dart:typed_data';

class ExportResult {
  final String filename;
  final Uint8List bytes;
  final String? savedPath;
  const ExportResult({required this.filename, required this.bytes, this.savedPath});
  String get sizeLabel => '${(bytes.length / 1024).toStringAsFixed(0)} KB';
}