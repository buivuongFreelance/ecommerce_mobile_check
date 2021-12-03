import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInWidget extends StatefulWidget {
  final Function onRegistration;
  GoogleSignInWidget(
    this.onRegistration,
  );

  @override
  _GoogleSignInWidgetState createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {
  bool _isLoading = false;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );
  Future _signInGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _googleSignIn.signIn();
    } catch (error) {}

    setState(() {
      _isLoading = false;
    });
  }

  Future init() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      widget.onRegistration(account.email);
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        _signInGoogle();
      },
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ConfigCustom.borderRadius),
        side: BorderSide.none,
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFDB3236),
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
                      Ionicons.logo_googleplus,
                      color: ConfigCustom.colorWhite,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
