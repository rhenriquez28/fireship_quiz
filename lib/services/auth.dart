import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<FirebaseUser> get getUser => _auth.currentUser();
  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  Future<FirebaseUser> anonLogin() async {
    AuthResult result = await _auth.signInAnonymously();
    FirebaseUser user = result.user;
    updateUserData(user);
    return user;
  }

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser user = result.user;
      updateUserData(user);
      return user;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<void> updateUserData(FirebaseUser user) {
    DocumentReference reportRef = _db.collection("reports").document(user.uid);
    return reportRef.setData({
      "uid": user.uid,
      "lastActivity": DateTime.now(),
    }, merge: true);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
