import 'package:cat_gallery/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';

class CustCompusMap {
  const CustCompusMap({
    this.minScale,
    this.maxScale,
    this.initScale,
    this.image,
    this.darkImage,
  });

  final double minScale;
  final double maxScale;
  final double initScale;
  final ImageProvider image;
  final ImageProvider darkImage;
}

class PhotoViewMap extends StatelessWidget {
  PhotoViewMap(this.name, this.map, this.position, this.offset);

  static const flagSize = 5.0;
  final String name;
  final CustCompusMap map;
  final Offset position;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    // final isDark = isDark(context);
    return ZoomableWidget(
      initialOffset: offset,
      initialScale: map.initScale,
      minScale: map.minScale,
      maxScale: map.maxScale,
      child: Container(
        child: Stack(
          children: <Widget>[
            TransitionToImage(
              image: isDarkMode(context) ? map.darkImage : map.image,
              // placeholder: CircularProgressIndicator(),
              placeholder: Container(),
              duration: Duration(milliseconds: 300),
            ),
            Positioned(
              top: position.dy,
              left: position.dx,
              child: Icon(
                Icons.flag,
                size: flagSize,
                color: Colors.lightBlueAccent,
              ),
            ),
          ],
        ),
      ),
    );

    // return PhotoView(
    //   basePosition: Alignment.topCenter,
    //   controller: PhotoViewController(
    //     initialPosition: Offset(offsetX ?? 0, offsetY ?? 0),
    //   ),
    //   backgroundDecoration: BoxDecoration(
    //     color: Color(0xFFF5F5F5),
    //   ),
    //   minScale: 0.1,
    //   maxScale: 1.0,
    //   initialScale: scale,
    //   imageProvider: img,
    // );
  }
}

class Maps {
  static const custW = CustCompusMap(
    minScale: 4,
    maxScale: 7,
    initScale: 6,
    image: AssetImage('assets/map/CustW.png'),
    darkImage: AssetImage('assets/map/Dark-CustW.png'),
  );

  static const custE = CustCompusMap(
    minScale: 4,
    maxScale: 7,
    initScale: 5,
    image: AssetImage('assets/map/CustE.png'),
    darkImage: AssetImage('assets/map/Dark-CustE.png'),
  );

  static const custS = CustCompusMap(
    minScale: 4,
    maxScale: 7,
    initScale: 6,
    image: AssetImage('assets/map/CustS.png'),
    darkImage: AssetImage('assets/map/Dark-CustS.png'),
  );

  /// @dx positive = right
  /// @dy positive = down
  static PhotoViewMap makeMap(String name, CustCompusMap map, double dx,
      double dy) {
    return PhotoViewMap(
      name,
      map,
      Offset(dx, dy),
      Offset(-dx + 57, -dy + 80),
    );
  }

  static Widget search(String name) {
    final List<PhotoViewMap> _maps = [
      PhotoViewMap(
        '东区体育馆',
        custE,
        Offset(37, 97),
        Offset(17, -15),
      ),
      PhotoViewMap(
        '东区操场',
        custE,
        Offset(27, 97),
        Offset(23, -15),
      ),
      PhotoViewMap(
        '东区学子亭',
        custE,
        Offset(32, 42),
        Offset(17, 37),
      ),
    ];

    for (final map in _maps) {
      if (name.contains(map.name)) {
        return map;
      }
    }
    return null;
  }

  static Widget get defaultMap =>
      PhotoViewMap('默认', custE, Offset.zero, Offset.zero);
}
