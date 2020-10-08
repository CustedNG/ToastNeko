import 'package:cat_gallery/utils.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MapPage extends StatefulWidget {
  final int index;
  final String heroTag;
  final PageController controller;

  MapPage({Key key, this.controller, this.heroTag, this.index})
      : super(key: key);

  @override
  _PhotoViewGalleryScreenState createState() => _PhotoViewGalleryScreenState();
}

class _PhotoViewGalleryScreenState extends State<MapPage> {
  int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: !isDarkMode(context)
                          ? [
                        AssetImage('assets/map/CustE.png'),
                        AssetImage('assets/map/CustW.png'),
                        AssetImage('assets/map/CustS.png'),
                      ][index]
                          : [
                        AssetImage('assets/map/Dark-CustE.png'),
                        AssetImage('assets/map/Dark-CustW.png'),
                        AssetImage('assets/map/Dark-CustS.png'),
                      ][index],
                      maxScale: 3.0,
                      minScale: PhotoViewComputedScale.contained
                    );
                  },
                  itemCount: 3,
                  backgroundDecoration: null,
                  pageController: widget.controller,
                  enableRotation: true,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                )),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text('${currentIndex + 1}/3',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          Positioned(
            right: 10,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
