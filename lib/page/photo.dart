import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class PhotoPage extends StatelessWidget{
  final String url;
  final int index;
  final Cat cat;
  final List<String> commentList;

  PhotoPage({Key key, this.url, this.index, this.cat, this.commentList}) : super(key: key);

  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isAndroid = Platform.isAndroid;
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            child: PhotoView(
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor
              ),
              maxScale: 3.0,
              minScale: PhotoViewComputedScale.contained,
              imageProvider: AdvancedNetworkImage(
                url,
                loadedCallback: () => print('Successfully loaded $url'),
                loadFailedCallback: () => print('Failed to load $url'),
                useDiskCache: true,
                cacheRule: CacheRule(maxAge: Duration(days: 30)),
              ),
              heroAttributes: PhotoViewHeroAttributes(
                  tag: index == 0 ? cat : index.hashCode,
                  transitionOnUserGestures: true
              ),
            ),
            onTap: (){
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
          ),
          Positioned(
              top: 10,
              left: 10,
              child: SafeArea(
                child: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop()
                )
              )
          ),
          Positioned(
            child: BlurryContainer(
              width: size.width,
              height: 137,
              blur: 10,
              borderRadius: BorderRadius.zero,
              padding: EdgeInsets.only(left: 17, top: 7,right: isAndroid ? 2 : 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeAnimatedTextKit(
                    text: commentList.isEmpty ? ['暂无评论\n赶紧评论吧'] : commentList,
                    repeatForever: commentList.isNotEmpty,
                    textAlign: TextAlign.center,
                    pause: Duration(milliseconds: 1000),
                  ),
                  SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextField(
                          onSubmitted: (str) => tryComment(context, str),
                          textInputAction: TextInputAction.send,
                          maxLines: 2,
                          minLines: 1,
                          controller: textEditingController,
                          decoration: buildRoundDecoration(
                              '想说点什么？',
                              Icon(Icons.chat)
                          ),
                        ),
                      ),
                      isAndroid ? IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () => tryComment(context, textEditingController.value.text)
                      ) : Container()
                    ],
                  )
                ],
              )
            ),
            bottom: 0,
          ),
          StatusBarOverlay()
        ],
      )
    );
  }

  void tryComment(BuildContext context, String str) async {
    final userProvider = locator<UserStore>();
    if(!userProvider.loggedIn.fetch()){
      showShouldLoginDialog(context);
      return;
    }

    final lastTime = userProvider.lastCommentTime.fetch();
    final nowTime = DateTime.now();
    if(lastTime != null){
      if(nowTime.difference(DateTime.parse(lastTime)).inSeconds < 30){
        showWrongDialog(context, '每次上报评论间隔不小于三十秒');
        return;
      }
    }

    await Request().go(
      'post',
      Strs.userComment,
      data: {
        Strs.keyCommentContent: {
          Strs.keyUserInfo: {
            Strs.keyUserId: userProvider.openId.fetch(),
          },
          Strs.keyCommentContent: str,
          Strs.keyCreateTime: nowDIYTime(),
          Strs.keyFileName : cat.img[index]
        },
        Strs.keyCommentPosition: {
          "is_comment": true,
          Strs.keyCatId: cat.id,
        }
      },
      success: (body) async {
        showToast(context, '评论成功', false);
        Provider.of<CatProvider>(context).updateData(cat.id);
        final userData = await locator.getAsync<UserStore>();
        userData.lastCommentTime.put(nowTime.toString());
      },
      failed: (code) => showWrongToast(context, code)
    );
  }
}