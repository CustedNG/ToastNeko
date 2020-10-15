import 'dart:convert';

import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/model/comment.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final List<Comment> commentData;
  final Cat cat;

  const ChatPage({Key key, this.commentData, this.cat}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isBusy = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async{
    _isBusy = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cat.displayName}的粉丝发言'),
        centerTitle: true,
      ),
      body: Theme(
          data: Theme.of(context).copyWith(
            accentColor: Colors.white.withOpacity(0.2),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: _isBusy ? CircularProgressIndicator() : _buildList(context),
            ),
          )
      ),
    );
  }

  Widget _buildList(BuildContext context){
    return ListView.builder(
        itemCount: widget.commentData.length,
        itemBuilder: (context, index){
          return ExpandChild(
            child: Text(widget.commentData[index].content),
          );
        }
    );
  }
}