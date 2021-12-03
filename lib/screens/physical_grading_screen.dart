import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/scanner_confirm_screen.dart';
import 'package:dingtoimc/widgets/button_bottom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhysicalGradingScreen extends StatefulWidget {
  static const routeName = '/physical_grading';

  @override
  _PhysicalGradingScreenState createState() => _PhysicalGradingScreenState();
}

class _PhysicalGradingScreenState extends State<PhysicalGradingScreen> {
  String _selectedGrade = '';
  bool _isLoading = false;
  String mode = ConfigCustom.defaultMode;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Map detailScanFromServer;

  Future _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(ConfigCustom.sharedSelectedScanId)) {
      Functions.goToRoute(context, AskingProScreen.routeName);
      return;
    }
    String customMode = await Functions.getModeType(context);

    if (customMode == ConfigCustom.defaultMode) {
      await User.emptyTimer();
    } else if (customMode == ConfigCustom.transactionCodeLockScan) {
      detailScanFromServer = await Device.backendGetDeviceScan(
          context, prefs.get(ConfigCustom.sharedSelectedScanId));

      setState(() {
        _selectedGrade = detailScanFromServer['physical_grading'];
        mode = customMode;
      });
    }
    var physicalGrading = prefs.get(ConfigCustom.sharedPointPhysical);
    if (!Functions.isEmpty(physicalGrading)) {
      String selectedGarde = 'D';
      if (physicalGrading == 50)
        selectedGarde = 'A';
      else if (physicalGrading == 40)
        selectedGarde = 'B';
      else if (physicalGrading == 30) selectedGarde = 'C';
      setState(() {
        _selectedGrade = selectedGarde;
        mode = customMode;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _goToSummary() async {
    if (_selectedGrade != '') {
      int number = 0;
      setState(() {
        _isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_selectedGrade == 'A')
        number = 50;
      else if (_selectedGrade == 'B')
        number = 40;
      else if (_selectedGrade == 'C')
        number = 30;
      else if (_selectedGrade == 'D') number = 10;
      await prefs.setInt(ConfigCustom.sharedPointPhysical, number);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushNamedAndRemoveUntil(
          ScannerConfirmScreen.routeName, (Route<dynamic> route) => false);
    } else {
      Functions.confirmSomethingError(
          context, 'Please select the physical grade of your phone.', () {});
    }
  }

  Widget widgetGrade(
      String text, value, String desc1, String desc2, String desc3) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _selectedGrade = value;
        });
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            ConfigCustom.globalPadding, 0, ConfigCustom.globalPadding, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ConfigCustom.borderRadius4),
            color: _selectedGrade == value ? Colors.white : Colors.white10,
          ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _selectedGrade == value
                        ? Positioned(
                            //left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: width / 5,
                              decoration: BoxDecoration(
                                color:
                                    ConfigCustom.colorPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        ConfigCustom.borderRadius4),
                                    bottomLeft: Radius.circular(
                                        ConfigCustom.borderRadius4)),
                              ),
                              child: Center(
                                  child: TextCustom(
                                value,
                                fontSize: width / 5,
                                fontWeight: FontWeight.w900,
                                color:
                                    ConfigCustom.colorPrimary.withOpacity(0.1),
                              )),
                            ),
                          )
                        : Positioned(
                            //left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                                width: width / 5,
                                decoration: BoxDecoration(
                                  color:
                                      ConfigCustom.colorWhite.withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          ConfigCustom.borderRadius4),
                                      bottomLeft: Radius.circular(
                                          ConfigCustom.borderRadius4)),
                                ),
                                child: Center(
                                    child: TextCustom(
                                  value,
                                  fontWeight: FontWeight.w900,
                                  fontSize: width / 5,
                                  color:
                                      ConfigCustom.colorWhite.withOpacity(0.1),
                                ))),
                          ),
                    Container(
                      width: width,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          width / 5 + ConfigCustom.globalPadding,
                          ConfigCustom.globalPadding,
                          0,
                          ConfigCustom.globalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextCustom(
                              text.toUpperCase(),
                              fontSize: 16,
                              color: _selectedGrade == value
                                  ? ConfigCustom.colorPrimary
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextCustom(
                                    desc1,
                                    fontSize: 13,
                                    maxLines: 2,
                                    color: _selectedGrade == value
                                        ? ConfigCustom.colorSteel
                                        : ConfigCustom.colorWhite
                                            .withOpacity(0.7),
                                  ),
                                  SizedBox(
                                    height: 2.0,
                                  ),
                                  TextCustom(
                                    desc2,
                                    fontSize: 13,
                                    maxLines: 2,
                                    color: _selectedGrade == value
                                        ? ConfigCustom.colorSteel
                                        : ConfigCustom.colorWhite
                                            .withOpacity(0.7),
                                  ),
                                  SizedBox(
                                    height: 2.0,
                                  ),
                                  Functions.isEmpty(desc3)
                                      ? Center()
                                      : TextCustom(
                                          desc3,
                                          fontSize: 13,
                                          maxLines: 2,
                                          color: _selectedGrade == value
                                              ? ConfigCustom.colorSteel
                                              : ConfigCustom.colorWhite
                                                  .withOpacity(0.7),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PreferredSize appBar = Functions.getAppbarScanner(
        context,
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextCustom(
                'Physical Grading',
                maxLines: 1,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
                fontSize: 16,
                letterSpacing: ConfigCustom.letterSpacing2,
              ),
              (mode == ConfigCustom.deviceScanMode ||
                      mode == ConfigCustom.transactionOwnerMode ||
                      mode == ConfigCustom.transactionCodeLockScan)
                  ? TimerCustom(
                      widget: true,
                    )
                  : Center(),
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
        child: _isLoading
            ? Loading()
            : Scaffold(
                primary: true,
                appBar: appBar,
                backgroundColor: Colors.transparent,
                key: _drawerKey,
                drawer: mode == ConfigCustom.defaultMode
                    ? DrawerCustom()
                    : DrawerScan(),
                body: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: ConfigCustom.colorBg,
                      ),
                      child: Container(
                        child: ListView(
                          children: <Widget>[
                            SpaceCustom(),
                            SpaceCustom(),
                            Padding(
                              padding: EdgeInsets.only(
                                left: ConfigCustom.globalPadding,
                                right: ConfigCustom.globalPadding,
                              ),
                              child: TextCustom(
                                'PHYSICAL GRADING',
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SpaceCustom(),
                            Padding(
                              padding: EdgeInsets.only(
                                left: ConfigCustom.globalPadding,
                                right: ConfigCustom.globalPadding,
                              ),
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  text:
                                      'Please select the physical grade of your phone from A-D, based on the descriptions provided. Once selected, click on ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: ConfigCustom.colorWhite
                                        .withOpacity(0.9),
                                    fontFamily: 'AvenirNext',
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'GO TO SUMMARY REPORT',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: ConfigCustom.colorWhite)),
                                    TextSpan(
                                      text: ' at the bottom.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            widgetGrade(
                              'Grade A',
                              'A',
                              'Almost new',
                              'Very few or imperceptible scratches',
                              'Very minimal usage',
                            ),
                            SpaceCustom(),
                            widgetGrade(
                              'Grade B',
                              'B',
                              'Almost Grade A but a few more',
                              'visible minor scratches',
                              '',
                            ),
                            SpaceCustom(),
                            widgetGrade(
                              'Grade C',
                              'C',
                              'Obvious signs of visible wear',
                              'Many scratches, but no dents or cracks anywhere',
                              '',
                            ),
                            SpaceCustom(),
                            widgetGrade(
                              'Grade D',
                              'D',
                              'Visible cracks on screen and/or casing dents',
                              'Deep scratches and scuffs',
                              '',
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ButtonBottom(
                        'Go To Summary Report',
                        MediaQuery.of(context).size.width,
                        () {
                          _goToSummary();
                        },
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
