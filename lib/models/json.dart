// Tolerant readers: the API mixes types (ids and quantities often arrive as
// strings), so models never hard-cast.

Map<String, dynamic> asMap(Object? value) =>
    value is Map<String, dynamic> ? value : const {};

List<Map<String, dynamic>> asMapList(Object? value) => (value is List ? value : const [])
    .whereType<Map>()
    .map((e) => e.cast<String, dynamic>())
    .toList();

Object? pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value != '') return value;
  }
  return null;
}

String pickString(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  final value = pick(json, keys);
  return value == null ? fallback : value.toString();
}

String? pickStringOrNull(Map<String, dynamic> json, List<String> keys) {
  final value = pick(json, keys);
  return value?.toString();
}

double pickDouble(Map<String, dynamic> json, List<String> keys, {double fallback = 0}) {
  final value = pick(json, keys);
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(' ', '').replaceAll(',', '.') ?? '') ?? fallback;
}

int pickInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
  final value = pick(json, keys);
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
