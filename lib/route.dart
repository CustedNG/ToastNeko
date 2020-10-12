import 'package:flutter/material.dart';

class AppRoute{
  final page;

  AppRoute(this.page);

  void go(BuildContext context){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }
}