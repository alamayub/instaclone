import 'dart:core';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:insta_clone/state/auth/constants/contants.dart';

import '../../posts/typedefs/user_id.dart';
import '../models/auth_result.dart';

class Authenticator {
  const Authenticator();
  FirebaseAuth get _auth => FirebaseAuth.instance;
  User? get user => _auth.currentUser;
  UserId? get userId => user?.uid;
  bool get isAlreadyLoggedIn => userId != null;
  String get displayName => user?.displayName ?? '';
  String? get email => user?.email;

  // logout from current device from auth providers
  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  // login with facebook
  Future<AuthResult> loginWithFacebook() async {
    final loginResult = await FacebookAuth.instance.login();
    final token = loginResult.accessToken?.token;
    if (token == null) {
      // user has aborted login
      return AuthResult.aborted;
    }

    final oAuthCredentials = FacebookAuthProvider.credential(token);
    try {
      await _auth.signInWithCredential(oAuthCredentials);
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      log('facbook sign in error 41 ${e.toString()}');
      final email = e.email;
      final credential = e.credential;
      if (e.code == Constants.accountExistsWithDifferentCredentials &&
          email != null &&
          credential != null) {
        final providers = await _auth.fetchSignInMethodsForEmail(
          email,
        );
        if (providers.contains(Constants.googleCom)) {
          await loginWithGoogle();
          await user?.linkWithCredential(credential);
        }
        return AuthResult.success;
      }
      return AuthResult.failure;
    }
  }

  // login with google
  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [Constants.googleCom],
    );
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount == null) {
      return AuthResult.aborted;
    }
    final googleAuth = await signInAccount.authentication;
    final authCredential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    try {
      await _auth.signInWithCredential(authCredential);
      return AuthResult.success;
    } catch (e) {
      log('google sign in error 79 ${e.toString()}');
      return AuthResult.failure;
    }
  }
}
