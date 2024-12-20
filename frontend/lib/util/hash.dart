import 'dart:math';

const String charmap = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

String randomHash(int size) {
  String result = "";
  for (int i = 0; i < size; i++) {
    result += charmap[Random().nextInt(charmap.length)];
  }
  return result;
}
