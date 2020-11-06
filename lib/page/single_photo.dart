import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SinglePhotoPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('兑换带'),
        centerTitle: true,
      ),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor
        ),
        maxScale: 3.0,
        minScale: PhotoViewComputedScale.contained,
        imageProvider: AssetImage('assets/prize_ribbon.png'),
      ),
    );
  }

}