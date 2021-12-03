import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInWidget extends StatefulWidget {
  final Function onRegistration;
  AppleSignInWidget(
    this.onRegistration,
  );

  @override
  _AppleSignInWidgetState createState() => _AppleSignInWidgetState();
}

class _AppleSignInWidgetState extends State<AppleSignInWidget> {
  bool _isLoading = false;

  // GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: <String>[
  //     'email',
  //   ],
  // );
  // Future _signInGoogle() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   if (await _googleSignIn.isSignedIn()) {
  //     await _googleSignIn.signOut();
  //   }
  //   await _googleSignIn.signIn();
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  // Future init() async {
  //   _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
  //     widget.onRegistration(account.email);
  //   });
  // }

  Future signInWithApple() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      widget.onRegistration(credential.authorizationCode);
    } catch (error) {
      Functions.confirmOkModel(
          context, 'Apple Sign In is not supported in this device', () {});
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    //init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () async {
        signInWithApple();
      },
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
        side: BorderSide.none,
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF7D7D7D),
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
                      Ionicons.logo_apple,
                      color: ConfigCustom.colorWhite,
                      size: 32,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
