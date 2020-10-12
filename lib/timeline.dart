import 'dart:convert';
import 'dart:math';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:flutter/material.dart';
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
  bool isBusy;
  bool isUploading = false;
  final textFieldController = TextEditingController();
  final textFieldController2 = TextEditingController();
  List<Color> colorList = [
    Colors.cyan,
    Colors.pinkAccent,
    Colors.yellow,
    Colors.lightGreen,
    Colors.tealAccent,
    Colors.purple,
    Colors.brown,
    Colors.indigo
  ];
  List<IconData> iconList = [
    Icons.architecture,
    Icons.search,
    Icons.flag,
    Icons.navigation,
    Icons.local_library,
    Icons.home
  ];

  @override
  void initState() {
    isBusy = true;
    initData();
    super.initState();
  }

  void initData() async{
    _steps = [];
    final catStore = CatStore();
    await catStore.init();
    Map<String, dynamic> jsonData = json.decode(catStore.fetch(widget.catId));
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
              message: //position['nick'] + '发现' +
                   widget.catName +
                  '在' + position['msg'],
              color: colorList[Random().nextInt(7)],
          )
      );
    }
    setState(() {
      isBusy = false;
    });
  }

  InputDecoration _buildDecoration(String label){
    return InputDecoration(
        labelText: label,
    );
  }

  String nowTime(){
    final dateTime = DateTime.now();
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} '
        '${dateTime.hour}:${dateTime.minute}';
  }
  
  void tryUpload() async{
    if(isUploading)return;
    isUploading = true;
    setState(() {});

    final user = UserStore();
    await user.init();
    await Request().go(
        'put',
        Strs.publicManagePosition,
        data: {
          "neko_id": widget.catId,
          "position": {
            "location": textFieldController.value.text,
            "time": nowTime(),
            "duration": 0,
            "msg": textFieldController2.value.text,
            "open_id": user.openId.fetch()
          }
        },
        success: (body) async {
          await initCatData();
          setState(() {
            initData();
            isUploading = false;
            Navigator.of(context).pop();
          });
        },
        failed: (code) => print(code)
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
          child: isBusy
              ? CircularProgressIndicator()
              : _TimelineActivity(steps: _steps),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx){
              return AlertDialog(
                shape: RoundShape().build(),
                title: Text('我发现了${widget.catName}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textFieldController,
                      decoration: _buildDecoration('${widget.catName}在哪里'),
                    ),
                    TextField(
                      controller: textFieldController2,
                      decoration: _buildDecoration('${widget.catName}在干什么'),
                    ),
                  ],
                ),
                actions: [
                  FlatButton(
                      onPressed: (){
                        setState(() {});
                        tryUpload();
                      },
                      child: isUploading
                          ? CircularProgressIndicator()
                          : Text('提交${widget.catName}行踪')
                  )
                ],
              );
            }
          );
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