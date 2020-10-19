import 'dart:io';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PhotoPage extends StatelessWidget{
  final String url;
  final int index;
  final Cat cat;
  final List<String> commentList;

  PhotoPage({Key key, this.url, this.index, this.cat, this.commentList}) : super(key: key);

  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        body: _buildBody(context),
        collapsed: _buildContainer(context, _buildCollapsed(context)),
        panel: _buildContainer(context, _buildPanel(context)),
        minHeight: 107,
        maxHeight: 337,
        boxShadow: [
          const BoxShadow(
            blurRadius: 48.0,
            color: Colors.black38,
          )
        ],
        borderRadius: buildBorderRadius(26),
      )
    );
  }

  BorderRadius buildBorderRadius(double radius){
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
  }

  Widget _buildContainer(BuildContext context, Widget child){
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: buildBorderRadius(24)
        ),
        child: child
    );
  }

  Widget _buildPanel(BuildContext context){
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemCount: commentList.length + 1,
      itemBuilder: (ctx, index){
        final comment = commentList[index > 0 ? index - 1 : 0].split('\n');
        final username = comment[0].split('：');
        return index != 0 ? Padding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(comment[0]),
                  Text(comment[1]),
                ],
              ),
              SizedBox(height: 17),
              ExpandChild(
                arrowSize: 23,
                expandedHint: '收起',
                collapsedHint: '展开',
                expandArrowStyle: ExpandArrowStyle.both,
                arrowPadding: EdgeInsets.only(top: 7),
                child: _buildTextField(context, false, '回复${username[0]}:', icon: Icon(Icons.add_comment)),
              )
            ],
          ),
          padding: EdgeInsets.fromLTRB(17, 7, 17, 0),
        ) : Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 17),
            child: Icon(Icons.keyboard_arrow_down)
        );
      },
      separatorBuilder: (ctx, index) => Divider(),
    );
  }

  Widget _buildCollapsed(BuildContext context){
    final isAndroid = Platform.isAndroid;
    return Padding(
      child: Column(
        children: [
          Icon(Icons.keyboard_arrow_up),
          SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: _buildTextField(context, true, '想说点什么？', icon: Icon(Icons.chat)),
              ),
              isAndroid ? IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                  onPressed: () => tryComment(context, textEditingController.value.text)
              ) : Container()
            ],
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(17, 0, isAndroid ? 2 : 17, 7),
    );
  }

  Widget _buildTextField(BuildContext context, bool isComment, String hint, {Icon icon}){
    return Padding(
      padding: EdgeInsets.all(2),
      child: TextField(
        onSubmitted: (str) => isComment ? tryComment(context, str) : null,
        textInputAction: TextInputAction.send,
        maxLines: 2,
        minLines: 1,
        controller: textEditingController,
        decoration: buildRoundDecoration(
            hint,
            icon
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context){
    return Stack(
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
          onTap: () => closeKeyboard(),
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
        StatusBarOverlay()
      ],
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
        textEditingController.clear();
        closeKeyboard();
      },
      failed: (code) => showWrongToast(context, code)
    );
  }
}