import 'package:csc318_fitnessfellows/pages/home_page.dart';
import 'package:csc318_fitnessfellows/pages/challenges_page.dart';
import 'package:csc318_fitnessfellows/pages/group_page.dart';
import 'package:csc318_fitnessfellows/pages/personal_page.dart';
import 'package:flutter/material.dart';

class NavigationIconView {
  NavigationIconView({
    this.activeIcon,
    this.icon,
    this.titleBuilder,
    this.contentBuilder,
    TickerProvider vsync,
  })  : _icon = icon,
        controller = AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = controller.drive(CurveTween(
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    ));
  }

  final Widget icon;
  final Widget activeIcon;
  final Widget _icon;
  final AnimationController controller;
  final WidgetBuilder titleBuilder;
  final WidgetBuilder contentBuilder;
  Animation<double> _animation;

  FadeTransition transition(BuildContext context) {
    Color iconColor;

    final ThemeData themeData = Theme.of(context);
    iconColor = themeData.primaryColor;

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
          position: _animation.drive(
            Tween<Offset>(
              begin: const Offset(0.0, 0.02), // Slightly down.
              end: Offset.zero,
            ),
          ),
          child: contentBuilder(context)),
    );
  }
}

class CustomIcon extends StatelessWidget {
  CustomIcon({this.icon});

  IconData icon;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    return Icon(
      icon,
      color: Theme.of(context).primaryColor,
    );
  }
}

class CustomIconInactive extends StatelessWidget {
  CustomIconInactive({this.icon});

  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: Colors.black26,
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;

  List<NavigationIconView> _navigationViews;

  @override
  void initState() {
    super.initState();

    _navigationViews = <NavigationIconView>[
      NavigationIconView(
        activeIcon: CustomIcon(icon: Icons.home),
        icon: CustomIconInactive(icon: Icons.home),
        titleBuilder: (context) => Text(
              'Home',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
        contentBuilder: (context) => HomePage(),
        vsync: this,
      ),
      NavigationIconView(
        activeIcon: CustomIcon(icon: Icons.person),
        icon: CustomIconInactive(icon: Icons.person),
        titleBuilder: (context) => Text(
              'Personal',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
        contentBuilder: (context) => PersonalPage(),
        vsync: this,
      ),
      NavigationIconView(
        activeIcon: CustomIcon(icon: Icons.group),
        icon: CustomIconInactive(icon: Icons.group),
        titleBuilder: (context) => Text(
              'Group',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
        contentBuilder: (context) => GroupPage(),
        vsync: this,
      ),
      NavigationIconView(
        activeIcon: CustomIcon(icon: Icons.star),
        icon: CustomIconInactive(icon: Icons.star),
        titleBuilder: (context) => Text(
              'Challenges',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
        contentBuilder: (context) => ChallengesPage(),
        vsync: this,
      ),
    ];

    _navigationViews[_currentIndex].controller.value = 1.0;

    setCurrentPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = BottomNavigationBar(
        items: _navigationViews
            .map<BottomNavigationBarItem>((NavigationIconView navigationView) {
          return BottomNavigationBarItem(
            activeIcon: navigationView.activeIcon,
            icon: navigationView.icon,
            title: navigationView.titleBuilder(context),
          );
        }).toList(),
        currentIndex: _currentIndex,
        //iconSize: 4.0,
        onTap: setCurrentPage);

    return Scaffold(
      body: Center(
        child: _buildTransitionsStack(),
      ),
      bottomNavigationBar: botNavBar,
    );
  }

  void setCurrentPage(int index) {
    setState(() {
      _navigationViews[_currentIndex].controller.reverse();
      _currentIndex = index;
      _navigationViews[_currentIndex].controller.forward();
    });
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews) view.controller.dispose();
    super.dispose();
  }

  Widget _buildTransitionsStack() {
    final List<Widget> transitions = <Widget>[];

    for (NavigationIconView view in _navigationViews)
      transitions.add(
        IgnorePointer(
          ignoring: _navigationViews[_currentIndex] != view,
          child: view.transition(context),
        ),
      );

    return Stack(children: transitions);
  }
}
