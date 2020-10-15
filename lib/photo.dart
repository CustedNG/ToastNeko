import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:cat_gallery/model/comment.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class PhotoPage extends StatelessWidget{
  final String url;
  final int index;
  final Cat cat;
  final List<Comment> commentData;

  PhotoPage({Key key, this.url, this.index, this.cat, this.commentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              imageProvider: CachedNetworkImageProvider(url),
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
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop()
                )
              )
          ),
          Positioned(
            child: BlurryContainer(
              width: size.width,
              height: 97,
              blur: 10,
              borderRadius: BorderRadius.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onSubmitted: (str) => tryComment(context, str),
                    textInputAction: TextInputAction.go,
                    maxLines: 2,
                    minLines: 1,
                    decoration: buildRoundDecoration(
                        '想说点什么？',
                        Icon(Icons.chat)
                    ),
                  ),
                ],
              )
            ),
            bottom: 0,
          )
        ],
      )
    );
  }
  
  void tryComment(BuildContext context, String str) async {
    if(!Provider.of<UserProvider>(context).loggedIn){
      showShouldLoginDialog(context);
      return;
    }

    final _user = Provider.of<UserProvider>(context);
    await Request().go(
      'post',
      Strs.userComment,
      data: {
        Strs.keyCommentContent: {
          Strs.keyUserInfo: {
            Strs.keyUserId: _user.openId,
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
      success: (body){
        showToast(context, '评论成功', false);
        Provider.of<CatProvider>(context).loadLocalData();
      },
      failed: (code) => showWrongToast(context, code)
    );
  }
}