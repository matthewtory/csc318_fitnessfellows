import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc318_fitnessfellows/pages/challenge_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChallengesPage extends StatefulWidget {
  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Challenges'),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('challenges').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.data.documents.length == 0) {
              return SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No challenges found'),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return buildChallengeTile(
                      context, snapshot.data.documents[index]);
                },
                childCount: snapshot.data.documents.length,
              ),
            );
          },
        ),
      ],
    );
  }
}

Widget buildChallengeTile(
    BuildContext context, DocumentSnapshot challengeDocument) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Card(
      elevation: 4.0,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder<Uint8List>(
            future: FirebaseStorage.instance
                .ref()
                .child(challengeDocument['image'])
                .getData(1000000),
            builder: (context, snapshot) {
              Widget widget = null;
              if (snapshot.hasData) {
                widget = Image.memory(
                  snapshot.data,
                  fit: BoxFit.fitHeight,
                );
              }

              return Padding(
                padding: EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    color: Colors.black26,
                    child: widget,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    challengeDocument['name'],
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.title,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 8.0,
                  ),
                  Text(
                    challengeDocument['description'],
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ChallengePage(challenge: challengeDocument),
                          ),
                        );
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: Text('Details'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
