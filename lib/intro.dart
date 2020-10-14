import 'package:cat_gallery/model/cat.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget{
  final Cat cat;

  const IntroPage({Key key, this.cat}) : super(key: key);

  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 23
  );

  static const TextStyle content = TextStyle(
      fontSize: 17
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${cat.displayName}的简介'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('性别', style: title),
            SizedBox(height: 7),
            Text(cat.sex, style: content),
            SizedBox(height: 20),
            Text('胆小程度', style: title),
            SizedBox(height: 7),
            Text('', style: content),
            SizedBox(height: 20),
            Text('出没概率', style: title),
            SizedBox(height: 7),
            Text('', style: content),
            SizedBox(height: 20),
            Text('描述', style: title),
            SizedBox(height: 7),
            Text(cat.description, style: content),
          ],
        ),
      )
    );
  }
}