import 'package:flutter/material.dart';
import 'package:frontend/util/secure_request.dart';
import 'package:frontend/util/sha1.dart';

class UserImage {
  final String username;

  const UserImage(this.username);

  String get imageUrl {
    String usernameSha1 = sha1(username);
    return '/home/userImage/$usernameSha1';
  }

  Future<void> image(BuildContext context) async {
    SecureRequest sr = SecureRequest(context: context);
    Map<String, dynamic>? image = await sr.post(imageUrl, null, true);
    print(image);
  }
}
