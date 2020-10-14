import 'dart:convert';

import 'package:cat_gallery/store/cat_store.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final catId;

  const ChatPage({Key key, this.catId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var _commentData;
  bool _isBusy = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async{
    final catStore = CatStore();
    await catStore.init();
    _commentData = json.decode(catStore.fetch(widget.catId))['comment'];
    _isBusy = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('开发中！！！'),
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
        itemCount: _commentData.length,
        itemBuilder: (context, index){
          return Container();
        }
    );
  }
}