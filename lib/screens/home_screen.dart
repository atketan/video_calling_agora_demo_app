import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_agora_demo_app/screens/home_section/users_list_page_screen.dart';

//import 'package:video_calling_agora_demo_app/screens/home_page/instant_loan_screen.dart';
//import 'package:video_calling_agora_demo_app/screens/home_page/invest_and_earn_screen.dart';
//import 'package:video_calling_agora_demo_app/screens/home_page/notifications_screen.dart';
//import 'package:video_calling_agora_demo_app/screens/settings_section/settings_page_screen.dart';
import 'package:video_calling_agora_demo_app/services/authentication.dart';
import 'package:video_calling_agora_demo_app/src/pages/call.dart';
import 'package:video_calling_agora_demo_app/utils/profile_ops/call_ops_db_handler.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(
      {Key key,
      this.auth,
      this.userId,
      this.displayName,
      this.avatar,
      this.invitedBy,
      this.mobileNo})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final String displayName;
  final String avatar;
  final String invitedBy;
  final String mobileNo;

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState(
        auth, userId, displayName, avatar, invitedBy, mobileNo);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final BaseAuth _auth;
  final String _userId;
  final String _displayName;
  final String _avatar;
  final String _invitedBy;
  final String _mobileNo;

  _HomeScreenState(this._auth, this._userId, this._displayName, this._avatar,
      this._invitedBy, this._mobileNo);

  int _selectedIndex = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  List<Widget> _widgetOptions;

  /// FCM Related Declarations Begin
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  CallOpsCRUDOps _callOpsCRUDOps;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> _messageRecd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _callOpsCRUDOps = new CallOpsCRUDOps();

    const TextStyle optionStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );

    _widgetOptions = <Widget>[
      /*Text(
        'Index 0: Users Available',
        style: optionStyle,
      ),*/
      UsersListPageScreen(_userId, _displayName),
      /*InvestAndEarnScreen(_userId, _displayName, _invitedBy),
      InstantLoanScreen(_userId, _displayName, _invitedBy, _mobileNo),*/
      Text(
        'Index 1: Call Records',
        style: optionStyle,
      ),
      //CirclePageScreen(),
      /*Text(
        'Index 3: Notifications',
        style: optionStyle,
      ),*/
      /*NotificationsScreen(_userId, _displayName),
      SettingsPageScreen(_displayName, _userId),*/
    ];

    ///----- FCM configuration -----//
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        debugPrint(data.toString());
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint("onMessage: $message");
        FlutterRingtonePlayer.playRingtone();

        /*showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );*/

        /// TO do
        /*setState(() {
          _messageRecd = message;
        });
        _scaffoldKey.currentState.openDrawer();*/
        _getCallReceiverOverlay(message);

        // Record notification in local DB
        //_insertNotification(message);
        //_query();
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint("onLaunch: $message");
        FlutterRingtonePlayer.playRingtone();

        // TODO optional
        /*setState(() {
          _messageRecd = message;
        });
        _scaffoldKey.currentState.openDrawer();*/
        _getCallReceiverOverlay(message);
        // Record notification in local DB
        //_insertNotification(message);
        //_query();
      },
      onResume: (Map<String, dynamic> message) async {
        debugPrint("onResume: $message");
        FlutterRingtonePlayer.playRingtone();

        /// TO do
        /*setState(() {
          _messageRecd = message;
        });
        _scaffoldKey.currentState.openDrawer();*/
        _getCallReceiverOverlay(message);
        // Record notification in local DB
        // _insertNotification(message);
        // _query();
      },
    );

    _subscribeToTopic();
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
    //_getCallReceiverOverlay(message);
    showSimpleNotification(
      Container(
        margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
        child: Text(
          message['notification']['body'],
          style: TextStyle(color: Colors.black),
        ),
      ),
      background: Colors.grey[100],
      autoDismiss: false,
      subtitle: Builder(
        builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                //width: 50,
                child: FlatButton(
                  color: Colors.red,
                  textColor: Colors.white54,
                  onPressed: () {
                    OverlaySupportEntry.of(context).dismiss();
                    /*_callOpsCRUDOps.updateCallRecord(_userId,
                        message['data']['callId'], 'Declined', '00:00');*/
                    FlutterRingtonePlayer.stop();
                  },
                  child: Text('Dismiss'),
                ),
              ),
              Container(
                //width: 50,
                child: FlatButton(
                  color: Colors.green,
                  textColor: Colors.white54,
                  onPressed: () {
                    OverlaySupportEntry.of(context).dismiss();
                    /*_callOpsCRUDOps.updateCallRecord(_userId,
                        message['data']['callId'], 'Answered', '00:00');*/
                    FlutterRingtonePlayer.stop();
                    //onJoin(context, message['data']['channelName']);
                    // push video page with given channel name
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallPage(
                          //channelName: _channelController.text,
                          channelName: message['data']['channelName'],
                        ),
                      ),
                    );
                  },
                  child: Text('Answer'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _getCallReceiverOverlay(Map<String, dynamic> message) {
    //showOverlayNotification(builder)
    showSimpleNotification(
      Container(
        margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
        child: Text(
          message['notification']['body'],
          style: TextStyle(color: Colors.black),
        ),
      ),
      background: Colors.grey[100],
      autoDismiss: false,
      subtitle: Builder(
        builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                //width: 50,
                child: FlatButton(
                  color: Colors.red,
                  textColor: Colors.white54,
                  onPressed: () {
                    OverlaySupportEntry.of(context).dismiss();
                    _callOpsCRUDOps.updateCallRecord(_userId,
                        message['data']['callId'], 'Declined', '00:00');
                    FlutterRingtonePlayer.stop();
                  },
                  child: Text('Dismiss'),
                ),
              ),
              Container(
                //width: 50,
                child: FlatButton(
                  color: Colors.green,
                  textColor: Colors.white54,
                  onPressed: () {
                    OverlaySupportEntry.of(context).dismiss();
                    _callOpsCRUDOps.updateCallRecord(_userId,
                        message['data']['callId'], 'Answered', '00:00');
                    FlutterRingtonePlayer.stop();
                    onJoin(context, message['data']['channelName']);
                  },
                  child: Text('Answer'),
                ),
              ),
            ],
          );
        },
      ),
      /*trailing: Builder(builder: (context) {
        return Column(
          children: <Widget>[],
        );
      }),*/
    );
  }

  Future<void> onJoin(BuildContext context, String channelName) async {
    debugPrint('channelName: ' + channelName);

    /*try { //RECORD ALREADY INSERTED FROM CALLER side
      _callOpsCRUDOps.insertCallRecord(new CallRecordDetails(
          userId,
          displayName,
          userData.documentID,
          DateTime.now().millisecondsSinceEpoch,
          'Not Answered',
          "00:00",
          "Video"));
    } catch (Exception) {
      debugPrint('Error inserting call record.');
    }*/

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

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    // Get the current user
    //String uid = 'jeffd23';
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = _db
          .collection('users')
          .document(_userId)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  /// Subscribe the user to a topic
  _subscribeToTopic() async {
    // Subscribe the user to a topic
    _fcm.subscribeToTopic('vidcall-updates');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: scaffoldBackgroundColor,
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      drawer: Drawer(
        child: _NavigationTiles(_userId, _messageRecd),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        //backgroundColor: Colors.blueAccent,
        backgroundColor: Colors.transparent,
        //buttonBackgroundColor: Colors.transparent,
        //color: Colors.transparent,
        animationDuration: Duration(milliseconds: 250),
        height: 55.0,
        items: <Widget>[
          Icon(Icons.supervised_user_circle, size: 30),
          Icon(Icons.record_voice_over, size: 30),
          /*Icon(Icons.notifications, size: 30),
          Icon(Icons.account_circle, size: 30),*/
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}

class _NavigationTiles extends StatelessWidget {
  final CallOpsCRUDOps _callOpsCRUDOps = new CallOpsCRUDOps();
  final Map<String, dynamic> message;
  final String _userId;

  _NavigationTiles(this._userId, this.message);

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      style: ListTileStyle.drawer,
      child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Container(color: Theme.of(context).accentColor),
              padding: EdgeInsets.all(0),
            ),
            /*ListTile(
              title: Text("Main"),
              selected: true,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            Divider(height: 0, indent: 16),
            ListTile(
              title: Text("Star On GitHub"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PageWithIme()));
              },
            )*/
            Container(
              //width: 50,
              child: FlatButton(
                color: Colors.red,
                textColor: Colors.white54,
                onPressed: () {
                  //OverlaySupportEntry.of(context).dismiss();
                  _callOpsCRUDOps.updateCallRecord(
                      _userId, message['data']['callId'], 'Declined', '00:00');
                  FlutterRingtonePlayer.stop();
                },
                child: Text('Dismiss'),
              ),
            ),
            Container(
              //width: 50,
              child: FlatButton(
                color: Colors.green,
                textColor: Colors.white54,
                onPressed: () {
                  //OverlaySupportEntry.of(context).dismiss();
                  _callOpsCRUDOps.updateCallRecord(
                      _userId, message['data']['callId'], 'Answered', '00:00');
                  FlutterRingtonePlayer.stop();
                  onJoin(context, message['data']['channelName']);
                },
                child: Text('Answer'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onJoin(BuildContext context, String channelName) async {
    debugPrint('channelName: ' + channelName);

    /*try { //RECORD ALREADY INSERTED FROM CALLER side
      _callOpsCRUDOps.insertCallRecord(new CallRecordDetails(
          userId,
          displayName,
          userData.documentID,
          DateTime.now().millisecondsSinceEpoch,
          'Not Answered',
          "00:00",
          "Video"));
    } catch (Exception) {
      debugPrint('Error inserting call record.');
    }*/

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
