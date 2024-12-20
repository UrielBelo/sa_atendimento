import 'dart:async';

class SingleButtonClick {
  static Map<String, bool> isClickedMap = {};

  bool verify(String buttonId, {int timeout = 5}) {
    if (isClickedMap.containsKey(buttonId)) return true;

    isClickedMap.addAll({buttonId: false});
    Timer(
      Duration(seconds: timeout),
      () => isClickedMap.remove(buttonId),
    );
    return false;
  }
}
