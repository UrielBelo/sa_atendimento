import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/classes/session.dart';

String getCurrentUrl() {
  try {
    if (kDebugMode) {
      return 'http://127.0.0.1:3003';
    }
    return Uri.base.origin.replaceAll('http//', '');
  } catch (_) {
    return 'http://127.0.0.1:3003';
  }
}

class Global {
  static String url = getCurrentUrl();
  static String? aesKey;
  static String? aesIv;
  static Session? session;
  static BuildContext? context;

  Global();
}
