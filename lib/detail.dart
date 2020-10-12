import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/photo.dart';
import 'package:cat_gallery/position.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/timeline.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/custom_image.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'discuss.dart';
import 'model/cat.dart';

class MyDetailPage extends StatefulWidget {
  final Cat cat;
  final int catIndex;

  MyDetailPage({Key key, this.cat, this.catIndex}) : super(key: key);

  @override
  _MyDetailPageState createState() => _MyDetailPageState(cat, catIndex);
}

class _MyDetailPageState extends State<MyDetailPage> with AutomaticKeepAliveClientMixin{
  Cat cat;

  _MyDetailPageState(Cat cat, int catIndex) {
    this.cat = cat;
  }

  Widget _buildCard(int index){
    bool isNotLast = index != cat.img.length;
    String url = Strs.baseImgUrl + cat.img[isNotLast ? index : 0];

    return GestureDetector(
      onTap: () => isNotLast ? AppRoute(
          PhotoPage(
            url: url,
            index: index,
            cat: cat,
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
                    '${index + 1}',
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
            itemCount: cat.img.length + 1,
            itemBuilder: (BuildContext context, int index) => Hero(
                tag: index == 0 ? cat : index.hashCode,
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
                          child: Maps.search(cat.position),
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
              icon: Icon(Icons.chat),
              onPressed: () => AppRoute(ChatPage(catId: cat.id)).go(context)
          ),
          IconButton(
              icon: Icon(Icons.alt_route),
              onPressed: () => AppRoute(
                  TimelinePage(catId: cat.id, catName: cat.displayName)
              ).go(context)
          )
        ],
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
