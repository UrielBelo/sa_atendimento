import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'dart:typed_data';

String sha256(String data) {
  Uint8List bytesList = utf8.encode(data);
  crypto.Digest digest = crypto.sha256.convert(bytesList);
  return digest.toString();
}
