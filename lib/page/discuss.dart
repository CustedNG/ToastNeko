import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/model/comment.dart';
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
  Map<Comment, List<Comment>> data;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async{
    _isBusy = false;
    widget.commentData.forEach((element) {
      //if(element)
    });
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
    final listLen = widget.commentData.length + 1;
    return ListView.builder(
        itemCount: listLen,
        itemBuilder: (context, index){
          return Padding(
              padding: EdgeInsets.all(17),
              child: index == listLen - 1
                  ? Center(child: Text('没有更多了╮(╯▽╰)╭'))
                  : _buildCommentItem(index)
          );
        }
    );
  }

  Widget _buildCommentItem(int index){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.commentData[index].nick + ': '),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.commentData[index].content),
            ExpandChild(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('该功能还在开发')
                ]
              ),
            )
          ],
        )
      ],
    );
  }
}