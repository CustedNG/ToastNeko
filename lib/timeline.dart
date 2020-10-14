import 'dart:convert';
import 'dart:math';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/login.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  final catId;
  final catName;

  const TimelinePage({Key key, this.catId, this.catName}) : super(key: key);

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<Step> _steps;
  bool _isBusy;
  bool _isUploading = false;

  final _textFieldController = TextEditingController();
  final _textFieldController2 = TextEditingController();
  final _userStore = locator<UserStore>();
  UserProvider _user;
  final _catStore = locator<CatStore>();

  static const List<Color> colorList = [
    Colors.cyan,
    Colors.pinkAccent,
    Colors.yellow,
    Colors.lightGreen,
    Colors.tealAccent,
    Colors.purple,
    Colors.brown,
    Colors.indigo
  ];
  static const List<IconData> iconList = [
    Icons.architecture,
    Icons.search,
    Icons.flag,
    Icons.navigation,
    Icons.local_library,
    Icons.home
  ];

  @override
  void initState() {
    _isBusy = true;
    initData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user = Provider.of<UserProvider>(context);
  }

  void initData() async{
    _steps = [];
    Map<String, dynamic> jsonData = json.decode(_catStore.fetch(widget.catId));
    final positions = jsonData[Strs.keyCatPosition];
    for(Map<String, dynamic> position in positions){
      if(_steps.isEmpty)_steps.add(
          Step(
            type: Type.line,
            duration: position['duration'],
            color: colorList[Random().nextInt(7)],
          )
      );
      _steps.add(
          Step(
            type: Type.checkpoint,
            message: position['time'],
            color: colorList[Random().nextInt(7)],
            icon: iconList[Random().nextInt(5)]
          )
      );
      _steps.add(
          Step(
              type: Type.line,
              duration: position['duration'],
              message: (position['nick'] ?? '') + ' 发现 ' +
                   widget.catName +
                  ' 在' + position['msg'],
              color: colorList[Random().nextInt(7)],
          )
      );
    }
    setState(() {
      _isBusy = false;
    });
  }

  String nowDIYTime(){
    final dateTime = DateTime.now();
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} '
        '${dateTime.hour}:${dateTime.minute}';
  }
  
  void tryUpload() async{
    if(_isUploading)return;
    _isUploading = true;
    setState(() {});
    final lastTime = _userStore.lastCommentTime.fetch();
    final nowTime = DateTime.now();
    final textValue1 = _textFieldController.value.text;
    final textValue2 = _textFieldController2.value.text;

    if(!isInputNotRubbish([_textFieldController, _textFieldController2])){
      showWrongDialog(context, '每项输入不得小于2大于10');
      _isUploading = false;
      return;
    }

    if(lastTime != null){
      if(nowTime.difference(DateTime.parse(lastTime)).inMinutes < 10){
        showWrongDialog(context, '每次上报间隔不小于十分钟');
        _isUploading = false;
        return;
      }
    }

    await Request().go(
        'put',
        Strs.publicManagePosition,
        data: {
          'neko_id': widget.catId,
          'position': {
            'location': textValue1,
            'time': nowDIYTime(),
            'duration': 0,
            'nick': _userStore.nick.fetch(),
            'msg': textValue2,
            'open_id': _userStore.openId.fetch()
          }
        },
        success: (body) async {
          await initCatData(widget.catId);
          setState(() {
            initData();
            _textFieldController.clear();
            _textFieldController2.clear();
            _userStore.lastCommentTime.put(nowTime.toString());
            Navigator.of(context).pop();
          });
        },
        failed: (code) => print(code)
    );
    _isUploading = false;
  }

  void _showAddDialog(){
    final catName = widget.catName;
    bool isLogin = _user.loggedIn;
    showRoundDialog(
        context,
        isLogin ? '我发现了$catName': '是否登录？',
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLogin ? TextField(
              controller: _textFieldController,
              decoration: buildDecoration('$catName在哪里'),
            ) : Text('需要登录才可以反馈$catName的行踪'),
            isLogin ? TextField(
              controller: _textFieldController2,
              decoration: buildDecoration('$catName在干什么'),
            ) : Container(),
          ],
        ),
        [
          FlatButton(
              onPressed: (){
                if(isLogin){
                  tryUpload();
                  return;
                }
                AppRoute(LoginPage()).go(context);
              },
              child: _isUploading
                  ? CircularProgressIndicator()
                  : Text(isLogin? '提交${widget.catName}行踪' : '登录')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.catName}的行踪'),
        centerTitle: true,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          accentColor: Colors.white.withOpacity(0.2),
        ),
        child: Center(
          child: _isBusy
              ? CircularProgressIndicator()
              : _TimelineActivity(steps: _steps),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showAddDialog();
        },
        child: Icon(Icons.remove_red_eye),
      ),
    );
  }
}

class _TimelineActivity extends StatelessWidget {
  const _TimelineActivity({Key key, this.steps}) : super(key: key);

  final List<Step> steps;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (BuildContext context, int index) {
        final Step step = steps[index];

        final IndicatorStyle indicator = step.isCheckpoint
            ? _indicatorStyleCheckpoint(step)
            : const IndicatorStyle(width: 0);

        final rightChild = _RightChildTimeline(step: step);

        Widget leftChild;
        if (step.hasHour) {
          leftChild = _LeftChildTimeline(step: step);
        }

        return TimelineTile(
          alignment: TimelineAlign.manual,
          isFirst: index == 0,
          isLast: index == steps.length - 1,
          lineXY: 0.15,
          indicatorStyle: indicator,
          startChild: leftChild,
          endChild: rightChild,
          hasIndicator: step.isCheckpoint,
          beforeLineStyle: LineStyle(
            color: step.color,
            thickness: 8,
          ),
        );
      },
    );
  }

  IndicatorStyle _indicatorStyleCheckpoint(Step step) {
    return IndicatorStyle(
      width: 46,
      height: 100,
      indicator: Container(
        decoration: BoxDecoration(
          color: step.color,
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Center(
          child: Icon(
            step.icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _RightChildTimeline extends StatelessWidget {
  const _RightChildTimeline({Key key, this.step}) : super(key: key);

  final Step step;

  @override
  Widget build(BuildContext context) {
    final double minHeight =
    step.isCheckpoint ? 100 : step.duration.toDouble() * 8;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          Padding(
            padding: EdgeInsets.only(
                left: step.isCheckpoint ? 20 : 39,
                top: 8,
                bottom: 8,
                right: 8),
            child: Text(
              step.type == Type.checkpoint
                  ? '${step.message}'
                  : step.message ?? '',
            )
          )
        ],
      ),
    );
  }
}

class _LeftChildTimeline extends StatelessWidget {
  const _LeftChildTimeline({Key key, this.step}) : super(key: key);

  final Step step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, right: step.isCheckpoint ? 10 : 29),
          child: Text(
            step.hour,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}

enum Type {
  checkpoint,
  line,
}

class Step {
  Step({
    this.type,
    this.hour,
    this.message,
    this.duration,
    this.color,
    this.icon,
  });

  final Type type;
  final String hour;
  final String message;
  final int duration;
  final Color color;
  final IconData icon;

  bool get isCheckpoint => type == Type.checkpoint;

  bool get hasHour => hour != null && hour.isNotEmpty;
}