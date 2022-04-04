import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui';

import 'home_page.dart';
import 'registration_page.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'SplashScreen';
  final SharedPreferences prefs;

  SplashScreen({this.prefs});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  _decideMainPage() {
    if (widget.prefs.getBool('is_verified') != null) {
      if (widget.prefs.getBool('is_verified')) {
        return HomePage(prefs: widget.prefs);
        // return RegistrationPage(prefs: prefs);
      } else {
        return RegistrationPage(prefs: widget.prefs);
      }
    } else {
      return RegistrationPage(prefs: widget.prefs);
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => _decideMainPage())));
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Center(
            child: Text(
          'ESP_CHAT',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white),
        )),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Text(
          'Designed by \nMaster2GLSI',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white),
        ),
      ),
    );
  }
}
