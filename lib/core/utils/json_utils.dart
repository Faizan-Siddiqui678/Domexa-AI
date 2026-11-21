/// Defensive JSON readers: the backend's LLM-driven payloads can omit keys.
double jd(dynamic v, [double def = 0]) =>
    v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? def);
int ji(dynamic v, [int def = 0]) =>
    v is num ? v.round() : (int.tryParse('${v ?? ''}') ?? def);
String js(dynamic v, [String def = '']) => v == null ? def : '$v';
Map<String, dynamic> jmap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<String> jstrings(dynamic v) =>
    v is List ? v.map((e) => '$e').toList() : <String>[];
List<T> jlist<T>(dynamic v, T Function(Map<String, dynamic>) f) => v is List
    ? v.whereType<Map>().map((e) => f(Map<String, dynamic>.from(e))).toList()
    : <T>[];