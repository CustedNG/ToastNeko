import 'package:flutter/material.dart';

class RoundShape extends RoundedRectangleBorder{
  RoundedRectangleBorder build() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    );
  }
}