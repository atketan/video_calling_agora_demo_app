import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersCRUDOps {
  UsersCRUDOps();

  static CollectionReference reference = Firestore.instance.collection('users');

  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  getUsersStream(String userId) {
    return Firestore.instance.collection('users').snapshots();
  }
}
