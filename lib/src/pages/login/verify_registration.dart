import 'dart:async';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone_flutter_udemy/src/pages/home/home_page.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key key}) : super(key: key);
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final auth = FirebaseAuth.instance;
  User user;
  Timer timer;

  @override
  void initState() {
    user = auth.currentUser;
    user.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 40,),
        body: Center(
         child: Column(
          children: [
            _bannerApp(),
            _textDescription(),

          ],

      ),
        ),
      ),
    );
  }
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Salir'),
        content: new Text('¿ Esta seguro que quiere salir ?'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text("SI"),
          ),
        ],
      ),
    ) ??
        false;
  }

  Widget _textDescription(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text (
          'Se ha enviado un email a ${user.email} porfavor verifique',
        style: TextStyle(
          color: Colors.black,
          fontSize:  24,
          fontFamily: 'NimbusSans',
        ),

      ),
    );

  }
  Widget _bannerApp(){
    return ClipPath(
      clipper: WaveClipperTwo(),
      child:Container(
        color: utils.Colors.uberCloneColor,
        height: MediaQuery.of(context).size.height * 0.22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/img/Logo J&E para fondos oscuros.png',
              width: 150,
              height: 100,

            ),

            Text (
              'Drivers',
              style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w100
              ),
            )

          ],

        ),
      ),

    );
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    }
  }
}