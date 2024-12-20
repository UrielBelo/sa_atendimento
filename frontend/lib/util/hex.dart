import 'dart:convert';

String stringToHex(String input) {
  List<int> bytes = utf8.encode(input);
  final buffer = StringBuffer();
  for (int byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

String hexToString(String hex) {
  List<int> bytes = [];
  for (int i = 0; i < hex.length; i += 2) {
    String byteString = hex.substring(i, i + 2);
    int byte = int.parse(byteString, radix: 16);
    bytes.add(byte);
  }
  return utf8.decode(bytes);
}
