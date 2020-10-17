import 'dart:convert';
import 'dart:io';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/page/login.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

bool isDarkMode(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> initCatData([String nekoId]) async {
  Map<String, dynamic> jsonData;
  final catStore = CatStore();
  await catStore.init();
  await Request().go(
      'get',
      Strs.publicGetAllCats,
      success: (value) async {
        jsonData = json.decode(value);
        catStore.allCats.put(json.encode(jsonData));
      },
      failed: (code) => print(code)
  );
}

Future<void> initSpecificCatData(String nekoId, CatStore catStore) async {
  await Request().go(
      'get',
      Strs.publicGetCatDetail,
      data: {'neko_id': nekoId},
      success: (value) async {
        catStore.put(nekoId, value);
      },
      failed: (code) => print(code)
  );
}

void showSnackBar(BuildContext context, String content){
  Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
      )
  );
}

Future<void> checkVersion(BuildContext context) async {
  await Request().go(
      'get',
      Strs.publicGetVersion,
      success: (data){
        Map<String, dynamic> jsonData = json.decode(data);
        int version = int.parse(jsonData['version']);
        if(version > Strs.versionCode){
          showRoundDialog(
              context,
              '检测到更新',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('最新版本：$version'),
                  Text(jsonData['info'] ?? '暂无更新日志'),
                  SizedBox(height: 20),
                  Text('是否更新？')
                ],
              ),
              [
                FlatButton(
                    onPressed: () => launchURL(Platform.isAndroid
                        ? jsonData['android']
                        : jsonData['ios']
                    ),
                    child: Text('好👌')
                ),
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('不❌')
                )
              ]
          );
          print('Update version:$version available');
        }
      }
  );
}

Future<void> getUserMsg(BuildContext context) async {
  final user = Provider.of<UserProvider>(context);
  user.loggedIn ? await Request().go(
    'get',
    Strs.userGetMsg,
    data: {
      Strs.keyUserId : user.openId
    },
    success: (data){
      user.setMsg(data);
    },
    failed: (code) => showWrongToast(context, code)
  ) : print('还未登录');
}

void unawaited(Future<void> future) {}

void showToast(BuildContext context, String content, bool isLong) =>
  Toast.show(
      content,
      context,
      duration: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: Toast.BOTTOM);

void showWrongToast(BuildContext context, String msg) =>
  showToast(context, msg, true);

bool isInputNotRubbish(List<TextEditingController> controllers, [int max, int min]){
  for(var controller in controllers){
    if(controller.text.length < (min ?? 2) || controller.text.length > (max ?? 10))
      return false;
  }
  return true;
}

void showRoundDialog(BuildContext context, String title, Widget child, List<Widget> actions){
  showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          shape: RoundShape().build(),
          content: child,
          actions: actions,
        );
      }
  );
}

void showShouldLoginDialog(BuildContext context){
  showRoundDialog(
      context, '提示', Text('需要先登录才能继续'),
      [
        FlatButton(
            onPressed: () => AppRoute(LoginPage()).go(context),
            child: Text('好')
        ),
        FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消')
        )
      ]
  );
}

void showWrongDialog(BuildContext context, String wrongMsg){
  showDialog(
      context: context,
      builder: (ctx){
        return AlertDialog(
          shape: RoundShape().build(),
          content: Text(wrongMsg),
          actions: [
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('确定')
            )
          ],
        );
      }
  );
}

String nowDIYTime(){
  final dateTime = DateTime.now();
  return '${dateTime.year}-${dateTime.month}-${dateTime.day} '
      '${dateTime.hour}:${dateTime.minute}';
}

dynamic kv(dynamic dict, String key, [dynamic defaultValue = '']) =>
    dict[key] ?? defaultValue;