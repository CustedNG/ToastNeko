import 'dart:convert';
import 'dart:math';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/page/discuss.dart';
import 'package:cat_gallery/page/intro.dart';
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

  @override
  void initState(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initData();
    });
    super.initState();
  }

  Future<void> initData() async {
    final _catProvider = Provider.of<CatProvider>(context);
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
              comment[Strs.keyFileName]
          )
      );
    }
    setState(() {
      notBusy = true;
    });
  }

  Widget _buildCard(int index){
    String url = Strs.baseImgUrl + widget.cat.img[index];
    List<String> _commentsList = [];
    _comments.forEach((ele) {
      if(ele.fileName == widget.cat.img[index])
        _commentsList.add(
            _comments[_comments.indexOf(ele)].nick
                + '：\n'
                + _comments[_comments.indexOf(ele)].content
        );
    });

    return notBusy ? GestureDetector(
      onTap: () => AppRoute(
          PhotoPage(
            url: url,
            index: index,
            cat: widget.cat,
            commentData: _comments,
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
                  index: index,
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
                      _commentsList.length != 0
                          ? _commentsList[Random().nextInt(_commentsList.length)]
                          : '暂无评论\n${widget.cat.displayName}想要评论',
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                )
            ),
          ],
        ),
      ),
    ) : Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
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
                StaggeredTile.count(2, index.isEven ? 3.5 : 4),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          StatusBarOverlay()
        ],
      ),
      floatingActionButton: FabCircularMenu(
        ringWidth: 77,
        ringDiameter: 277,
        ringColor: isDarkMode(context) ? Colors.black87 : Colors.white70,
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
                  IntroPage(
                      cat: widget.cat,
                  )
              ).go(context)
          ),
          IconButton(
              icon: Icon(Icons.chat),
              onPressed: () => AppRoute(
                  ChatPage(
                    cat: widget.cat,
                    commentData: _comments,
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
