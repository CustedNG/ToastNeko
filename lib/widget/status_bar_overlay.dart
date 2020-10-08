import 'package:flutter/material.dart';

class StatusBarOverlay extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Container(
        height: 47,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: FractionalOffset(0.5, 0),
                end: FractionalOffset(0.5, 1)
            )
        ),
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

}