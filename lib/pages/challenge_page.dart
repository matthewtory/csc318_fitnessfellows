import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:csc318_fitnessfellows/data/activities.dart';

class ChallengePage extends StatelessWidget {
  ChallengePage({this.challenge});

  final DocumentSnapshot challenge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FutureBuilder<Uint8List>(
              future: FirebaseStorage.instance
                  .ref()
                  .child(challenge['image'])
                  .getData(1000000),
              builder: (context, snapshot) {
                Widget widget = null;
                if (snapshot.hasData) {
                  widget = Image.memory(
                    snapshot.data,
                    fit: BoxFit.cover,
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  child: Container(
                    color: Colors.black26,
                    child: widget,
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Text(challenge['name'],
                      style: Theme.of(context)
                          .textTheme
                          .title
                          .copyWith(fontSize: 32.0)),
                  Divider(
                    height: 16.0,
                  ),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 4.0,
                  ),
                  Text(
                    challenge['description'],
                    style: Theme.of(context).textTheme.body1,
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    'Units',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 4.0,
                  ),
                  Text(
                    getActivity(challenge['activity']).units,
                    style: Theme.of(context).textTheme.body1,
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Center(
                    child: FutureBuilder<FirebaseUser>(
                      future: FirebaseAuth.instance.currentUser(),
                      builder: (context, userSnapshot) {
                        if(!userSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        
                        return StreamBuilder<DocumentSnapshot>(
                          stream: Firestore.instance.document('users/'+userSnapshot.data.uid).snapshots(),
                          builder: (context, userDocumentSnapshot) {
                            if(!userDocumentSnapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            print(userSnapshot.data.uid);

                            List<dynamic> userChallenges = List.from(userDocumentSnapshot.data['challenges'] ?? []) ?? [];
                            
                            if(!userChallenges.contains(challenge.documentID)) {
                              return RaisedButton.icon(
                                onPressed: () {
                                  userChallenges.add(challenge.documentID);
                                  userDocumentSnapshot.data.reference.updateData({
                                    'challenges': userChallenges,
                                  });
                                },
                                icon: Icon(Icons.add),
                                color: Colors.orange,
                                colorBrightness: Brightness.dark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                label: Text('Personal Challenge'),
                              );
                            } else {
                              return RaisedButton.icon(
                                onPressed: () {
                                  userChallenges.remove(challenge.documentID);
                                  userDocumentSnapshot.data.reference.updateData({
                                    'challenges': userChallenges,
                                  });
                                },
                                icon: Icon(Icons.close),
                                color: Colors.red,
                                colorBrightness: Brightness.dark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                label: Text('Personal Challenge'),
                              );
                            }
                          }
                        );
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Center(
                    child: FutureBuilder<FirebaseUser>(
                      future: FirebaseAuth.instance.currentUser(),
                      builder: (context, userSnapshot) {
                        if(!userSnapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        return FutureBuilder<DocumentSnapshot>(
                          future: Firestore.instance.document('users/'+userSnapshot.data.uid).get(),
                          builder: (context, userDocumentSnapshot) {
                            if(!userDocumentSnapshot.hasData) {
                              return CircularProgressIndicator();
                            }

                            if(userDocumentSnapshot.data['group'] == null) {
                              return Container();
                            }

                            print(userDocumentSnapshot.data.data);

                            DocumentReference groupRef = (userDocumentSnapshot.data['group'] as DocumentReference);
                            print(groupRef.path);
                            return StreamBuilder<DocumentSnapshot>(
                              stream: groupRef.snapshots(),
                              builder: (context, groupSnapshot) {
                                if(!groupSnapshot.hasData) {
                                  return CircularProgressIndicator();
                                } else if(groupSnapshot.data == null) {
                                  return Container();
                                }

                                DocumentSnapshot group = groupSnapshot.data;

                                if(group['challenge'] == null || group['challenge'].documentID != challenge.documentID) {
                                  return RaisedButton.icon(
                                    onPressed: () {
                                      print(group.data);
                                      group.reference.updateData({
                                        'challenge': challenge.reference,
                                      });
                                    },
                                    icon: Icon(Icons.add),
                                    color: Colors.lightGreen,
                                    colorBrightness: Brightness.dark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    label: Text('Set as group challenge'),
                                  );
                                } else {
                                  return RaisedButton.icon(
                                    onPressed: () {
                                      group.reference.updateData({
                                        'challenge': null,
                                      });
                                    },
                                    icon: Icon(Icons.close),
                                    color: Colors.red,
                                    colorBrightness: Brightness.dark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    label: Text('Unset as group challenge'),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
