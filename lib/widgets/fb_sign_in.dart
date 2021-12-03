import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'custom_webview.dart';

class FBSignInWidget extends StatefulWidget {
  final Function onRegistration;
  FBSignInWidget(
    this.onRegistration,
  );
  @override
  _FBSignInWidgetState createState() => _FBSignInWidgetState();
}

class _FBSignInWidgetState extends State<FBSignInWidget> {
  bool _isLoading = false;
  String clientId = '968828860232963';
  String redirectUrl = "https://www.facebook.com/connect/login_success.html";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  Future init() async {
    await firebaseAuth.signOut();
  }

  Future signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomWebView(
                  selectedUrl:
                      'https://www.facebook.com/dialog/oauth?client_id=$clientId&redirect_uri=$redirectUrl&response_type=token&scope=email,public_profile,',
                ),
            maintainState: true),
      );
      if (result != null) {
        final facebookAuthCred =
            FacebookAuthProvider.getCredential(accessToken: result);
        final user = await firebaseAuth.signInWithCredential(facebookAuthCred);
        widget.onRegistration(user);
      }
    } catch (error) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        signIn();
      },
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
        side: BorderSide.none,
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF4267B2),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: _isLoading
              ? LoadingWidget()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Ionicons.logo_facebook,
                      color: ConfigCustom.colorWhite,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
