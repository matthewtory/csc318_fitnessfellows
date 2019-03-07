import 'package:csc318_fitnessfellows/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController;
  TextEditingController passwordController;

  String emailError;
  String passwordError;

  @override
  initState() {
    super.initState();

    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Material(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(64.0)),
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/icons/ic_pushups.png',
                        width: 82.0,
                        height: 82.0,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 48.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Fitness Fellows',
                        style: Theme.of(context).textTheme.headline),
                  ),
                  Container(
                    width: 200.0,
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: 'Email', errorText: emailError),
                      controller: emailController,
                      onChanged: (password) {
                        setState(() {
                          emailError = null;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 200.0,
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: 'Password', errorText: passwordError),
                      obscureText: true,
                      controller: passwordController,
                      onChanged: (password) {
                        setState(() {
                          passwordError = null;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlineButton(
                          onPressed: () async {
                            String email = emailController.text;
                            String password = passwordController.text;

                            try {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                            } catch (e) {
                              setState(() {
                                emailError = 'Invalid email or password';
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          child: Text('Login'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlineButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                  fullscreenDialog: true),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Text('Sign Up'),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
