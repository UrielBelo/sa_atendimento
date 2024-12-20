import 'package:encrypt/encrypt.dart' as encrypt;

String aesEncrypt(String data, String key, String iv) {
  final cipherKey = encrypt.Key.fromUtf8(key);
  final cipherIv = encrypt.IV.fromUtf8(iv);

  if (key.length != 16 || iv.length != 16) {
    Exception("A String Chave deve ter 16 dígitos");
  }

  final encrypter = encrypt.Encrypter(
    encrypt.AES(
      cipherKey,
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ),
  );

  final encrypted = encrypter.encrypt(data, iv: cipherIv);
  return encrypted.base16;
}

String aesDecrypt(String data, String key, String iv) {
  final cipherKey = encrypt.Key.fromUtf8(key);
  final cipherIv = encrypt.IV.fromUtf8(iv);

  if (key.length != 16 || iv.length != 16) {
    Exception("A String Chave deve ter 16 dígitos");
  }

  final decrypter = encrypt.Encrypter(
    encrypt.AES(
      cipherKey,
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ),
  );
  final decrypted = decrypter.decrypt16(data, iv: cipherIv);
  return decrypted;
}
