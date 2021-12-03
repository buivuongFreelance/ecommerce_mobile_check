import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class TimeoutScreen extends StatefulWidget {
  static const routeName = '/timeout_screen';

  @override
  _TimeoutScreenState createState() => _TimeoutScreenState();
}

class _TimeoutScreenState extends State<TimeoutScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Future init() async {
    if (!await User.auth(context)) return;

    await User.emptyUserIsScanning();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _goHome() async {
    Navigator.of(context).pushNamedAndRemoveUntil(
        AskingProScreen.routeName, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    PreferredSize appBar = Functions.getAppbarMain(
        context,
        Expanded(
          flex: 1,
          child: TextCustom(
            'Timeout',
            maxLines: 1,
            fontWeight: FontWeight.w900,
            textAlign: TextAlign.center,
            fontSize: 18,
            letterSpacing: ConfigCustom.letterSpacing2,
          ),
        ), () {
      _drawerKey.currentState.openDrawer();
    });

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: ConfigCustom.colorBgBlendBottom,
        ),
        child: Scaffold(
          appBar: appBar,
          backgroundColor: Colors.transparent,
          key: _drawerKey,
          drawer: DrawerCustom(),
          body: Container(
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width / 1.2,
                  child: TextCustom(
                    '00:00',
                    fontSize: 35,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                    color: ConfigCustom.colorErrorLight,
                    letterSpacing: ConfigCustom.letterSpacing * 2,
                  ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                Container(
                  width: width / 1.25,
                  child: TextCustom(
                    'You have run out of scan time. Please scan again.',
                    textAlign: TextAlign.center,
                    fontSize: 18,
                  ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                SpaceCustom(),
                Container(
                  child: Image.asset('assets/app/com_session_timeout.png'),
                  width: width / 2,
                ),
                SpaceCustom(),
                SpaceCustom(),
                SpaceCustom(),
                SpaceCustom(),
                Container(
                  width: width / 2,
                  child: ButtonCustom(
                    'Scan Again',
                    onTap: () {
                      _goHome();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
