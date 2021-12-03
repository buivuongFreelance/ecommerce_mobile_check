import 'package:animator/animator.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:dingtoimc/widgets/touch_screen.dart';
import 'package:flutter/material.dart';

class TouchScreen extends StatefulWidget {
  static const routeName = '/touch_screen';

  @override
  _TouchScreenState createState() => _TouchScreenState();
}

class _TouchScreenState extends State<TouchScreen> {
  bool _isTouch = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Future init() async {
    if (!await User.auth(context)) return;
    try {
      await User.checkUserIsScanning(context);
      await Device.checkUserAnonymous(context);
    } catch (error) {}
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

  _setTouch(value) {
    if (value != _isTouch)
      setState(() {
        _isTouch = value;
      });
  }

  handleStart() async {
    _setTouch(true);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    PreferredSize appBar = Functions.getAppbarScanner(
        context,
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextCustom(
                'Check General',
                maxLines: 1,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
                fontSize: 16,
                letterSpacing: ConfigCustom.letterSpacing2,
              ),
              TimerCustom(
                widget: true,
              ),
            ],
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
          backgroundColor: Colors.transparent,
          key: _drawerKey,
          drawer: DrawerScan(),
          primary: true,
          appBar: _isTouch ? null : appBar,
          body: Container(
            child: Stack(
              children: <Widget>[
                !_isTouch ? Center() : TouchScreenCustom(),
                _isTouch
                    ? Center()
                    : Container(
                        width: width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: new BoxDecoration(
                                    gradient: ConfigCustom.colorBgCircleOutline,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: new BoxDecoration(
                                    color: ConfigCustom.colorWhite,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Image.asset(
                                    'assets/app/com_smartphone.png',
                                    color: ConfigCustom.colorPrimary,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  bottom: 38,
                                  right: 38,
                                  child: Animator(
                                    tweenMap: {
                                      'translateAnim': Tween<Offset>(
                                          begin: Offset.zero,
                                          end: Offset(0, -1.2)),
                                    },
                                    cycles: 0,
                                    builder: (context, animatorState, child) =>
                                        Center(
                                      child: FractionalTranslation(
                                        translation: animatorState
                                            .getAnimation<Offset>(
                                                'translateAnim')
                                            .value,
                                        child: SizedBox(
                                          width: 40,
                                          child: Image.asset(
                                            'assets/app/com_hand.png',
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            Container(
                              width: width / 1.2,
                              child: TextCustom(
                                'Color in the screen blue by swiping',
                                fontSize: 20,
                                textAlign: TextAlign.center,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SpaceCustom(),
                            Container(
                              width: width / 1.2,
                              child: TextCustom(
                                'The screen color will change from white to blue. Try to color the entire screen blue.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            Container(
                              width: width / 2,
                              child: ButtonCustom(
                                'Start',
                                onTap: () {
                                  handleStart();
                                },
                                color: ConfigCustom.colorPrimary,
                              ),
                            ),
                          ],
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
