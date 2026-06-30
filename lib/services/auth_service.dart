import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('email');
    googleProvider.addScope('profile');

    final UserCredential userCredential;

    if (kIsWeb) {
      userCredential = await _auth.signInWithPopup(googleProvider);
    } else {
      userCredential = await _auth.signInWithProvider(googleProvider);
    }

    final user = userCredential.user;

    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'phone': user.phoneNumber ?? '',
        'authProvider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}