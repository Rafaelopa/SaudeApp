import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
  });

  factory User.fromFirebase(fb_auth.User? fbUser) {
    if (fbUser == null) {
      throw ArgumentError("Firebase user cannot be null for User.fromFirebase");
    }
    return User(
      uid: fbUser.uid,
      email: fbUser.email,
      displayName: fbUser.displayName,
      photoURL: fbUser.photoURL,
      emailVerified: fbUser.emailVerified,
    );
  }
}

