import 'package:flash_chat/componenets/RoundedButton.dart';
import 'package:flash_chat/componenets/User.dart' as prefix0;
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/componenets/User.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/screens/cadre_screen.dart';
import 'package:firebase_database/firebase_database.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'RegistrationScreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  String name;
  bool showSpinner = false;
  user kind;
  final _firestore = Firestore.instance;
  void _setUser(user type) {
    setState(() {
      kind = type;
    });
  }

  void _registUser() async {
    setState(() {
      showSpinner = true;
    });
    try {
      final newUser = await authService.auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _firestore
          .collection('userinfo')
          .document(email)
          .setData({'id': email, 'type': kind.index, 'name': name});

      _firestore.collection('group').document(email).setData({
        'member': [name],
        'leader': email,
      });

      _firestore.collection('location').document(email).setData({
        'lat': 37.532600,
        'lng': 127.024612,
      });

      print('regist user');
      if (newUser != null) {
        Navigator.pushNamed(context, UserScreen.id);
      }
      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration,
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  name = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your name'),
              ),
              SizedBox(
                height: 24.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio(
                    activeColor: Colors.lightBlue,
                    value: user.soldier,
                    groupValue: kind,
                    onChanged: _setUser,
                  ),
                  Text('용사'),
                  Radio(
                    activeColor: Colors.lightBlue,
                    value: user.cadre,
                    groupValue: kind,
                    onChanged: _setUser,
                  ),
                  Text('간부'),
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                text: 'Register',
                txtColor: Colors.white,
                color: Colors.blueAccent,
                onPressed: () {
                  //_database.child("1").set({'id': email, 'type': kind.index});
                  _registUser();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
