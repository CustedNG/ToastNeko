import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/page/login.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:cat_gallery/widget/round_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../widget/round_shape.dart';
import '../widget/setting_item.dart';

class InfoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with TickerProviderStateMixin{
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  double _scale;
  UserProvider _user;
  bool _isChangingNick;
  final panelBorder = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  final _nickController = TextEditingController();
  final _nickFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isChangingNick = false;
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
    _nickController.dispose();
    _nickFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context);
    _scale = 1 - _curvedAnimation.value;

    if(_user.isBusy)return CircularProgressIndicator();

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: FadeAnimatedTextKit(
            text: [Strs.appName, _user.loggedIn ? '欢迎，${_user.nick}' : '🐱'],
            isRepeatingAnimation: true,
            repeatForever: true,
            textStyle: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _buildUser()
    );
  }

  Widget _buildUser(){
    return SlidingUpPanel(
      body: _buildScrollView(context),
      maxHeight: 377,
      minHeight: 77,
      collapsed: Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: panelBorder
        ),
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_arrow_up, color: Colors.white),
                Row(
                    mainAxisAlignment: _user.loggedIn
                        ? MainAxisAlignment.spaceEvenly
                        : MainAxisAlignment.center,
                    children: [
                      !_user.loggedIn
                          ? RoundBtn('登录', Colors.cyan, () => AppRoute(LoginPage()).go(context))
                          : RoundBtn('退出登录', Colors.redAccent, () => _user.logout()),
                      _user.loggedIn
                          ? RoundBtn('修改昵称', Colors.cyan, () => _buildNickDialog(context))
                          : Container(),
                    ]
                ),
                SizedBox(height: 13),
              ],
            )
        ),
      ),
      panel: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: panelBorder
        ),
        child: Center(child: Text('你当前还没有任何消息（功能开发中）')),
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(26.0),
        topRight: Radius.circular(26.0),
      ),
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

    return BounceInDown(
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
      ),
    );
  }

  Widget _buildSetting(BuildContext context){
    return Column(
      children: [
        SizedBox(height: 17.0),
        Text(Strs.about),
        SizedBox(height: 7.0),
        SettingItem(title: '抽奖', onTap: () => _buildLotteryDialog()),
        SettingItem(title: Strs.joinUserGroup, onTap: () => launchURL(Strs.joinQQUrl)),
        SizedBox(height: 17.0),
        SettingItem(title: Strs.usageHelp, onTap: () =>
            showRoundDialog(
                context,
                '帮助',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(Strs.photoWrongSolution),
                    Text(Strs.helpText1)
                  ],
                ),
                [
                  FlatButton(
                    child: Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]
            )
        ),
      ],
    );
  }

  void _buildLotteryDialog(){
    bool loggedIn = _user.loggedIn;

    if(!loggedIn){
      showRoundDialog(
          context,
          '请登录',
          Text('需要登录来验证你是否是长理学子，以便判断抽奖资格'),
          [
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('好')
            )
          ]
      );
      return;
    }

    showRoundDialog(
        context,
        '你的兑换码',
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(base64Encode(utf8.encode(_user.openId.replaceFirst('2020', '0202')))),
            SizedBox(height: 7),
            Text('请加入用户群，以获取中奖信息')
          ],
        ),
        [
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('我收下了')
          )
        ]
    );
  }

  Future<void> tryChangeNick() async {
    if(_isChangingNick)return;

    if(!isInputNotRubbish([_nickController], 12, 4)){
      showWrongDialog(context, '昵称不得长于12小与4');
      return;
    }
    
    await Request().go(
        'put',
        Strs.userChangeNick,
        data: {
          Strs.keyUserId : _user.openId,
          Strs.keyUserName : _nickController.value.text
        },
        success: (data){
          _user.setNick(_nickController.value.text);
          Navigator.of(context).pop();
          _nickController.clear();
          showToast(context, '修改昵称成功', false);
        },
        failed: (code) => showToast(context, '错误码 $code', false)
    );
    _isChangingNick = false;
  }

  void _buildNickDialog(BuildContext context) {
    showRoundDialog(
        context,
        '修改昵称',
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: _nickController,
              focusNode: _nickFocusNode,
              maxLength: 12,
              style: TextStyle(color: Colors.white),
              decoration: buildDecoration('想要的新昵称'),
            )
          ],
        ),
        [
          FlatButton(
            child: _isChangingNick
                ? Padding(
                    padding: EdgeInsets.all(5),
                    child: CircularProgressIndicator(),
                )
                : Text('确定'),
            onPressed: () {
              tryChangeNick();
            },
          ),
          FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('取消')
          )
        ]
    );
  }
}