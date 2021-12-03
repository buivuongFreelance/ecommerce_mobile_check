import 'dart:io' show Platform;

import 'package:dingtoimc/widgets/google_sign_in.dart';
import 'package:dingtoimc/widgets/apple_sign_in.dart';
import 'package:flutter/material.dart';

import 'fb_sign_in.dart';

class SocialLogin extends StatefulWidget {
  final Function onRegistrationGoogle;
  final Function onRegistrationFacebook;
  final Function onRegistrationApple;

  SocialLogin(
      {this.onRegistrationGoogle,
      this.onRegistrationFacebook,
      this.onRegistrationApple});

  @override
  _SocialLoginState createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GoogleSignInWidget(widget.onRegistrationGoogle),
        Platform.isIOS
            ? AppleSignInWidget(widget.onRegistrationApple)
            : Center(),
        FBSignInWidget(widget.onRegistrationFacebook),
      ],
    );
  }
}
