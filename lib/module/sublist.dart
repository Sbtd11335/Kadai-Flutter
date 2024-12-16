List<T> subList<T>(List<T> list, int start, int end) {
  final s = start >= 0 ? start : 0;
  final e = end < list.length ? end : list.length;
  return list.sublist(s, e);
}