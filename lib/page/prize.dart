import 'dart:convert';

import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/page/single_photo.dart';
import 'package:cat_gallery/route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrizePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProvider _user = Provider.of<UserProvider>(context);

    if (_user.isBusy) return CircularProgressIndicator();

    return Scaffold(
        appBar: AppBar(
          title: Text('兑奖须知'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Column(
            children: [
              Text('你的兑奖码'),
              Text(
                  _user.loggedIn
                  ? base64Encode(utf8.encode(_user.openId.replaceFirst('2020', '0202')))
                  : '请先登录'
              ),
              SizedBox(height: 37),
              Text(
                  '如何获得:\n'
                      '我们分为线上和线下两种途径:\n'
                      '①在线上，你可以在 Toast Neko APP内参与抽奖，我们会定期开奖；\n'
                      '②在线下，我们已经在校园各处绑上了『Toast neko 兑粮带』，找到兑粮带并摘下，凭兑粮带领取猫粮\n\n'
                      '兑粮规则：\n'
                      '线上：获奖可得五份猫粮\n'
                      '线下：根据找到的兑粮带上“基础模板”的数量，一个“基础模板”对应一份猫粮，每个人兑粮时最多兑换两条带子\n\n'
                      '何时兑粮:\n'
                      '第一次兑粮在周三下午，具体兑粮时间和地方会定期在Neko中更新。请注意！每次的兑粮地点不一定一样呦，同学们记得查看Neko兑粮信息！\n'
              ),
              RichText(
                  text: TextSpan(
                      text: '查看图片:',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color
                      ),
                      children: [
                        TextSpan(
                          text: '『Toast neko 兑粮带』',
                          style: TextStyle(color: Colors.cyan),
                          recognizer: TapGestureRecognizer()..onTap=() =>
                              AppRoute(SinglePhotoPage()).go(context)
                        ),
                      ]
                  )
              )
            ],
          ),
        )
    );
  }
}
