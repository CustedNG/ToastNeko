import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';
import 'package:cat_gallery/widget/input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _isBusy = false;
  final _userStore = locator<UserStore>();

  @override
  void dispose(){
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
  }

  Future<void> tryLogin() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    final username = _usernameController.value.text;
    final password = _passwordController.value.text;

    try {
      await Request().go(
          'post',
          Strs.userLogin,
          data: {
            Strs.keyUserAccount: username,
            Strs.keyUserPwd: password
          },
          success: (body){
            _userStore.username.put(username);
            _userStore.password.put(password);
            Provider.of<UserProvider>(context).login();
            Map<String, dynamic> jsonData = json.decode(body);
            _userStore.openId.put(jsonData[Strs.keyUserId]);
            _userStore.nick.put(jsonData[Strs.keyUserName]);
            Navigator.of(context).pop();
          },
          failed: (code) => print(code)
      );
    } catch (e) {
      rethrow;
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void focusOnPasswordField() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  void autoFillText(){
    _usernameController.text = _userStore.username.fetch();
    _passwordController.text = _userStore.password.fetch();
  }

  @override
  void initState() {
    super.initState();
    autoFillText();
    Future.delayed(Duration(microseconds: 377), () => showToast(
        context,
        Strs.loginToast,
        true
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildLoginForm(context),
      backgroundColor: Colors.teal,
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              SizedBox(height: 47),
              _title(),
              SizedBox(height: 77),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                style: TextStyle(color: Colors.white),
                decoration: buildDecoration('一卡通号'),
                onSubmitted: (_) => focusOnPasswordField(),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                style: TextStyle(color: Colors.white),
                obscureText: true,
                decoration: buildDecoration('统一认证密码'),
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
                          child: _isBusy
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
    return ElasticInRight(
      child: Column(
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
              fontSize: 60,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}