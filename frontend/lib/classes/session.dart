// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Session {
  final String userId;
  final String sessionHash;
  final String username;
  String signToken;
  Session({
    required this.userId,
    required this.sessionHash,
    required this.username,
    required this.signToken,
  });

  Session copyWith({
    String? userId,
    String? sessionHash,
    String? username,
    String? signToken,
  }) {
    return Session(
      userId: userId ?? this.userId,
      sessionHash: sessionHash ?? this.sessionHash,
      username: username ?? this.username,
      signToken: signToken ?? this.signToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'sessionHash': sessionHash,
      'username': username,
      'signToken': signToken,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      userId: map['userId'] as String,
      sessionHash: map['sessionHash'] as String,
      username: map['username'] as String,
      signToken: map['signToken'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Session.fromJson(String source) => Session.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Session(userId: $userId, sessionHash: $sessionHash, username: $username, signToken: $signToken)';
  }

  @override
  bool operator ==(covariant Session other) {
    if (identical(this, other)) return true;

    return other.userId == userId && other.sessionHash == sessionHash && other.username == username && other.signToken == signToken;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ sessionHash.hashCode ^ username.hashCode ^ signToken.hashCode;
  }
}
