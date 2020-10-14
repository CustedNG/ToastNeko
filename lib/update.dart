import 'dart:io';

import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/round_btn.dart';
import 'package:flutter/material.dart';

class UpdatePage extends StatelessWidget{
  final version;
  final android;
  final ios;

  const UpdatePage({Key key, this.version, this.android, this.ios}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更新'),
        centerTitle: true,
      ),
      body: Center(
        child: RoundBtn(
            '下载更新',
            Colors.cyan,
                () =>launchURL(Platform.isAndroid ? android : ios)
        ),
      ),
    );
  }
}