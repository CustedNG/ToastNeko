import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/login.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  UserProvider user;

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
    user = Provider.of<UserProvider>(context);
    _scale = 1 - _curvedAnimation.value;

    if(user.isBusy)return CircularProgressIndicator();

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Container(),
        centerTitle: true,
      ),
      body: _buildScrollView(context)
    );
  }

  Widget _buildScrollView(BuildContext context){
    return SingleChildScrollView(
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
                child: _buildCard(context),
              ),
            ),
          ),
          _buildSetting(context)
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context){
    TextStyle bannerTextStyle = TextStyle(
        color: Colors.white70,
        fontSize: 15,
        fontWeight: FontWeight.bold
    );

    return Card(
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
          Positioned(
              bottom: 5,
              right: 8,
              child: Text(
                'Ver: Beta 0.0.1',
                style: bannerTextStyle,
              )
          )
        ],
      ),
    );
  }

  Widget _buildSetting(BuildContext context){
    return Column(
      children: [
        SizedBox(height: 20.0),
        Text(Strs.about),
        SizedBox(height: 10.0),
        SettingItem(title: Strs.joinUserGroup, onTap: () => launchURL(Strs.joinQQUrl)),
        SizedBox(height: 20.0),
        SettingItem(title: Strs.usageHelp, onTap: () =>
            showDialog(context: context, builder: (ctx){
              return _buildAlertDialog(context);
            })
        ),
        SizedBox(height: 40),
        !user.loggedIn
            ? _logInOutBtn(context, '登录', Colors.redAccent, () => AppRoute(LoginPage()).go(context))
            : _logInOutBtn(context, '退出登录', Colors.redAccent, () => user.logout())
        ,
        SizedBox(height: 40.0)
      ],
    );
  }

  Widget _buildAlertDialog(BuildContext context){
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