import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_agora_demo_app/models/call_record_details.dart';
import 'package:video_calling_agora_demo_app/src/pages/call.dart';
import 'package:video_calling_agora_demo_app/utils/profile_ops/call_ops_db_handler.dart';

class UsersListItem extends StatelessWidget {
  final DocumentSnapshot userData;
  final String userId;
  final String displayName;

  UsersListItem(this.userData, this.userId, this.displayName);

  /// create a channelController to retrieve text value
  //final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  //bool _validateError = false;

  /// KB declared
  final CallOpsCRUDOps _callOpsCRUDOps = new CallOpsCRUDOps();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 7,
              child: Container(
                margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    userData.data['displayName'] ?? '',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                    child: Text(
                      'Member Since: \n' + userData.data['memberSince'] ?? '',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerRight,
                //width: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.video_call,
                        size: 30.0,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        debugPrint('Video call pressed');
                        onJoin(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.call,
                        size: 25.0,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        debugPrint('Audio call pressed');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onJoin(BuildContext context) async {
    var channelName =
        DateTime.now().millisecondsSinceEpoch.toString() + '-' + userId;
    debugPrint('channelName: ' + channelName);

    try {
      _callOpsCRUDOps.insertCallRecord(new CallRecordDetails(
          userId,
          displayName,
          userData.documentID,
          DateTime.now().millisecondsSinceEpoch,
          'Not Answered',
          "00:00",
          channelName,
          "Video"));
    } catch (Exception) {
      debugPrint('Error inserting call record.');
    }

    // update input validation
    /*setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });*/

    //if (_channelController.text.isNotEmpty) {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic();
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          //channelName: _channelController.text,
          channelName: channelName,
        ),
      ),
    );
    //}
  }

  Future<void> _handleCameraAndMic() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    print(statuses[Permission.camera].toString() +
        ' AND ' +
        statuses[Permission.microphone].toString());
    /*await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );*/
  }
}
