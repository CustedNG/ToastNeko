import 'dart:convert';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/intro.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/model/comment.dart';
import 'package:cat_gallery/photo.dart';
import 'package:cat_gallery/position.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/timeline.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/custom_image.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DetailPage extends StatefulWidget {
  final Cat cat;
  final int catIndex;

  DetailPage({Key key, this.cat, this.catIndex}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with AutomaticKeepAliveClientMixin{
  final _catStore = locator<CatStore>();
  List<Comment> _comments = [];
  int _commentsLen;

  @override
  void initState(){
    super.initState();
    initData();
  }

  void initData(){
    final commentsData = json.decode(_catStore.fetch(widget.cat.id))[Strs.keyComment];
    for(Map<String, dynamic> comment in commentsData){
      _comments.add(
          Comment(
              comment[Strs.keyCommentContent],
              comment[Strs.keyUserInfo][Strs.keyUserName],
              comment[Strs.keyCommentID],
              comment[Strs.keyUserInfo][Strs.keyUserId],
              comment[Strs.keyCreateTime]
          )
      );
    }
    _commentsLen = _comments.length;
  }

  Widget _buildCard(int index){
    bool isNotLast = index != widget.cat.img.length;
    String url = Strs.baseImgUrl + widget.cat.img[isNotLast ? index : 0];

    return GestureDetector(
      onTap: () => isNotLast ? AppRoute(
          PhotoPage(
            url: url,
            index: index,
            cat: widget.cat,
          )
      ).go(context) : null,
      child: Card(
        color: Colors.transparent,
        elevation: 20.0,
        shape: RoundShape().build(),
        clipBehavior: Clip.antiAlias,
        semanticContainer: false,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
                child: isNotLast ? MyImage(
                  imgUrl: url,
                  index: index,
                ) : Center(child: Text('没有了\n(´･ω･`)')),
            ),
            isNotLast ? Positioned(
                bottom: 0,
                child: BlurryContainer(
                  height: 47,
                  width: MediaQuery.of(context).size.width - 60,
                  borderRadius: BorderRadius.zero,
                  child: Text(
                    index < _commentsLen ? _comments[index].content : '暂无评论',
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                )
            ) : Container(),
          ],
        ),
      ),
    );
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
            itemCount: widget.cat.img.length + 1,
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
