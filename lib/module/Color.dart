import 'dart:ui';

Color colorFromHex(String hex) {
  final red = int.parse(hex.substring(0, 2), radix: 16);
  final green = int.parse(hex.substring(2, 4), radix: 16);
  final blue = int.parse(hex.substring(4, 6), radix: 16);
  return Color.fromARGB(255, red, green, blue);
}