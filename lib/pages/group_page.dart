import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:csc318_fitnessfellows/pages/challenges_page.dart'
    as challenges_page;

import 'package:csc318_fitnessfellows/data/activities.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Your Group'),
        ),
        FutureBuilder<FirebaseUser>(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return buildProgressSliver();
            }

            FirebaseUser user = userSnapshot.data;

            return StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .snapshots(),
              builder: (context, userDocSnapshot) {
                if (!userDocSnapshot.hasData) {
                  return buildProgressSliver();
                }

                DocumentSnapshot userDocument = userDocSnapshot.data;

                if (userDocument['group'] == null) {
                  return SliverFillRemaining(
                      child: Center(
                    child: Text('You are not in a group.'),
                  ));
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream:
                      (userDocument['group'] as DocumentReference).snapshots(),
                  builder: (context, groupSnapshot) {
                    if (!groupSnapshot.hasData) {
                      return buildProgressSliver();
                    }

                    return buildGroupPage(userDocument, groupSnapshot.data);
                  },
                );
              },
            );
          },
        )
      ],
    );
  }

  Widget buildGroupPage(
      DocumentSnapshot userSnapshot, DocumentSnapshot groupDocument) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Group Challenge',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            StreamBuilder(
              stream: groupDocument['challenge'] != null
                  ? (groupDocument['challenge'] as DocumentReference)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (groupDocument['challenge'] == null) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No group challenge set'),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return challenges_page.buildChallengeTile(
                    context, snapshot.data);
              },
            ),
            Divider(
              color: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Group Members',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('users')
                  .where('group', isEqualTo: groupDocument.reference)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  children: snapshot.data.documents.map((userDocument) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        child: ListTile(
                          title: Text(
                            userDocument['first_name'] +
                                " " +
                                userDocument['last_name'],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            Divider(
              color: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Submissions',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: groupDocument['challenge'] != null
                  ? (groupDocument['challenge'] as DocumentReference)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (groupDocument['challenge'] == null) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No group challenge set'),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                DocumentSnapshot challengeDocument = snapshot.data;

                return StreamBuilder<QuerySnapshot>(
                  stream: snapshot.data.reference
                      .collection('submissions')
                      .where('group', isEqualTo: groupDocument.documentID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    List<DocumentSnapshot> submissions =
                        snapshot.data.documents.toList();
                    submissions
                        .sort((s1, s2) => s1['amount'] > s2['amount'] ? 1 : -1);
                    return Column(
                      children: submissions
                          .map(
                            (doc) =>
                                buildUserSubmissionTile(challengeDocument, doc),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserSubmissionTile(
      DocumentSnapshot challengeDocument, DocumentSnapshot userSubmissionDoc) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(userSubmissionDoc.documentID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        Activity activity = getActivity(challengeDocument['activity']);

        return ListTile(
          title: Text(snapshot.data['first_name']),
          trailing: Text(
            '${userSubmissionDoc['amount']} ${activity.units}',
            style: Theme.of(context).textTheme.subtitle,
          ),
        );
      },
    );
  }

  Widget buildProgressSliver() {
    return SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
