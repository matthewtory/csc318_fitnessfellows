import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  String firstNameError = null;
  String lastNameError = null;
  String emailError = null;
  String passwordError = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(color: Colors.black54),
        ),
        iconTheme: IconThemeData(color: Colors.black54),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 200.0,
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "First Name", errorText: firstNameError),
                  controller: firstNameController,
                  onChanged: (string) {
                    setState(() {
                      firstNameError = null;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 200.0,
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "Last Name", errorText: lastNameError),
                  controller: lastNameController,
                  onChanged: (string) {
                    setState(() {
                      lastNameError = null;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 200.0,
                child: TextField(
                  decoration:
                      InputDecoration(labelText: "email", errorText: emailError),
                  controller: emailController,
                  onChanged: (string) {
                    setState(() {
                      emailError = null;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 200.0,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password", errorText: passwordError),
                  controller: passwordController,
                  onChanged: (string) {
                    setState(() {
                      passwordError = null;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlineButton(
                onPressed: onSignUpPressed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                child: Text('Sign Up'),
              ),
            ),
          ],
        )),
      ),
    );
  }

  void onSignUpPressed() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    bool error = false;
    if (firstName.length < 3) {
      setState(() {
        firstNameError = "First name not long enough";
      });
      error = true;
    }

    if (lastName.length < 3) {
      setState(() {
        lastNameError = "Last name not long enough";
      });
      error = true;
    }

    if (email.length < 3) {
      setState(() {
        emailError = "email not long enough";
      });
      error = true;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        emailError = "email not valid";
      });
      error = true;
    }

    if (password.length < 3) {
      setState(() {
        passwordError = "Password not long enough";
      });
      error = true;
    }

    if (error) {
      return;
    }

    try {
      FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      DocumentReference doc = await Firestore.instance.collection('users').document(user.uid);

      Firestore.instance.runTransaction((transaction) {
        doc.setData({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        }, merge: true);
      });

      DocumentSnapshot snapshot = await Firestore.instance.document('users/${user.uid}').get();
      print(snapshot.data);
      Navigator.of(context).pop();

    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Okay'),
            )
          ],
        ),
      );
    }

  }

  @override
  void dispose() {
    super.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
