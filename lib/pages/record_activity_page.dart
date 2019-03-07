import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:csc318_fitnessfellows/data/activities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc318_fitnessfellows/pages/challenges_page.dart'
    as challenges_page;
import 'package:firebase_storage/firebase_storage.dart';

class RecordActivityPage extends StatefulWidget {
  @override
  _RecordActivityPageState createState() => _RecordActivityPageState();
}

class _RecordActivityPageState extends State<RecordActivityPage>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  List<Tab> tabs;
  List<Widget> pages;

  @override
  void initState() {
    super.initState();

    tabs = [
      Tab(text: 'Personal'),
      Tab(text: 'Group'),
    ];

    pages = [RecordActivityPersonal(), RecordActivityGroup()];
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black54),
        title: Text(
          'Record Activity',
          style: TextStyle(color: Colors.black),
        ),
        bottom: TabBar(
          controller: tabController,
          tabs: tabs,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: BubbleTabIndicator(
            indicatorColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: pages,
      ),
    );
  }
}

class RecordActivityPersonal extends StatefulWidget {
  @override
  _RecordActivityPersonalState createState() => _RecordActivityPersonalState();
}

class _RecordActivityPersonalState extends State<RecordActivityPersonal> {
  Activity selectedActivity = activities.first;
  DateTime selectedDate = DateTime.now();

  TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: '0');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Type',
            style: Theme.of(context).textTheme.title,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: DropdownButton<Activity>(
              onChanged: (activity) {
                setState(() {
                  selectedActivity = activity;
                });
              },
              value: selectedActivity,
              items: activities.map((activity) {
                return DropdownMenuItem<Activity>(
                  value: activity,
                  child: Text(activity.name),
                );
              }).toList(),
            ),
          ),
          Text(
            'Date',
            style: Theme.of(context).textTheme.title,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: RaisedButton(
              colorBrightness: Brightness.dark,
              color: Colors.green,
              onPressed: () async {
                DateTime dateTime = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2018),
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                );

                if (dateTime == null) {
                  return;
                }

                setState(() {
                  selectedDate = dateTime;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}'),
              ),
            ),
          ),
          Text(
            selectedActivity.units,
            style: Theme.of(context).textTheme.title,
          ),
          Container(
            width: 100.0,
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: RaisedButton(
                onPressed: submitActivity,
                child: Text('Submit'),
                color: Colors.orange,
                colorBrightness: Brightness.dark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void submitActivity() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

    if (amountController.text.length <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Enter an amount'),
          actions: <Widget>[
            FlatButton(
              onPressed: Navigator.of(context).pop,
              child: Text('Okay'),
            )
          ],
        ),
      );
      return;
    }

    await Firestore.instance.collection('activity').add({
      'uid': currentUser.uid,
      'activity': selectedActivity.id,
      'date': selectedDate,
      'amount': int.parse(amountController.text),
    });

    Navigator.of(context).pop();
  }

  @override
  dispose() {
    super.dispose();

    amountController.dispose();
  }
}

class RecordActivityGroup extends StatefulWidget {
  @override
  _RecordActivityGroupState createState() => _RecordActivityGroupState();
}

class _RecordActivityGroupState extends State<RecordActivityGroup> {
  TextEditingController amountController;

  @override
  initState() {
    super.initState();

    amountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
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
              stream: (userDocument['group'] as DocumentReference).snapshots(),
              builder: (context, groupSnapshot) {
                if (!groupSnapshot.hasData) {
                  return buildProgressSliver();
                }

                if (groupSnapshot.data['challenge'] == null) {
                  return Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No challenge set.'),
                    ),
                  );
                }

                return buildGroupPage(userDocument, groupSnapshot.data);
              },
            );
          },
        );
      },
    );
  }

  Widget buildGroupPage(
      DocumentSnapshot userDocument, DocumentSnapshot groupDocument) {
    return StreamBuilder(
      stream: groupDocument['challenge'] != null
          ? (groupDocument['challenge'] as DocumentReference).snapshots()
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

        Activity activity = getActivity(snapshot.data['activity']);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            challenges_page.buildChallengeTile(context, snapshot.data),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                activity.units,
                style: Theme.of(context).textTheme.title,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 100.0,
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: RaisedButton(
                  onPressed: () => submitActivity(
                      userDocument, groupDocument, snapshot.data, activity),
                  child: Text('Submit'),
                  color: Colors.orange,
                  colorBrightness: Brightness.dark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void submitActivity(
      DocumentSnapshot userDocument,
      DocumentSnapshot groupDocument,
      DocumentSnapshot challengeDocument,
      Activity activity) async {
    if (amountController.text.length <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Enter an amount'),
              actions: <Widget>[
                FlatButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text('Okay'),
                )
              ],
            ),
      );
      return;
    }
    await challengeDocument.reference
        .collection('submissions')
        .document(userDocument.documentID)
        .setData({
      'amount': int.parse(amountController.text),
      'group': groupDocument.documentID,
    });

    Navigator.of(context).pop();
  }

  Widget buildProgressSliver() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    super.dispose();

    amountController.dispose();
  }
}
