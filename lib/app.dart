import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/page/home.dart';
import 'package:cat_gallery/page/info.dart';
import 'package:cat_gallery/model/navigation_item.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/round_shape.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }

    return MaterialApp(
        title: Strs.appName,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: AnimatedSplashScreen(
          splash: Card(
              elevation: 10.0,
              shape: RoundShape().build(),
              clipBehavior: Clip.antiAlias,
              semanticContainer: false,
              child: AspectRatio(
                aspectRatio: 25 / 11,
                child: Image.asset(
                    Strs.bannerToastNeko,
                    fit: BoxFit.cover),
              )
          ),
          nextScreen: MyHomePage(title: Strs.appName),
          duration: 1000,
          splashIconSize: 137,
          backgroundColor: Color.fromRGBO(243, 233, 198, 1),
          curve: Curves.easeInOutCubic,
          animationDuration: Duration(milliseconds: 777),
          splashTransition: SplashTransition.rotationTransition,
          pageTransitionType: PageTransitionType.fade,
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  List<NavigationItem> items = [
    NavigationItem(Icon(Icons.home), Text('主页'), Colors.cyanAccent),
    NavigationItem(Icon(Icons.settings), Text('关于'), Colors.pinkAccent)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: BouncingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectIndex = index),
        children: [
          HomePage(),
          InfoPage()
        ],
      ),
      bottomNavigationBar: _buildBottom(context),
    );
  }

  Widget _buildItem(NavigationItem item, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 377),
      curve: Curves.fastOutSlowIn,
      height: 50,
      width: isSelected ? 95 : 50,
      padding: isSelected ? EdgeInsets.only(left: 16, right: 16) : null,
      decoration: isSelected
          ? BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.all(Radius.circular(50)))
          : null,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconTheme(
                data: IconThemeData(
                    size: 24, color: isDarkMode(context) ? Colors.white : Colors.black),
                child: item.icon,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: isSelected
                    ? DefaultTextStyle.merge(
                    child: item.title,
                    style: TextStyle(
                        color: isDarkMode(context) ? Colors.white : Colors.black))
                    : null,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return SafeArea(
        child: BlurryContainer(
          blur: 27,
          borderRadius: BorderRadius.zero,
          height: 56,
          padding: EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 8),
          //decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              var itemIndex = items.indexOf(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectIndex = itemIndex;
                    _pageController.animateToPage(itemIndex,
                        duration: Duration(milliseconds: 377),
                        curve: Curves.easeInOutCubic);
                  });
                },
                child: _buildItem(item, _selectIndex == itemIndex),
              );
            }).toList(),
          ),
        )
    );
  }
}
