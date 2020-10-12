import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

class MyImage extends StatelessWidget{
  final imgUrl;
  final index;

  const MyImage({Key key, this.imgUrl, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TransitionToImage(
      image: AdvancedNetworkImage(
        imgUrl,
        loadedCallback: () => print('Successfully loaded $imgUrl'),
        loadFailedCallback: () => print('Failed to load $imgUrl'),
        useDiskCache: true,
        cacheRule: CacheRule(maxAge: Duration(days: 15)),
      ),
      loadingWidgetBuilder: (_, double progress, __) {
        return Center(child: CircularProgressIndicator());
      },
      fit: BoxFit.cover,
      placeholder: const Icon(Icons.refresh),
      duration: Duration(milliseconds: 777),
      enableRefresh: true,
    );
  }

}