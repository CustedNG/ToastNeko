import 'dart:convert';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_gallery/photo.dart';
import 'package:cat_gallery/position.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
  int catIndex;
  Map<String, dynamic> photoAmount = {
    'Neko': 5,
    'Tom': 4,
    'Miao': 2,
    'Mi': 1,
    'Mao': 1
  };

  _MyDetailPageState(Cat cat, int catIndex) {
    this.cat = cat;
    this.catIndex = catIndex;
  }

  @override
  void initState(){
    super.initState();
    getData();
  }

  void getData() async{
    try {
      Response response = await Dio().get('https://cat.lolli.tech/data/photo_amount.json');
      if (response.statusCode == 200) {
        photoAmount = jsonDecode(response.toString());
      } else {
        print('Http status ${response.statusCode}');
      }
    } catch (exception) {
      print(exception);
    }

    if (!mounted) return;
    setState(() {
      print('Photo Amount Data: $photoAmount');
    });
  }

  Widget _buildCard(int index){
    String url = 'https://cat.lolli.tech/img/${catIndex + 1}/${index + 1}.JPG';
    bool isNotLast = index != photoAmount[cat.name];

    return GestureDetector(
      onTap: () => isNotLast ? Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhotoPage(
                url: url,
                index: index,
                cat: cat,
              )
          )) : null,
      child: Card(
        color: Colors.transparent,
        elevation: 20.0,
        shape: RoundShape().build(),
        clipBehavior: Clip.antiAlias,
        semanticContainer: false,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
                child: isNotLast ?
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                ) : Center(child: Text('没有了\n(´･ω･`)'))
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
            itemCount: photoAmount[cat.name] + 1,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (ctx){
              return AlertDialog(
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
            }),
        backgroundColor: cat.sex == '男' ? Colors.lightBlueAccent : Colors.pinkAccent,
        child: Icon(Icons.alt_route),
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
