import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'detail.dart';
import 'model/cat.dart';
import 'widget/round_shape.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  int _index;
  double _padding;
  FixedExtentScrollController _fixedExtentScrollController = FixedExtentScrollController(initialItem: 4);
  List<Cat> catList = new List<Cat>();
  bool isOnTap = false;
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  double _scale;
  
  _HomePageState() {
    final catData = CatStore().fetchAll();
    _index = catData.length - 1;
    catData.forEach((cat){
      catList.add(
          Cat(
              cat[Strs.keyCatId], 
              cat[Strs.keyCatName],
              cat[Strs.keyCatPosition],
              cat[Strs.keyCatSex],
              cat[Strs.keyCatDescription],
              cat[Strs.keyCatAvatar],
              cat[Strs.keyCatImg]
          )
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.2,
      duration: Duration(milliseconds: 177),
    );
    _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic
    )..addListener(() { setState(() {});});
    Future.delayed(
        Duration(milliseconds: 477), () =>
        _fixedExtentScrollController.animateToItem(0,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOutCubic)
    );
  }

  Widget _buildList(BuildContext context, int index, double height, double width){
    _scale = 1 - _curvedAnimation.value;
    return Padding(
        padding: EdgeInsets.all(_padding),
        child: Hero(
          tag: catList[index],
          transitionOnUserGestures: true,
          child: Transform.scale(
            scale: _scale,
            child: Card(
                color: Colors.transparent,
                elevation: 20.0,
                shape: RoundShape().build(),
                clipBehavior: Clip.antiAlias,
                semanticContainer: false,
                child: Stack(
                  children: <Widget>[
                    SizedBox.expand(
                        child: CachedNetworkImage(
                          imageUrl: catList[index].avatar,
                          fit: BoxFit.cover,
                          placeholder: (context, str) => Center(child: CircularProgressIndicator()),
                        )
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: BlurryContainer(
                          blur: 10.0,
                          height: 115,
                          width: width - 2 * _padding,
                          borderRadius: BorderRadius.zero,
                          child: Container(),
                        )
                    ),
                    Positioned(
                        bottom: 27,
                        left: 37,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              catList[index].displayName,
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.white, fontSize: 23),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              '${catList[index].position} · ${catList[index].sex == '未知' ? '未知' : catList[index].sex + '孩子'}',
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.grey, fontSize: 19),
                            )
                          ],
                        )
                    ),
                  ],
                )
            ),
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    var size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    _padding = width / 12;

    return Stack(
      children: [
        GestureDetector(
          onTapDown: (detail) => _controller.forward(),
          onTapUp: (detail) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyDetailPage(
                      cat: catList[_index],
                      catIndex: _index
                  )
              )
          ),
          onVerticalDragUpdate: (updateDetail) {
            if(updateDetail.delta.dy < -10){
              if(_index == catList.length - 1){
                _fixedExtentScrollController.animateTo(
                    _fixedExtentScrollController.position.maxScrollExtent + 50,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic
                );
              }else{
                _fixedExtentScrollController.animateToItem(
                    _index + 1,
                    duration: Duration(milliseconds: 777),
                    curve: Curves.easeInOutCubic
                );
              }
            }
            else if(updateDetail.delta.dy > 10){
              if(_index == 0){
                _fixedExtentScrollController.animateTo(
                    -50,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic
                );
              }else{
                _fixedExtentScrollController.animateToItem(
                    _index - 1,
                    duration: Duration(milliseconds: 777),
                    curve: Curves.easeInOutCubic
                );
              }
            }
          },
          child: ListWheelScrollView.useDelegate(
            itemExtent: (width - 2 * _padding) / width * height,
            diameterRatio: 6,
            onSelectedItemChanged: (index) => _index = index,
            controller: _fixedExtentScrollController,
            physics: NeverScrollableScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) => _buildList(context, index, height, width),
                childCount: catList.length),
          ),
        ),
        StatusBarOverlay()
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}