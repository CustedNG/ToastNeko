import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/all_str.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/model/error.dart';
import 'package:cat_gallery/page/intro.dart';
import 'package:cat_gallery/page/login.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:cat_gallery/widget/round_btn.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:cat_gallery/widget/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with TickerProviderStateMixin{
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  double _scale;
  UserProvider _user;
  bool _isChangingNick;
  bool loggedIn;
  bool isPanelOpen = false;
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
    loggedIn = _user.loggedIn;

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text(Strs.appName),
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
      onPanelClosed: () => setState(() => isPanelOpen = false),
      onPanelOpened: () => setState(() => isPanelOpen = true),
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
                    mainAxisAlignment: loggedIn
                        ? MainAxisAlignment.spaceEvenly
                        : MainAxisAlignment.center,
                    children: [
                      !loggedIn
                          ? RoundBtn('登录', Colors.cyan, () =>
                              isPanelOpen ? null : AppRoute(LoginPage()).go(context)
                          )
                          : RoundBtn('退出登录', Colors.redAccent, () =>
                              isPanelOpen ? null : logout()
                          ),
                      loggedIn
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
        child: loggedIn ? _buildMsgList(context) : Center(child: Text('请先登录'))
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(26.0),
        topRight: Radius.circular(26.0),
      ),
    );
  }

  void logout() async{
    loggedIn = false;
    await _user.logout();
    setState((){});
  }

  Widget _buildMsgList(BuildContext context){
    final msgList = json.decode(_user.msg)['msg_list'];
    final listLength = msgList.length + 1;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 17, bottom: 27),
          child: Icon(Icons.keyboard_arrow_down)
        ),
        SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              itemCount: listLength,
              itemBuilder: (context, index){
                return Center(
                    child: Padding(
                        padding: EdgeInsets.all(17),
                        child: msgList.length == 0
                            ? Text('你当前没有任何消息')
                            : (index == listLength - 1 ? Text('~~~') : _buildCommentItem(msgList, index - 1))//
                    )
                );
              }
          ),
        )
      ],
    );
  }

  Widget _buildCommentItem(dynamic msgList, int index){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(msgList[index].nick + '回复了你: '),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msgList[index].content)
          ],
        )
      ],
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
                  'Ver: Beta 0.' + Strs.versionCode.toString(),
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
        _user.openId == null
            ? SizedBox(height: 1)
            : SettingItem(title: '抽奖', onTap: () => _buildLotteryDialog()),
        SettingItem(title: Strs.joinUserGroup, onTap: () => launchURL(Strs.joinQQUrl)),
        SizedBox(height: 17.0),
        SettingItem(title: Strs.usageHelp, onTap: () =>
            AppRoute(IntroScreen()).go(context)
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
    
    try{
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
          }
      );
    }catch(e){
      showWrongToastByCode(context, e.toString(), nickError);
    }
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