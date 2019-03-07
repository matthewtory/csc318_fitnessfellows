import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc318_fitnessfellows/pages/activity_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:csc318_fitnessfellows/data/activities.dart';

class PersonalPage extends StatefulWidget {
  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Personal'),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16.0),
          sliver: FutureBuilder(
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
                  builder: (context, userDocumentSnapshot) {
                    if (!userDocumentSnapshot.hasData) {
                      return buildProgressSliver();
                    }

                    return buildPersonalPage(userDocumentSnapshot.data);
                  });
            },
          ),
        )
      ],
    );
  }

  Widget buildProgressSliver() {
    return SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildPersonalPage(DocumentSnapshot userDocument) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('activity')
            .where('uid', isEqualTo: userDocument.documentID)
            .snapshots(),
        builder: (context, userActivitySnapshot) {
          if (!userActivitySnapshot.hasData) {
            return SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          QuerySnapshot activity = userActivitySnapshot.data;

          return SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Text('Personal Challenges',
                    style: Theme.of(context).textTheme.title),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: (userDocument['challenges'] ?? []).map<Widget>(
                    (challengeId) {
                      return FutureBuilder(
                        future: Firestore.instance
                            .collection('challenges')
                            .document(challengeId)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }

                          return buildChallengeCard(
                              userDocument, snapshot.data, activity);
                        },
                      );
                    },
                  ).toList(),
                ),
                Divider(
                  color: Colors.transparent,
                ),
                Text('Your Activities',
                    style: Theme.of(context).textTheme.title),
                buildActivities(activity)
              ],
            ),
          );
        });
  }

  Widget buildActivities(QuerySnapshot userActivity) {
    List<Activity> userActivities = userActivity.documents
        .map((doc) {
          return getActivity(doc['activity']);
        })
        .toSet()
        .toList();

    List<Widget> rows = [];
    for (int i = 0; i < userActivities.length; i += 2) {
      List<Widget> rowChildren = [];
      rowChildren.add(buildActivityButton(
          context, userActivities[i], userActivity.documents));
      if (i + 1 < userActivities.length) {
        rowChildren.add(buildActivityButton(
            context, userActivities[i + 1], userActivity.documents));
      } else {
        rowChildren.add(Expanded(child: Container()));
      }
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: rowChildren,
        ),
      );
    }

    return Column(
      children: rows,
    );
  }

  Widget buildActivityButton(BuildContext context, Activity activity,
      List<DocumentSnapshot> userActivity) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: RaisedButton.icon(
          color: Colors.white,
          colorBrightness: Brightness.light,
          textColor: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ActivityPage(
                      activity: activity,
                      userActivity: userActivity.where((doc) {
                        return doc['activity'] == activity.id;
                      }).toList(),
                    ),
              ),
            );
          },
          icon: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/icons/${activity.icon}.png',
              width: 32.0,
              height: 32.0,
            ),
          ),
          label: Expanded(child: Text(activity.name, overflow: TextOverflow.fade, maxLines: 1, softWrap: false,)),
        ),
      ),
    );
  }

  Widget buildChallengeCard(DocumentSnapshot userDocument,
      DocumentSnapshot challengeDocument, QuerySnapshot activity) {
    List<DocumentSnapshot> thisActivity = activity.documents
        .where((activityDoc) =>
            activityDoc['activity'] == challengeDocument['activity'])
        .toList();

    int maxProgress = thisActivity.fold(0, (previous, activityDoc) {
      return activityDoc['amount'] > previous
          ? activityDoc['amount']
          : previous;
    });

    Activity activityType = getActivity(challengeDocument['activity']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      challengeDocument['name'],
                      style: Theme.of(context).textTheme.subtitle,
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ActivityPage(
                                  activity: activityType,
                                  userActivity: thisActivity,
                                ),
                              ),
                            );
                          },
                          child: Text('Progress'),
                          textColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
                Divider(
                  height: 16.0,
                  color: Colors.transparent,
                ),
                LinearProgressIndicator(
                  value: maxProgress.toDouble() /
                      (challengeDocument['goal'] as int).toDouble(),
                  backgroundColor: Colors.orange.withAlpha(70),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    '$maxProgress/${challengeDocument['goal']}',
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
