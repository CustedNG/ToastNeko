import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

class MyImage extends StatelessWidget{
  final imgUrl;

  const MyImage({Key key, this.imgUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TransitionToImage(
      image: buildProvider(context),
      loadingWidgetBuilder: (_, double progress, __) {
        return Center(child: CircularProgressIndicator());
      },
      fit: BoxFit.cover,
      placeholder: const Icon(Icons.refresh),
      duration: Duration(milliseconds: 777),
      enableRefresh: true,
    );
  }

  ImageProvider buildProvider(BuildContext context){
    return AdvancedNetworkImage(
      imgUrl,
      loadedCallback: () => print('Successfully loaded $imgUrl'),
      loadFailedCallback: () => print('Failed to load $imgUrl'),
      useDiskCache: true,
      cacheRule: CacheRule(maxAge: Duration(days: 15)),
    );
  }

}