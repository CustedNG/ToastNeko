import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatelessWidget{
  final String url;
  final int index;
  final Cat cat;

  PhotoPage({Key key, this.url, this.index, this.cat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
          child: PhotoView(
            maxScale: 3.0,
            minScale: PhotoViewComputedScale.contained,
            imageProvider: CachedNetworkImageProvider(url),
            heroAttributes: PhotoViewHeroAttributes(
                tag: index == 0 ? cat : index.hashCode
            ),
          ),
          onTap: () => Navigator.pop(context),
        )
    );
  }
}