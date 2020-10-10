import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';
import 'package:flutter/material.dart';
import 'widget/round_shape.dart';
import 'widget/setting_item.dart';

class InfoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with TickerProviderStateMixin{
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  double _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.7,
      duration: Duration(milliseconds: 777),
    );
    _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic
    )..addListener(() { setState(() {});});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = UserStore().loggedIn.fetch();
    _scale = 1 - _curvedAnimation.value;
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Container(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: (){
                  _controller.forward();
                  Future.delayed(Duration(milliseconds: 300), () => _controller.reverse());
                }, 
                child: Transform.scale(
                  scale: _scale,
                  child: Card(
                    elevation: 10.0,
                    shape: RoundShape().build(),
                    clipBehavior: Clip.antiAlias,
                    semanticContainer: false,
                    child: Stack(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 25 / 11,
                          child: Image.asset(
                              Strs.bannerToastNeko,
                              fit: BoxFit.cover),
                        ),
                        BlurryContainer(
                          blur: 10,
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: Text('点我登录'),
                          ),
                        ),
                        Positioned(
                            bottom: 5,
                            right: 8,
                            child: Text(
                              'Ver: Beta 0.0.1',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 20.0),
                Text(Strs.about),
                SizedBox(height: 10.0),
                SettingItem(title: Strs.feedback, onTap: () => Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(Strs.sendEmail),
                    ))
                ),
                SettingItem(title: Strs.joinUserGroup, onTap: () => launchURL(Strs.joinQQUrl)),
                SizedBox(height: 20.0),
                SettingItem(title: Strs.usageHelp, onTap: () => showDialog(context: context, builder: (ctx){
                  return AlertDialog(
                    shape: RoundShape().build(),
                    content: SizedBox(
                      height: 77,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(Strs.photoWrongSolution),
                          Text(Strs.helpText1)
                        ],
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
                })),
                loggedIn
                    ? _logInOutBtn(context, '退出登录', Colors.redAccent, (){})
                    : Container()
                ,
                SizedBox(height: 40.0)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _logInOutBtn(BuildContext context, String btnName, Color color,
      GestureTapCallback onTap) {
    return Container(
      height: 35.0,
      child: Material(
        elevation: 10.0,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: MaterialButton(
            child: Text(btnName), textColor: Colors.white, onPressed: onTap),
      ),
    );
  }
}