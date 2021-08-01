import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

//import 'package:video_calling_agora_demo_app/screens/settings_section/contact_us_screen.dart';
import 'package:video_calling_agora_demo_app/screens/splash_screen.dart';
import 'package:video_calling_agora_demo_app/services/authentication.dart';

class MobileLoginSignupScreen extends StatefulWidget {
  MobileLoginSignupScreen({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() {
    return _MobileLoginSignupScreen();
  }
}

class _MobileLoginSignupScreen extends State<MobileLoginSignupScreen> {
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  bool isLoading = false;

  Future<void> verifyPhone() async {
    setState(() {
      isLoading = true;
    });

    //debugPrint('+91' + this.phoneNo);

    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        debugPrint('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: '+91' + this.phoneNo,
          // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent: smsOTPSent,
          // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                        'Error', // errorMessage
                        style: TextStyle(color: Colors.red),
                      )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                      //Navigator.of(context).pushReplacementNamed('/homepage');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplashScreen(
                            auth: new Auth(),
                          ),
                        ),
                      );
                    } else {
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      //final FirebaseUser user = await _auth.signInWithCredential(credential);
      await _auth.signInWithCredential(credential).then((value) {
        user = value.user;
      });
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pop();
      //Navigator.of(context).pushReplacementNamed('/homepage');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreen(
            auth: new Auth(),
          ),
        ),
      );
    } catch (e) {
      if (e.runtimeType == PlatformException) {
        handleError(e);
      } else {
        debugPrint('e: ' + e.toString());
      }
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        title: Text(),
      ),*/
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            FadeInImage(
              placeholder: AssetImage("assets/m-3.jpg"),
              image: AssetImage("assets/m-3.jpg"),
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              //if you use a larger image, you can set where in the image you like most
              //width alignment.centerRight, bottomCenter, topRight, etc...
              alignment: Alignment.center,
            ),
            _getScreen(),
          ],
        ),
      ),
    );
  }

  _getScreen() {
    return Center(
      child: ListView(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            //color: scaffoldBackgroundColor,
            height: 250.0,
            alignment: Alignment.center,
            //padding: EdgeInsets.all(15.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 100.0,
              child: Image.asset('assets/ic_launcher.png'),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            child: Card(
              elevation: 3.0,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                    child: Text(
                      'Welcome to VidCall!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        //color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  (isLoading)
                      ? CircularProgressIndicator()
                      : Container(
                          margin: EdgeInsets.all(20),
                          color: Colors.white,
                          child: ListTile(
                            title: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  hintText: 'Eg. 1234567890',
                                  prefixText: '+91 '),
                              onChanged: (value) {
                                this.phoneNo = value;
                                //debugPrint(this.phoneNo);
                              },
                            ),
                          ),
                        ),
                  (errorMessage != ''
                      ? Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container()),
                  SizedBox(
                    width: 120.0,
                    height: 35.0,
                    child: RaisedButton(
                      onPressed: () {
                        verifyPhone();
                      },
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      textColor: Colors.white,
                      elevation: 10,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showSimpleNotification(
        Text("No internet connection."),
        background: Colors.red,
        autoDismiss: false,
        trailing: Builder(builder: (context) {
          return FlatButton(
              textColor: Colors.white54,
              onPressed: () {
                OverlaySupportEntry.of(context).dismiss();
              },
              child: Text('Dismiss'));
        }),
      );
      return false;
    } else {
      return true;
    }
  }
}
