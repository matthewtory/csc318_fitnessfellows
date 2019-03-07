import 'package:csc318_fitnessfellows/pages/main_page.dart';
import 'package:csc318_fitnessfellows/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Fellows',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: EntryPage(),
    );
  }
}

class EntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return new LoginPage();
        } else {
          return new MainPage();
        }
      },
    );
  }
}
