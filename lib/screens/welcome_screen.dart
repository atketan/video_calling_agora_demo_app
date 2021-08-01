import 'package:video_calling_agora_demo_app/constants.dart';
import 'package:video_calling_agora_demo_app/screens/home_screen.dart';
import 'package:video_calling_agora_demo_app/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_calling_agora_demo_app/screens/registration_process/registration_step_one.dart';
import 'package:video_calling_agora_demo_app/utils/registration_process/registration_process_db_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({this.auth, this.userId});

  final BaseAuth auth;
  final String userId;

  @override
  State<StatefulWidget> createState() {
    return _WelcomeScreenState(auth, userId);
  }
}

class _WelcomeScreenState extends State<StatefulWidget> {
  final BaseAuth _auth;
  final String _userId;

  _WelcomeScreenState(this._auth, this._userId);

  String _registrationStatus;
  String _displayName;
  String _avatar;
  String _invitedBy;
  String _mobileNo;

  RegistrationProcessCRUDOps _registrationProcessCRUDOps;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _registrationProcessCRUDOps = RegistrationProcessCRUDOps();
    _checkConnectivity();
    _registrationStatus = "";
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      backgroundColor: scaffoldBackgroundColorLight,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        key: _refreshIndicatorKey,
        child: Container(
          //color: Colors.blue,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              FadeInImage(
                placeholder: AssetImage("assets/nb-5.jpg"),
                image: AssetImage("assets/nb-5.jpg"),
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                //if you use a larger image, you can set where in the image you like most
                //width alignment.centerRight, bottomCenter, topRight, etc...
                alignment: Alignment.center,
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage('assets/ic_launcher.png'),
                    ),
                    Text(
                      'VidCall',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        //fontStyle: FontStyle.italic,
                        color: Colors.black,
                        backgroundColor: Colors.white70,
                      ),
                    ),
                    Text(
                      'Video Calling Demo App',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        //fontStyle: FontStyle.italic,
                        color: Colors.black,
                        backgroundColor: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onRefresh: _refresh,
      ),
    );
  }

  Future<dynamic> _refresh() {
    /*showMessage('Registration Pending');
    _getHomeScreen();
    return null;*/
    return _registrationProcessCRUDOps
        .getUserDetailsStream(_userId)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds != null && ds.exists) {
        //print(ds.data['registrationStatus']);
        try {
          setState(() {
            if (ds.data['registrationStatus'] == "complete") {
              _registrationStatus = ds.data['registrationStatus'];
              _displayName = ds.data['displayName'];
              _avatar = ds.data['avatar'];
              _invitedBy = ds.data['invitedBy'];
              _mobileNo = ds.data['mobileNo'];
              _setSharedPreferences(_userId, _displayName, _avatar, _invitedBy);
              _getHomeScreen();
            }
            if (_registrationStatus == "") {
              _getUserRegistrationScreen(_userId);
              //_getHomeScreen(_registrationStatus);
            }
          });
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        //debugPrint('ds does not exist.');
        _getUserRegistrationScreen(_userId);
        //_getHomeScreen(_registrationStatus);
      }
    });
  }

  _getUserRegistrationScreen(userId) async {
    debugPrint('inside user reg screen function');
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserRegistrationStepOne(userId),
      fullscreenDialog: true,
    ));
    Navigator.pop(context);
    //_refresh();
    //debugPrint("from get function: " + _registrationStatus);
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showMessage('No internet present or slow connection. Kindly try again.');
      return false;
    } else {
      return true;
    }
  }

  void _getHomeScreen() {
    //Navigator.of(context).pop();
    //debugPrint('Calling Investor Home');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "HomeScreen"),
        builder: (context) => HomeScreen(
          auth: _auth,
          userId: _userId,
          displayName: _displayName,
          avatar: _avatar,
          invitedBy: _invitedBy,
          mobileNo: _mobileNo,
        ),
      ),
    );
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldState.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void _setSharedPreferences(String userId, String displayName, String avatar,
      String invitedBy) async {
    final prefs = await SharedPreferences.getInstance();
    /*final key = 'my_int_key';
    final value = 42;
    prefs.setInt(key, value);*/
    prefs.setString("userId", userId);
    prefs.setString("displayName", displayName);
    prefs.setString("avatar", avatar);
    prefs.setString("invitedBy", invitedBy);
  }
}
