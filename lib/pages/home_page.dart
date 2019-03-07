import 'package:csc318_fitnessfellows/pages/record_activity_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Home'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.exit_to_app), onPressed: () async {
              FirebaseAuth.instance.signOut();
            }),
          ],

        ),
        SliverList(
          delegate: SliverChildListDelegate(
            <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => RecordActivityPage(),
                          fullscreenDialog: true),
                    );
                  },
                  color: Colors.orange,
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        size: 100.0,
                        color: Colors.white,
                      ),
                      Text(
                        'Record Activity',
                        style: Theme.of(context)
                            .textTheme
                            .title
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
