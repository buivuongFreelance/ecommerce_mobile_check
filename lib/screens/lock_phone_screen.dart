import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/login_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/loading.dart';

class LockPhoneScreen extends StatefulWidget {
  static const routeName = '/lock-Phone';

  @override
  _LockPhoneScreenState createState() => _LockPhoneScreenState();
}

class _LockPhoneScreenState extends State<LockPhoneScreen> {
  bool isLoading = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    logout();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(ConfigCustom.authToken)) {
        setState(() {
          isLoading = true;
        });
        await User.logoutLocked(context);
        setState(() {
          isLoading = false;
        });
        Functions.goToRoute(context, WelcomeScreen.routeName);
      }
    } catch (error) {
      Functions.confirmError(context, () => {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widthWidget =
        MediaQuery.of(context).size.width - ConfigCustom.globalPadding * 4;

    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBg,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _drawerKey,
        appBar: null,
        drawer: DrawerCustom(),
        body: isLoading
            ? Loading()
            : GestureClickOutside(
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Container(
                          width: widthWidget,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: width / 3,
                                  child: Image.asset(
                                    'assets/app/com_lock.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                                Center(
                                  child: Container(
                                    child: TextCustom(
                                      "Owner completed transaction scan. We will deliver this device to exchanger to check.",
                                      fontSize: 18,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                                Center(
                                  child: Container(
                                    width: width,
                                    child: ButtonCustom(
                                      'Sign In With Exchanger',
                                      onTap: () {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                LoginScreen.routeName,
                                                (Route<dynamic> route) =>
                                                    false);
                                      },
                                    ),
                                  ),
                                ),
                                SpaceCustom(),
                                SpaceCustom(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
