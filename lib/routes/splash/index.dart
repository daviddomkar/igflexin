import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          colors: [
            Color.fromARGB(255, 223, 61, 139),
            Color.fromARGB(255, 255, 161, 94),
          ],
        ),
      ),
    );
  }
}
