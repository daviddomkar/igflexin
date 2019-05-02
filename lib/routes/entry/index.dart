import 'package:flutter/material.dart';
import 'package:igflexin/router/router.dart';

class Entry extends StatefulWidget {
  @override
  _EntryState createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouterController.switchRouteStatic(context, 'main', 'auth');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          colors: [Color.fromARGB(255, 223, 61, 139), Color.fromARGB(255, 255, 161, 94)],
        ),
      ),
    );
  }
}
