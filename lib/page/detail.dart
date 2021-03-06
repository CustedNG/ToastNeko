import 'dart:convert';
import 'dart:math';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/all_str.dart';
import 'package:cat_gallery/model/reply.dart';
import 'package:cat_gallery/page/info.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/model/comment.dart';
import 'package:cat_gallery/page/photo.dart';
import 'package:cat_gallery/widget/position.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/page/timeline.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/custom_image.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final Cat cat;
  final int catIndex;

  DetailPage({Key key, this.cat, this.catIndex}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with AutomaticKeepAliveClientMixin{
  List<Comment> _comments = [];
  bool notBusy = false;
  CatProvider _catProvider;

  @override
  void initState(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initData();
    });
    super.initState();
  }

  Future<void> initData() async {
    _catProvider = Provider.of<CatProvider>(context);
    final catJson = await _catProvider.fetch(widget.cat.id);
    final commentsData = json.decode(catJson)[Strs.keyComment];
    for(Map<String, dynamic> comment in commentsData){
      _comments.add(
          Comment(
              comment[Strs.keyCommentContent],
              comment[Strs.keyUserInfo][Strs.keyUserName],
              comment[Strs.keyCommentID],
              comment[Strs.keyUserInfo][Strs.keyUserId],
              comment[Strs.keyCreateTime],
              comment[Strs.keyFileName],
              json.encode(kv(comment, Strs.keyReply, []))
          )
      );
    }
    setState(() {
      notBusy = true;
    });
  }

  Widget _buildCard(int index){
    String url = Strs.baseImgUrl + widget.cat.img[index];
    List<String> _commentsStringList = [];
    List<Comment> _commentsList = [];
    List<Reply> _replyList = [];
    _comments.forEach((ele) {
      if(ele.fileName == widget.cat.img[index]){
          _commentsList.add(ele);
          for(dynamic reply in json.decode(ele.reply)){
            _replyList.add(
                Reply(
                    ele.commentId,
                    reply[Strs.keyReplyId],
                    reply[Strs.keyCommentContent],
                    reply[Strs.keyUserInfo][Strs.keyUserId],
                    reply[Strs.keyUserInfo][Strs.keyUserName],
                    reply[Strs.keyCreateTime]
                )
            );
          }
          _commentsStringList.add(
              buildCommentString(_comments[_comments.indexOf(ele)], ':\n')
          );
      }
    });

    return GestureDetector(
      onTap: () => AppRoute(
          PhotoPage(
            url: url,
            index: index,
            cat: widget.cat,
            commentList: _commentsList,
            replyList: _replyList,
          )
      ).go(context),
      child: Card(
        color: Colors.transparent,
        elevation: 20.0,
        shape: RoundShape().build(),
        clipBehavior: Clip.antiAlias,
        semanticContainer: false,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
                child: MyImage(
                  imgUrl: url,
                ),
            ),
            Positioned(
                bottom: 0,
                child: BlurryContainer(
                  padding: EdgeInsets.all(13),
                  height: 63,
                  width: MediaQuery.of(context).size.width / 2 - 10,
                  borderRadius: BorderRadius.zero,
                  child: Text(
                      _commentsStringList.length != 0
                          ? _commentsStringList[Random().nextInt(_commentsStringList.length)]
                          : '暂无评论\n${widget.cat.displayName}想要评论',
                      textScaleFactor: 1.0,
                      overflow: TextOverflow.fade,
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backGroundColor = Theme.of(context).scaffoldBackgroundColor;
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          StaggeredGridView.countBuilder(
            physics: BouncingScrollPhysics(),
            crossAxisCount: 4,
            itemCount: widget.cat.img.length,
            itemBuilder: (BuildContext context, int index) => Hero(
                tag: index == 0 ? widget.cat : index.hashCode,
                transitionOnUserGestures: true,
                child: _buildCard(index)
            ),
            staggeredTileBuilder: (int index) =>
                StaggeredTile.count(2, index.isEven ? 3.15 : 3.6),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          StatusBarOverlay(),
          Positioned(
            top: 47,
            right: 27,
            child: GestureDetector(
              child: Icon(Icons.info_outline, color: Colors.red),
              onTap: () => showRoundDialog(
                  context,
                  '性别未知',
                  Text('如果您知道${widget.cat.displayName}的性别，请加入用户群，向管理员反馈该信息，谢谢！'),
                  [
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('好')
                    )
                  ]
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FabCircularMenu(
        ringWidth: 77,
        ringDiameter: 277,
        ringColor: backGroundColor,
        fabColor: backGroundColor,
        animationCurve: Curves.easeInOutCubic,
        children: [
          IconButton(
              icon: Icon(Icons.map),
              onPressed: () => showDialog(
                  context: context,
                  builder: (ctx){
                    return AlertDialog(
                      contentPadding: EdgeInsets.fromLTRB(19, 20, 19, 7),
                      shape: RoundShape().build(),
                      title: Text('发现地'),
                      elevation: 20,
                      content: SizedBox(
                        height: 270 * 0.618,
                        child: ClipRect(
                          child: Maps.search(widget.cat.position),
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('确定'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  })
          ),
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => AppRoute(
                  InfoPage(
                      cat: widget.cat,
                  )
              ).go(context)
          ),
          IconButton(
              icon: Icon(Icons.alt_route),
              onPressed: () => AppRoute(
                  TimelinePage(
                      catId: widget.cat.id,
                      catName: widget.cat.displayName
                  )
              ).go(context)
          )
        ],
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
