import 'package:intl/intl.dart';
import 'package:video_calling_agora_demo_app/utils/registration_process/registration_process_db_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_calling_agora_demo_app/constants.dart';

class UserRegistrationStepOne extends StatefulWidget {
  final String userId;

  UserRegistrationStepOne(this.userId);

  @override
  State<StatefulWidget> createState() {
    return _UserRegistrationStepOneState(userId);
  }
}

class _UserRegistrationStepOneState extends State<UserRegistrationStepOne> {
  final String _userId;

  _UserRegistrationStepOneState(this._userId);

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  RegistrationProcessCRUDOps _registrationProcessCRUDOps;

  String _firstName;
  String _lastName;
  String _mobileNumber;

  TextEditingController _firstNameController;
  TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _getUserDoc();
    _registrationProcessCRUDOps = new RegistrationProcessCRUDOps();
    _firstNameController = new TextEditingController(text: _firstName);
    _lastNameController = new TextEditingController(text: _lastName);

    _getMobileNumber();
  }

  _getMobileNumber() async {
    await FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        _mobileNumber = value.phoneNumber;
      });
    });
  }

  void _getUserDoc() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    FirebaseUser user = await _auth.currentUser();
    /*setState(() {
      _userEmail = user.email;
    });

    debugPrint(_userEmail);*/
  }

  @override
  Widget build(BuildContext context) {
    //_getUserDoc();
    return Scaffold(
      backgroundColor: scaffoldBackgroundColorLight,
      key: _scaffoldState,
      body: _getStepOneUserNameInfoScreen(),
    );
  }

  _getStepOneUserNameInfoScreen() {
    return Stack(
      children: <Widget>[
        _getScreenHeader(),
        _getBottomNavigatorOptions(),
        _getNameForm(),
      ],
    );
  }

  _getScreenHeader() {
    return Container(
      margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0, bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'VidCall - Demo App',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          Text(
            'Tell us about you!',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  _getBottomNavigatorOptions() {
    return Container(
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.grey[300],
        height: 50.0,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.bottomLeft,
                /*child: FlatButton(
                  onPressed: () {
                    debugPrint('Previous clicked.');
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '< Previous',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),*/
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () async {
                    final FormState form = _formKey.currentState;
                    if (!form.validate()) {
                      showMessage('Please complete the form to proceed.');
                    } else {
                      debugPrint('Submit clicked.');
                      // verify OTP and then update Firestore
                      var _timestamp = new DateFormat("dd/MM/yyyy hh:mm:ss")
                          .format(DateTime.now());

                      var mapData = {
                        'registrationStatus': 'complete',
                        'displayName': _firstNameController.text + ' ' + _lastNameController.text,
                        'firstName': _firstNameController.text,
                        'lastName': _lastNameController.text,
                        'mobileNumber': _mobileNumber,
                        'memberSince': _timestamp.toString()
                      };
                      try {
                        await _registrationProcessCRUDOps.addUserRecord(
                            mapData, _userId);
                      } catch (e) {
                        debugPrint(e);
                      }

                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    }
                    /*debugPrint('Submit clicked.');
                    var mapData = {
                      'registrationStatus': 'complete',
                      'displayName': _firstNameController.text +
                          ' ' +
                          _lastNameController.text,
                      'firstName': _firstNameController.text,
                      'lastName': _lastNameController.text,
                      'myDeposits': '0',
                      'friendsDeposits': '0',
                      'creditUsed': '0',
                      'invitedBy': "",
                    };
                    try {
                      _registrationProcessCRUDOps.addUserRecord(
                          mapData, _userId);
                    } catch (e) {
                      debugPrint(e);
                    }

                    Navigator.popUntil(context, ModalRoute.withName("/"));*/
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getNameForm() {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        //shrinkWrap: true,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50.0,
          ),
          new ListTile(
            title: new Container(
              child: TextFormField(
                decoration: new InputDecoration(
                  labelText: 'First Name',
                ),
                style: TextStyle(
                  fontSize: 14.0,
                ),
                controller: _firstNameController,
                onSaved: (value) => _firstName = value,
                validator: (value) {
                  return value != '' ? null : 'Please enter your first name';
                },
              ),
            ),
          ),
          new ListTile(
            title: new Container(
              child: TextFormField(
                decoration: new InputDecoration(
                  labelText: 'Last Name',
                ),
                style: TextStyle(
                  fontSize: 14.0,
                ),
                controller: _lastNameController,
                onSaved: (value) => _lastName = value,
                validator: (value) {
                  return value != '' ? null : 'Please enter your last name';
                },
              ),
            ),
          ),
          Container(
            height: 50.0,
          ),
        ],
      ),
    );
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldState.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
