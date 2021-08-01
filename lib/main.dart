import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:video_calling_agora_demo_app/screens/splash_screen.dart';
import 'package:video_calling_agora_demo_app/services/authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VidCall - Demo App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(auth: new Auth()),
      ),
    );
  }
}
