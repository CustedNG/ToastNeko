import 'package:cat_gallery/timeline.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ChatPageState();

}

class _ChatPageState extends State<ChatPage>{
  @override
  Widget build(BuildContext context) {
    return TimelinePage();
  }
}