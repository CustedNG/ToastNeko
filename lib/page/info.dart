import 'package:cat_gallery/data/all_str.dart';
import 'package:cat_gallery/model/cat.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget{
  final Cat cat;

  const InfoPage({Key key, this.cat}) : super(key: key);

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
            SizedBox(height: 3),
            Text(cat.sex, style: content),
            SizedBox(height: 20),
            Text('地区', style: title),
            SizedBox(height: 3),
            Text(cat.position, style: content),
            SizedBox(height: 20),
            Text('胆小程度', style: title),
            SizedBox(height: 3),
            Text(''.padLeft(cat.coward, '⭐️'), style: content),
            SizedBox(height: 20),
            Text('出没概率', style: title),
            SizedBox(height: 3),
            Text(''.padLeft(cat.haunt, '⭐'), style: content),
            SizedBox(height: 20),
            Text('描述', style: title),
            SizedBox(height: 3),
            Text(cat.description, style: content),
            SizedBox(height: 20),
            Text('状态', style: title),
            SizedBox(height: 3),
            Text(
                Strs.diedCats.contains(cat.displayName) ? '去世' : '存活',
                style: content
            ),
          ],
        ),
      )
    );
  }
}