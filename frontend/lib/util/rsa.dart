import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import "package:asn1lib/asn1lib.dart";
import 'dart:math';
import 'dart:async';
import 'package:universal_html/html.dart' as html;

class RSA {
  final int _chunkSize;

  RSA({int keySize = 2048}) : _chunkSize = 64;

  Future<Map<String, String>> generateKeyPairAdaptive() async {
    if (kIsWeb) {
      return await _generateKeyPairWeb();
    } else {
      return await compute(_generateKeyPairIsolate, null);
    }
  }

  Future<Map<String, String>> _generateKeyPairIsolate(_) async {
    // Geração do par de chaves RSA
    return _generateKeyPair();
  }

  Future<Map<String, String>> _generateKeyPair() async {
    final keyGen = RSAKeyGenerator();
    final secureRandom = FortunaRandom();
    final keyParams = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);

    Random random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    final rngParams = ParametersWithRandom(keyParams, secureRandom);

    keyGen.init(rngParams);

    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    return {
      "publicKey": _encodePublicKey(publicKey),
      "privateKey": _encodePrivateKey(privateKey),
    };
  }

  Future<Map<String, String>> _generateKeyPairWeb() async {
    final completer = Completer<Map<String, String>>();
    final worker = html.Worker('rsa_worker_bootstrap.js'); // Caminho para o arquivo do Worker.

    try {
      worker.onMessage.listen((event) {
        final data = event.data;
        if (data['error'] != null) {
          completer.completeError(data['error']);
        } else {
          completer.complete({
            'publicKey': data['publicKey'],
            'privateKey': data['privateKey'],
          });
        }
        worker.terminate();
      });

      worker.onError.listen((error) {
        final errorMessage = error is html.ErrorEvent ? error.message ?? 'Erro desconhecido no Worker' : 'Erro inesperado: $error';

        completer.completeError(errorMessage);
        worker.terminate();
      });
    } catch (e) {
      completer.completeError(e);
    }

    worker.postMessage('start'); // Sinaliza o Worker para começar o processamento.
    return completer.future;
  }

  /// Criptografa com a chave pública
  String cipherWithPublicKey(String message, String publicKeyPem) {
    final publicKey = _parsePublicKey(publicKeyPem);
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));

    // Divide a mensagem em blocos e criptografa cada um
    final blocks = _chunkMessage(message);
    final encryptedBlocks = blocks.map((block) {
      final encryptedBlock = encrypter.encrypt(block);
      return encryptedBlock.bytes; // Usa os bytes ao invés de Base64
    });

    // Concatena os blocos criptografados com o separador '|'
    return encryptedBlocks.map((bytes) => _bytesToHex(bytes)).join('|');
  }

  /// Descriptografa com a chave privada
  String decipherWithPrivateKey(String encrypted, String privateKeyPem) {
    final privateKey = _parsePrivateKey(privateKeyPem);
    final encrypter = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey, encoding: encrypt.RSAEncoding.OAEP));

    // Divide os blocos criptografados usando o separador '|'
    final blocks = encrypted.trim().replaceAll(' ', '').split('|');

    // Descriptografa cada bloco
    final decryptedBlocks = blocks.map((blockHex) {
      if (blockHex.trim() != '' && blockHex.isNotEmpty) {
        final decrypted = encrypter.decrypt16(blockHex);
        return decrypted;
      } else {
        return '';
      }
    });

    // Concatena os blocos descriptografados
    return decryptedBlocks.join('');
  }

  /// Divide a mensagem em blocos
  List<String> _chunkMessage(String input) {
    final bytes = utf8.encode(input);
    final chunks = <String>[];
    for (var i = 0; i < bytes.length; i += _chunkSize) {
      chunks.add(utf8.decode(bytes.sublist(i, i + _chunkSize > bytes.length ? bytes.length : i + _chunkSize)));
    }
    return chunks;
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  String _encodePublicKey(RSAPublicKey publicKey) {
    var algorithmSeq = ASN1Sequence();
    var algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1Obj);

    var publicKeySeq = ASN1Sequence();
    publicKeySeq.add(ASN1Integer(publicKey.modulus!));
    publicKeySeq.add(ASN1Integer(publicKey.exponent!));
    var publicKeySeqBitString = ASN1BitString(Uint8List.fromList(publicKeySeq.encodedBytes));

    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqBitString);
    var dataBase64 = base64.encode(topLevelSeq.encodedBytes);

    return """-----BEGIN PUBLIC KEY-----\r\n$dataBase64\r\n-----END PUBLIC KEY-----""";
  }

  String _encodePrivateKey(RSAPrivateKey privateKey) {
    var version = ASN1Integer(BigInt.from(0));

    var algorithmSeq = ASN1Sequence();
    var algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1Obj);

    var privateKeySeq = ASN1Sequence();
    var modulus = ASN1Integer(privateKey.n!);
    var publicExponent = ASN1Integer(BigInt.parse('65537'));
    var privateExponent = ASN1Integer(privateKey.privateExponent!);
    var p = ASN1Integer(privateKey.p!);
    var q = ASN1Integer(privateKey.q!);
    var dP = privateKey.privateExponent! % (privateKey.p! - BigInt.from(1));
    var exp1 = ASN1Integer(dP);
    var dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.from(1));
    var exp2 = ASN1Integer(dQ);
    var iQ = privateKey.q!.modInverse(privateKey.p!);
    var co = ASN1Integer(iQ);

    privateKeySeq.add(version);
    privateKeySeq.add(modulus);
    privateKeySeq.add(publicExponent);
    privateKeySeq.add(privateExponent);
    privateKeySeq.add(p);
    privateKeySeq.add(q);
    privateKeySeq.add(exp1);
    privateKeySeq.add(exp2);
    privateKeySeq.add(co);
    var publicKeySeqOctetString = ASN1OctetString(Uint8List.fromList(privateKeySeq.encodedBytes));

    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(version);
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqOctetString);
    var dataBase64 = base64.encode(topLevelSeq.encodedBytes);

    return """-----BEGIN PRIVATE KEY-----\r\n$dataBase64\r\n-----END PRIVATE KEY-----""";
  }

  /// Analisa uma chave pública PEM
  RSAPublicKey _parsePublicKey(String publicKeyPem) {
    return encrypt.RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;
  }

  /// Analisa uma chave privada PEM
  RSAPrivateKey _parsePrivateKey(String privateKeyPem) {
    return encrypt.RSAKeyParser().parse(privateKeyPem) as RSAPrivateKey;
  }
}
