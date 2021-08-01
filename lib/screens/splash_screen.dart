import 'dart:async';
import 'package:video_calling_agora_demo_app/screens/mobile_login_signup_screen.dart';
import 'package:video_calling_agora_demo_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_calling_agora_demo_app/services/authentication.dart';
import 'package:video_calling_agora_demo_app/constants.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() {
    return new _SplashScreenState();
  }
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _SplashScreenState extends State<SplashScreen> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget _buildWaitingScreen() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    _getOtherScreen();
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[
            CircularProgressIndicator(),
            _getOtherScreen(),
          ],
        ),
      ),
    );
  }

  _getOtherScreen() {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        /*return new LoginPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );*/
        return new MobileLoginSignupScreen(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          //debugPrint('Logged In');
          //debugPrint('Calling Welcome Screen');
          return new WelcomeScreen(
            auth: widget.auth,
            userId: _userId,
          );
        } else
          return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
