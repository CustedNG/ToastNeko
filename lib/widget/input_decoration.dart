import 'package:flutter/material.dart';

InputDecoration buildDecoration(String label){
  return InputDecoration(
      labelText: label,
  );
}

InputDecoration buildRoundDecoration(String label, [Icon preIcon, Icon sufIcon]){
  return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.all(3),
      prefixIcon: preIcon,
      suffixIcon: sufIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(55.0)),
  );
}