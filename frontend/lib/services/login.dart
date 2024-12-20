import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/classes/session.dart';
import 'package:frontend/components/alert.dart';
import 'package:frontend/util/aes.dart';
import 'package:frontend/util/cookie.dart';
import 'package:frontend/util/hex.dart';
import 'package:frontend/util/http.dart';
import 'package:frontend/util/rsa.dart';
import 'package:frontend/util/sha256.dart';
import 'package:http/http.dart';
import '../util/global.dart';

class LoginService {
  final String login;
  final String password;
  String? publicKeyPem;
  String? privateKeyPem;
  String? aesKey;
  String? aesIv;
  String? sessionHash;

  LoginService({
    required this.login,
    required this.password,
  });

  Future<String?> getLogin(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1)); //Para não congelar a animação
    RSA rsa = RSA();
    HTTPUtil http = HTTPUtil();

    String usernameHash = sha256(login);
    Map<String, String> rsaKeyPair = await rsa.generateKeyPairAdaptive();
    DateTime currentTimestamp = DateTime.now();

    publicKeyPem = rsaKeyPair['publicKey']!;
    privateKeyPem = rsaKeyPair['privateKey']!;

    try {
      Response preLoginResponse = await http.post('${Global.url}/auth/prelogin', {
        'usernameHash': usernameHash,
        'publicKey': stringToHex(publicKeyPem!),
        'timestamp': currentTimestamp.millisecondsSinceEpoch,
      });

      Map<String, dynamic> preLoginResponseJson = jsonDecode(preLoginResponse.body);
      if (preLoginResponseJson.containsKey('error')) {
        if (context.mounted) {
          showAlertWithText(context, Icons.error_outline, preLoginResponseJson['error']);
        }
        return null;
      }
      sessionHash = rsa.decipherWithPrivateKey(preLoginResponseJson['sessionHash'], privateKeyPem!);
      await Future.delayed(const Duration(milliseconds: 500)); //Para não congelar a animação
      aesKey = rsa.decipherWithPrivateKey(preLoginResponseJson['aesKey'], privateKeyPem!);
      await Future.delayed(const Duration(milliseconds: 500)); //Para não congelar a animação
      aesIv = rsa.decipherWithPrivateKey(preLoginResponseJson['aesIv'], privateKeyPem!);

      currentTimestamp = DateTime.now();
      String passwordHash = sha256(password);

      Response loginResponse = await http.post('${Global.url}/auth/login', {
        'usernameHash': usernameHash,
        'timestamp': currentTimestamp.millisecondsSinceEpoch,
        'username': aesEncrypt(login, aesKey!, aesIv!),
        'password': aesEncrypt(passwordHash, aesKey!, aesIv!),
      });

      Map<String, dynamic> loginResponseJson = jsonDecode(loginResponse.body);

      if (loginResponseJson.containsKey('error')) {
        if (context.mounted) {
          showAlertWithText(context, Icons.error_outline, loginResponseJson['error']);
        }
        return null;
      }

      String sessionAesIv = aesDecrypt(loginResponseJson['newAesIv'], aesKey!, aesIv!);
      String sessionAesKey = aesDecrypt(loginResponseJson['newAesKey'], aesKey!, aesIv!);
      String newSessionHash = aesDecrypt(loginResponseJson['sessionHash'], aesKey!, aesIv!);
      String signToken = aesDecrypt(loginResponseJson['signToken'], aesKey!, aesIv!);
      String userId = aesDecrypt(loginResponseJson['userId'], aesKey!, aesIv!);

      Global.aesIv = sessionAesIv;
      Global.aesKey = sessionAesKey;
      Session newSession = Session(
        userId: userId,
        sessionHash: newSessionHash,
        signToken: signToken,
        username: login,
      );
      Global.session = newSession;
      saveSession(sessionAesKey, sessionAesIv, newSession);
      return 'ok';
    } on Exception catch (e) {
      if (context.mounted) {
        showAlertWithText(context, Icons.error_outline, '$e');
      }
      return null;
    }
  }
}
