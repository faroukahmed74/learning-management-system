enum CefrLevel {
  a1('A1'),
  a2('A2'),
  b1('B1'),
  b2('B2'),
  c1('C1'),
  c2('C2');

  const CefrLevel(this.label);
  final String label;

  static CefrLevel? fromString(String? value) {
    if (value == null) return null;
    for (final level in CefrLevel.values) {
      if (level.label == value.toUpperCase()) return level;
    }
    return null;
  }
}
