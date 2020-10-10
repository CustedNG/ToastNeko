import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFocusNode = FocusNode();
  bool isBusy = false;

  Future<void> tryLogin() async {
    if (isBusy) return;

    setState(() => isBusy = true);

    try {
    } catch (e) {
      rethrow;
    } finally {
      setState(() => isBusy = false);
    }
  }

  void focusOnPasswordField() {
    FocusScope.of(context).requestFocus(passwordFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _buildLoginForm(context)
    );
  }

  InputDecoration _buildDecoration(String label, TextStyle textStyle){
    return InputDecoration(
        labelText: label,
        labelStyle: textStyle,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.cyan
            )
        )
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return ListView(
      // mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.all(0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
              SizedBox(height: 47),
              _title(),
              SizedBox(height: 77),
              TextField(
                controller: usernameController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: _buildDecoration('一卡通号', TextStyle(color: Color(0x55FFFFFF))),
                onSubmitted: (_) => focusOnPasswordField(),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                style: TextStyle(color: Colors.white),
                obscureText: true,
                decoration: _buildDecoration('统一认证密码', TextStyle(color: Color(0x55FFFFFF))),
                onSubmitted: (_) => tryLogin(),
              ),
              SizedBox(height: 90),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '登录',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 80,
                      maxHeight: 80,
                    ),
                    child: GestureDetector(
                      onTap: tryLogin,
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: Center(
                          child: isBusy
                              ? CircularProgressIndicator()
                              : Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        )
      ],
    );
  }

  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 60,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Toast Neko',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 60,
          ),
        )
      ],
    );
  }
}