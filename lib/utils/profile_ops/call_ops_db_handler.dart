import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_calling_agora_demo_app/models/call_record_details.dart';

class CallOpsCRUDOps {
  CallOpsCRUDOps();

  CollectionReference reference = Firestore.instance.collection('users');

  // Function to insert new call record in caller's and receiver's database
  insertCallRecord(CallRecordDetails callRecordDetails) {
    WriteBatch batch = Firestore.instance.batch();

    // 1.
    DocumentReference recCallRef = Firestore.instance
        .collection("users")
        .document(callRecordDetails.receiverId)
        .collection("call_records")
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    batch.setData(recCallRef, callRecordDetails.toMap());

    //2.
    /*DocumentReference senderCallRef = Firestore.instance
        .collection("users")
        .document(callRecordDetails.callerId)
        .collection("call_records")
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    batch.setData(senderCallRef, callRecordDetails.toMap());*/

    batch.commit().whenComplete(() {
      print("Call insert done");
    }).catchError((error) {
      print(error.toString());
    });
  }

  // Function to update call status and duration in caller's and receiver's database
  updateCallRecord(String receiverId, String callId, String callStatus,
      String callDuration) {
    WriteBatch batch = Firestore.instance.batch();

    // 1.
    DocumentReference recCallRef = Firestore.instance
        .collection("users")
        .document(receiverId)
        .collection("call_records")
        .document(callId);
    batch.updateData(
        recCallRef, {'callStatus': callStatus, 'callDuration': callDuration});

    //2.
    /*DocumentReference senderCallRef = Firestore.instance
        .collection("users")
        .document(callRecordDetails.callerId)
        .collection("call_records")
        .document(callId);
    batch.updateData(
        recCallRef, {'callStatus': callStatus, 'callDuration': callDuration});*/

    batch.commit().whenComplete(() {
      print("Call update done");
    }).catchError((error) {
      print(error.toString());
    });
  }
}
