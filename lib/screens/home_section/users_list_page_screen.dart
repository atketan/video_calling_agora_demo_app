import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:video_calling_agora_demo_app/constants.dart';
import 'package:video_calling_agora_demo_app/screens/home_section/users_list_item.dart';
import 'package:video_calling_agora_demo_app/screens/splash_screen.dart';
import 'package:video_calling_agora_demo_app/services/authentication.dart';
import 'package:video_calling_agora_demo_app/utils/profile_ops/users_db_handler.dart';

class UsersListPageScreen extends StatefulWidget {
  final String userId;
  final String displayName;

  UsersListPageScreen(this.userId, this.displayName);

  @override
  State<StatefulWidget> createState() {
    return _UsersListPageScreenState(userId, displayName);
  }
}

class _UsersListPageScreenState extends State<UsersListPageScreen> {
  final String _userId;
  final String _displayName;

  _UsersListPageScreenState(this._userId, this._displayName);

  UsersCRUDOps dbHandler;

  @override
  void initState() {
    super.initState();
    dbHandler = new UsersCRUDOps();
    _checkConnectivity();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      //body: _getUsersPageListView(),
      body: _getUsersSection(),
      appBar: new AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: Text(
          "Users",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            //fontSize: 30.0,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: _logout,
          )
        ],
      ),
    );
  }

  _getUsersPageListView() {
    return ListView(
      children: <Widget>[_getPageHeader(), _getUsersSection()],
    );
  }

  _getPageHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 25.0),
      child: Text(
        "Available Users",
        style: TextStyle(
          fontWeight: FontWeight.w800,
          //fontSize: 30.0,
          color: Colors.white,
        ),
      ),
    );
  }

  _getUsersSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _buildUsersListBody(context),
        ],
      ),
    );
  }

  _buildUsersListBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: dbHandler.getUsersStream(_userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );
        if (snapshot.data.documents.length > 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 5.0,
                  left: 15.0,
                  bottom: 5.0,
                ),
                child: Text(
                  "${snapshot.data.documents.length.toString()} users",
                ),
              ),
              _buildUsersDetailsList(context, snapshot.data.documents),
            ],
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              top: 5.0,
              bottom: 5.0,
            ),
            child: Center(
              child: Text(
                'No active users found.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildUsersDetailsList(
      BuildContext context, List<DocumentSnapshot> documents) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children:
          documents.map<Widget>((data) => _buildUsersListItem(data)).toList(),
    );
  }

  _buildUsersListItem(DocumentSnapshot userData) {
    if (userData.documentID == _userId) {
      return Container();
    } else {
      return UsersListItem(userData, _userId, _displayName);
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }

    //Navigator.popUntil(context, ModalRoute.withName("/"));

    Navigator.pop(context, true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SplashScreen(
          auth: new Auth(),
        ),
      ),
    );
  }
}
