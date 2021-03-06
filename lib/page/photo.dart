import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/all_str.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/model/comment.dart';
import 'package:cat_gallery/model/error.dart';
import 'package:cat_gallery/model/reply.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/custom_image.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:cat_gallery/widget/status_bar_overlay.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PhotoPage extends StatefulWidget{
  final String url;
  final int index;
  final Cat cat;
  final List<Comment> commentList;
  final List<Reply> replyList;

  PhotoPage({Key key, this.url, this.index, this.cat, this.commentList, this.replyList}) : super(key: key);

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final TextEditingController textEditingController = TextEditingController();
  final PanelController panelController = PanelController();
  final boxShadow = BoxShadow(blurRadius: 48.0, color: Colors.black38);
  bool isPanelOpen = false;
  String commentId;
  String replyWho;
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: panelController,
        body: _buildBody(context),
        collapsed: ElasticInRight(child: _buildContainer(context, _buildCollapsed(context))),
        panel: _buildContainer(context, _buildPanel(context)),
        minHeight: 107,
        maxHeight: 337,
        onPanelOpened: () => setState(() => isPanelOpen = true),
        onPanelClosed: () => setState(() => isPanelOpen = false),
        boxShadow: [boxShadow],
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 17, bottom: 17),
          child: Icon(Icons.keyboard_arrow_down),
        ),
        SizedBox(
          height: 279,
          width: MediaQuery.of(context).size.width,
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            itemCount: widget.commentList.length,
            itemBuilder: (ctx, index){
              return _buildCommentItem(index);
            },
            separatorBuilder: (ctx, index) => Divider(),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(int index){
    final fontSize = Theme.of(context).textTheme.bodyText2.fontSize;
    final comment = widget.commentList[index];
    final List<Reply> replyList = [];
    widget.replyList.forEach((ele) =>
        ele.commentId == comment.commentId ? replyList.add(
            Reply(
                comment.commentId,
                ele.replyId,
                ele.content,
                ele.openId,
                ele.nick,
                ele.createTime
            )
        ) : null
    );
    final replyLength = replyList.length;
    final commentNameWidth = comment.nick.length * fontSize / 2;
    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(comment.nick + ': ' + comment.content, overflow: TextOverflow.fade),
              FlatButton(
                onPressed: (){
                  setState((){
                    commentId = comment.commentId;
                    replyWho = comment.nick;
                  });
                  panelController.close();
                  Future.delayed(Duration(milliseconds: 577), () => FocusScope.of(context).requestFocus(focusNode));
                },
                onLongPress: () => tryDelComment(comment.commentId, true),
                child: Text('回复'),
                padding: EdgeInsets.all(1),
                minWidth: 37,
              )
            ],
          ),
          replyLength == 0 ? Container() : ExpandChild(
            arrowSize: 23,
            expandedHint: '收起',
            collapsedHint: '展开',
            expandArrowStyle: ExpandArrowStyle.both,
            arrowPadding: EdgeInsets.zero,
            child: Row(
              children: [
                SizedBox(width: commentNameWidth),
                SizedBox(
                  height: fontSize * replyLength * 1.35,
                  width: MediaQuery.of(context).size.width - commentNameWidth - 74,
                  child: ListView.builder(
                    itemCount: replyLength,
                    itemBuilder: (ctx, index){
                      return Text(buildReplyString(replyList[index], ': '));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(37, 0, 37, 0),
    );
  }

  Widget _buildCollapsed(BuildContext context){
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
                child: _buildTextField(
                    context,
                    true,
                    commentId == null ? '想说点什么？' : '回复$replyWho',
                    icon: commentId == null ? Icon(Icons.chat) : Icon(Icons.reply)
                ),
              ),
              Platform.isAndroid ? IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                  padding: EdgeInsets.zero,
                  onPressed: () => tryComment(context, textEditingController.value.text)
              ) : Container()
            ],
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(17, 1, 17, 7),
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
        enabled: isPanelOpen ? false : true,
        focusNode: focusNode,
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
            imageProvider: MyImage(imgUrl: widget.url).buildProvider(context),
            heroAttributes: PhotoViewHeroAttributes(
                tag: widget.index == 0 ? widget.cat : widget.index.hashCode,
                transitionOnUserGestures: true
            ),
          ),
          onTap: () => closeKeyboardPanel(),
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

  void closeKeyboardPanel(){
    panelController.close();
    closeKeyboard();
  }

  void tryComment(BuildContext context, String str) async {
    final isComment = commentId == null;
    final userProvider = locator<UserStore>();
    if(!userProvider.loggedIn.fetch()){
      showShouldLoginDialog(context);
      return;
    }

    if(!isInputNotRubbish([textEditingController], 20, 1)){
      showWrongDialog(context, '字数不得小于1大于20');
      return;
    }

    final lastTime = userProvider.lastCommentTime.fetch();
    final nowTime = DateTime.now();
    if(lastTime != null){
      if(nowTime.difference(DateTime.parse(lastTime)).inSeconds < 30){
        showWrongDialog(context, '每次评论间隔不小于三十秒');
        return;
      }
    }

    try{
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
              Strs.keyFileName : widget.cat.img[widget.index]
            },
            Strs.keyCommentPosition: isComment ? {
              Strs.keyIsComment: true,
              Strs.keyCatId: widget.cat.id,
            } : {
              Strs.keyIsComment: false,
              Strs.keyCatId: widget.cat.id,
              Strs.keyCommentID: commentId,
              Strs.keyUserId: locator<UserStore>().openId.fetch()
            }
          },
          success: (body) async {
            showToast(context, isComment ? '评论成功' : '回复成功', false);
            Provider.of<CatProvider>(context).updateData(widget.cat.id);
            final userData = await locator.getAsync<UserStore>();
            final obj = isComment ? userData.lastCommentTime : userData.lastFeedbackTime;
            obj.put(nowTime.toString());
            textEditingController.clear();
            closeKeyboard();
          }
      );
    }catch(e){
      showWrongToastByCode(context, e.toString(), commentError);
    }
  }

  void tryDelComment(String commentId, bool isComment) {
    //TODO: 需在此处鉴权，如果是此操作是评论发布本人或管理员，才可使用本接口
    print(this.commentId);
  }
}
