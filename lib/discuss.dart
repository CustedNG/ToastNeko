import 'package:cat_gallery/timeline.dart';
import 'package:flutter/material.dart';

class DiscussPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _DiscussPageState();

}

class _DiscussPageState extends State<DiscussPage>{
  @override
  Widget build(BuildContext context) {
    return ActivityTimeline();
  }
}