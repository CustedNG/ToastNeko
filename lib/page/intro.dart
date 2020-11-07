import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class IntroScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();

    slides.add(
      Slide(
        title: '登录',
        description: '关于界面点击底部即可登录，评论、反馈等功能登录后方可操作',
        pathImage: 'assets/intro/login.jpg',
        backgroundColor: Colors.cyan,
      ),
    );
    slides.add(
      Slide(
        title: '评论',
        description: '点击任意图片，在底部输入想要评论的内容，再点击发送即可',
        pathImage: 'assets/intro/comment.jpg',
        backgroundColor: Colors.pinkAccent,
      ),
    );
    slides.add(
      Slide(
        title: '反馈猫猫踪迹',
        description: '进入踪迹页后，点击右下角按钮，输入信息点击发送即可',
        pathImage: 'assets/intro/feedback.jpg',
        backgroundColor: Colors.purple,
      ),
    );
  }

  void onDonePress() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Color btnColor = Colors.white24;
    double btnBorderRadius = 20;
    return IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onDonePress,
      borderRadiusDoneBtn: btnBorderRadius,
      borderRadiusPrevBtn: btnBorderRadius,
      borderRadiusSkipBtn: btnBorderRadius,
      colorDoneBtn: btnColor,
      colorPrevBtn: btnColor,
      colorSkipBtn: btnColor,
      nameSkipBtn: '跳过',
      nameDoneBtn: '完成',
      nameNextBtn: '继续',
      namePrevBtn: '返回',
      colorActiveDot: Colors.white70,
      colorDot: Colors.white24,
    );
  }
}