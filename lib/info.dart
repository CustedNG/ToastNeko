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
                              'assets/toast_neko.png',
                              fit: BoxFit.cover),
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
                Text('关于'),
                SizedBox(height: 10.0),
                SettingItem(title: '向我们反馈', onTap: () => Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('请发送邮件至\n2036293523@qq.com'),
                    ))
                ),
                SettingItem(title: '加入用户群', onTap: () => launchURL('https://jq.qq.com/?_wv=1027&k=86nHLzAl')),
                SizedBox(height: 20.0),
                SettingItem(title: '使用帮助', onTap: () => showDialog(context: context, builder: (ctx){
                  return AlertDialog(
                    shape: RoundShape().build(),
                    content: SizedBox(
                      height: 77,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('如果图片显示错误，请清除所有数据。'),
                          Text('首页上下滑动，点击查看图片。')
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
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _logInOutBtn(context, '重新登录', Colors.lightBlue, (){}),
                    SizedBox(width: 40.0),
                    _logInOutBtn(context, '退出登录', Colors.redAccent, (){})
                  ],
                ),*/
                SizedBox(height: 40.0)
              ],
            )
          ],
        ),
      ),
    );
  }
}