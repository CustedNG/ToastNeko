import 'dart:convert';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/store/user_store.dart';
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

    final username = usernameController.value.text;
    final password = passwordController.value.text;

    try {
      await Request().go(
          'post',
          Strs.userLogin,
          data: {
            'cid': username,
            'pwd': password
          },
          success: (body) async {
            print(body);
            final userStore = UserStore();
            await userStore.init();
            userStore.username.put(username);
            userStore.password.put(password);
            Map<String, dynamic> jsonData = json.decode(body);
            userStore.openId.put(jsonData[Strs.keyUserId]);
            Navigator.of(context).pop();
          },
          failed: (code) => print(code)
      );
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
      body: _buildLoginForm(context),
      backgroundColor: Colors.teal,
    );
  }

  InputDecoration _buildDecoration(String label, TextStyle textStyle){
    return InputDecoration(
        labelText: label,
        labelStyle: textStyle,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.lightBlueAccent
            )
        )
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
            fontSize: 60,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}