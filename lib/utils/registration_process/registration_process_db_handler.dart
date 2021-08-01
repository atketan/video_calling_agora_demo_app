import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationProcessCRUDOps {
  RegistrationProcessCRUDOps();

  static CollectionReference reference = Firestore.instance.collection('users');

  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  // Get user record as a stream to ensure web based profile changes are
  // received in real time
  getUserDetailsStream(String userId) {
    //return await reference.document(userId).get();
    /*Stream<QuerySnapshot> userDetailsStream = Firestore.instance
        .collection('users')
        .document(userId)
        .collection('user_details')
        .snapshots();
    return userDetailsStream;*/
    return Firestore.instance.collection('users').document(userId);
  }

  // Add user record
  addUserRecord(Map<String, dynamic> mapData, String userId) async {
    WriteBatch batch = Firestore.instance.batch();
    if (isLoggedIn()) {
      //1.
      DocumentReference userRef = reference.document(userId);
      batch.setData(userRef, mapData, merge: false);
      /*Firestore.instance.runTransaction(
        (Transaction transaction) async {
          await reference.document(userId).setData(mapData, merge: false);
        },
      );*/

      batch.commit().whenComplete(() {
        print("done");
      }).catchError((error) {
        print(error.toString());
      });
    }
  }

  // Update user record
  updateUserRecord(Map<String, dynamic> mapData, String userId) async {
    if (isLoggedIn()) {
      Firestore.instance.runTransaction(
        (Transaction transaction) async {
          await reference.document(userId).updateData(mapData);
        },
      );
    }
  }

  // Get user with matching mobile number
  getUserWithMobileNumber(String mobileNo) {
    return Firestore.instance
        .collection('users')
        .where('mobileNumber', isEqualTo: '+91' + mobileNo)
        .snapshots()
        .first;
  }
}
