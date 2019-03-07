import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc318_fitnessfellows/data/activities.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ActivityPage extends StatefulWidget {
  ActivityPage({this.activity, this.userActivity});

  final Activity activity;
  final List<DocumentSnapshot> userActivity;

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime dateToDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    widget.userActivity
        .sort((snap1, snap2) => snap1['date'].isAfter(snap2['date']) ? 1 : -1);
    List<DocumentSnapshot> activity = widget.userActivity.where((doc) {
      List<DocumentSnapshot> sameDay = widget.userActivity
          .where((doc1) =>
              dateToDay(doc1['date']).isAtSameMomentAs(dateToDay(doc['date'])))
          .toList();

      return sameDay.reduce(
              (doc1, doc2) => doc1['amount'] > doc2['amount'] ? doc1 : doc2) ==
          doc;
    }).toList();
    List<Series<DocumentSnapshot, DateTime>> series = [];
    series.add(
      Series<DocumentSnapshot, DateTime>(
          id: 'activity',
          data: activity,
          domainFn: (doc, _) =>
              DateTime(doc['date'].year, doc['date'].month, doc['date'].day),
          measureFn: (doc, _) => doc['amount']),
    );

    int best = widget.userActivity.fold(
      0,
      (prev, doc) => max(
            prev,
            doc['amount'],
          ),
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            title: Text(widget.activity.name),
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image.asset(
                            'assets/icons/${widget.activity.icon}.png',
                            width: 48.0,
                            height: 48.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            expandedHeight: 180.0,
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.title,
                  ),
                  Container(height: 200.0, child: TimeSeriesChart(series)),
                  Divider(
                    height: 16.0,
                    color: Colors.transparent,
                  ),
                  Text(
                    'Best',
                    style: Theme.of(context).textTheme.title,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '$best ${widget.activity.units}',
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                  ),
                  Divider(color: Colors.transparent,),
                  Text(
                    'Recent Progress',
                    style: Theme.of(context).textTheme.title,
                  ),
                  Column(
                    children: widget.userActivity.map((doc) {
                      return ListTile(
                        title: Text('${doc['amount']} ${widget.activity.units}'),
                        trailing: Text('${doc['date'].year}/${doc['date'].month}/${doc['date'].day}'),
                      );
                    }).toList().reversed.toList(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
