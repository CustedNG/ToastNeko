import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/all_str.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/model/comment.dart';
import 'package:cat_gallery/model/reply.dart';
import 'package:cat_gallery/page/login.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      }
  );
}

Future<void> initSpecificCatData(String nekoId, CatStore catStore) async {
  await Request().go(
      'get',
      Strs.publicGetCatDetail,
      data: {'neko_id': nekoId},
      success: (value) async {
        catStore.put(nekoId, value);
      }
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
    }
  ) : print('还未登录');
}

void autoUpdateUserMsg(BuildContext context){
  getUserMsg(context);
  Timer.periodic(Duration(seconds: 37), (_) => getUserMsg(context));
}

Future<void> clearUserMsg(BuildContext context) async {
  final user = Provider.of<UserProvider>(context);
  await Request().go(
    'delete',
    Strs.userClearNotification,
    data: {
      Strs.keyUserId: user.openId
    },
    success: (data) => user.clearMsg()
  );
}

Future<void> getPrizeInfo(BuildContext context) async {
  final user = locator<UserStore>();
  final userName = user.nick.fetch();
  if(user.loggedIn.fetch()){
    await Request().go(
        'get',
        Strs.getPrizeInfoUrl,
        success: (body){
          String data = body.toString();
          String date = data.substring(4, 14);
          if(user.prizeDate.fetch() != date){
            user.prizeDate.put(date);
            if(data.contains(userName)){
              showRoundDialog(
                  context,
                  '恭喜$userName',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('本次中奖名单:'),
                      Text(data),
                      Text('是否进群了解领取方式？')
                    ],
                  ),
                  [
                    FlatButton(
                        onPressed: () => launchURL(Strs.joinQQUrl),
                        child: Text('好👌')
                    ),
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('不❌')
                    )
                  ]
              );
            }
          }
        }
    );
  } else print('没有登陆，未获取中奖信息');
}

String getCatNameById(String catId, CatStore catStore){
  Map catMap = json.decode(catStore.allCats.fetch());
  for(var eachCat in catMap[Strs.keyCatList]){
    if(eachCat[Strs.keyCatId] == catId) return eachCat[Strs.keyCatName];
  }
  return '未知';
}

int getImgIndexById(String catId, String imgId, CatStore catStore){
  Map map = json.decode(catStore.fetch(catId));
  List<String> imgs = [];
  map[Strs.keyCatImg].forEach((url) => imgs.add(url));
  return imgs.indexOf(imgId);
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

void closeKeyboard() =>
    SystemChannels.textInput.invokeMethod('TextInput.hide');

String buildCommentString(Comment comment, String between) =>
    comment.nick + between + comment.content;

String buildReplyString(Reply reply, String between) =>
    reply.nick + between + reply.content;

void showWrongToastByCode(BuildContext context, String error, Map<String, String> errorDict){
  errorDict.forEach((code, prompt){
    if(error.contains(code))showWrongToast(context, prompt);
  });
}
