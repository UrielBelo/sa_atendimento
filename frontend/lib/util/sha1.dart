import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';

String sha1(String data) {
  var bytes = utf8.encode(data);
  var digest = crypto.sha1.convert(bytes);
  return digest.toString();
}
