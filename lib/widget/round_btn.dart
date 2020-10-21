import 'package:flutter/material.dart';

class RoundBtn extends StatelessWidget{
  final btnName;
  final btnColor;
  final onTap;

  const RoundBtn(this.btnName, this.btnColor, this.onTap);
  
  @override
  Widget build(BuildContext context) {
    return _logInOutBtn(context, btnName, btnColor, onTap);
  }
  
  Widget _logInOutBtn(BuildContext context, String btnName, Color color,
      GestureTapCallback onTap) {
    return Container(
      height: 37.0,
      child: Material(
        elevation: 10.0,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: FlatButton(
            child: Text(btnName),
            textColor: Colors.white,
            onPressed: onTap
        ),
      ),
    );
  }
}