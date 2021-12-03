import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/physical_grading_screen.dart';
import 'package:dingtoimc/widgets/blacklist_group.dart';
import 'package:dingtoimc/widgets/bluetooth_group.dart';
import 'package:dingtoimc/widgets/button_bottom.dart';
import 'package:dingtoimc/widgets/camera_group.dart';
import 'package:dingtoimc/widgets/device_header.dart';
import 'package:dingtoimc/widgets/diamond_rating_group.dart';
import 'package:dingtoimc/widgets/divider_custom.dart';

import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/faceid_group.dart';
import 'package:dingtoimc/widgets/finger_group.dart';
import 'package:dingtoimc/widgets/flash_group.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/microphone_group.dart';
import 'package:dingtoimc/widgets/scanner_rating_group.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/speaker_group.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/text_group.dart';
import 'package:dingtoimc/widgets/text_in_group.dart';
import 'package:dingtoimc/widgets/text_out_group.dart';
import 'package:dingtoimc/widgets/timestamp_group.dart';
import 'package:dingtoimc/widgets/touchscreen_group.dart';
import 'package:dingtoimc/widgets/voice_in_group.dart';
import 'package:dingtoimc/widgets/voice_out_group.dart';
import 'package:dingtoimc/widgets/volume_group.dart';
import 'package:dingtoimc/widgets/wifi_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScanScreen extends StatefulWidget {
  static const routeName = '/scan-history-screen';
  @override
  _HistoryScanScreenState createState() => _HistoryScanScreenState();
}

class _HistoryScanScreenState extends State<HistoryScanScreen> {
  bool _isLoading = false;
  String _tappedScan = "all";
  List _listAll = [];
  List _list = [];
  String _activeWidget = 'main';
  Map _detail;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    init();
    super.initState();
  }

  Future init() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List list = await Device.listScanningHistory(context);
      _listAll = list;
      setList();
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  setList() {
    if (_tappedScan == ConfigCustom.all) {
      setState(() {
        _list = List.from(_listAll);
      });
    } else {
      List l = [];
      for (int i = 0; i < _listAll.length; i++) {
        Map item = _listAll[i];
        if (item['type'] == _tappedScan) {
          l.add(item);
        }

        if (_tappedScan == ConfigCustom.userFree) {
          if (item['type'] == ConfigCustom.userFreeSummary) l.add(item);
        } else if (_tappedScan == ConfigCustom.userPro) {
          if (item['type'] == ConfigCustom.userProSummary) l.add(item);
        }
      }
      setState(() {
        _list = l;
      });
    }
  }

  Future goToDetail(item) async {
    String id = item['id'];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });

    try {
      Map detail = await Device.detailScanningHistory(context, id);
      if (detail['type'] == ConfigCustom.userPro) {
        await prefs.setString(ConfigCustom.sharedUserPay, ConfigCustom.userPro);
      }
      setState(() {
        _detail = detail;
      });
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
    setState(() {
      _isLoading = false;
      _activeWidget = 'detail';
    });
  }

  Widget widgetItemList(width) {
    List<Widget> listWidget = new List<Widget>();
    for (var i = 0; i < _list.length; i++) {
      Map item = _list[i];
      String strScan = 'Basic Scan';
      Color colorScan = ConfigCustom.colorSecondary;
      if (item['type'] == ConfigCustom.userPro ||
          item['type'] == ConfigCustom.userProSummary) {
        strScan = 'Pro Scan';
        colorScan = ConfigCustom.colorSecondary;
      }
      listWidget.add(Container(
        width: width,
        child: Column(
          children: <Widget>[
            i == 0 ? DividerCustom() : Center(),
            InkWell(
              onTap: () {
                goToDetail(item);
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Ionicons.ios_timer,
                      color: colorScan,
                      size: 25,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextCustom(
                          Functions.getDateTime(
                              DateTime.tryParse(item['timestamp'].toString())),
                          fontWeight: FontWeight.w900,
                        ),
                        TextCustom(
                          strScan,
                          color: ConfigCustom.colorWhite.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ]),
            ),
            DividerCustom(),
          ],
        ),
      ));
    }
    return new Column(children: listWidget);
  }

  Widget widgetItemTab(message, type) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        setState(() {
          _tappedScan = type;
        });

        setList();
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 2,
                    color: _tappedScan == type
                        ? ConfigCustom.colorSecondary
                        : Colors.transparent))),
        width: width / 3,
        child: Center(
          child: TextCustom(
            message,
            letterSpacing: 0.75,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget widgetDetail() {
    String strScan = 'Basic Scan';
    String strTitleScore = 'Scan Score';
    Widget widgetScanScore = Center();
    bool hasPhysical = true;

    Map deviceCustom = {};
    Map mainInfo;
    if (!Functions.isEmpty(_detail)) {
      mainInfo = _detail['main_info'];
      deviceCustom = Map.from(mainInfo);
      deviceCustom[ConfigCustom.sharedTimestamp] =
          DateTime.tryParse(_detail[ConfigCustom.sharedTimestamp].toString());
      if (_detail['type'] == ConfigCustom.userPro ||
          _detail['type'] == ConfigCustom.userProSummary) {
        strScan = 'Pro Scan';
      }

      widgetScanScore = ScannerRatingGroup(deviceCustom);
      if (_detail['type'] == ConfigCustom.userFreeSummary ||
          _detail['type'] == ConfigCustom.userProSummary) {
        strTitleScore = 'Dingtoi Rating';
        widgetScanScore = DiamondRatingGroup(deviceCustom);
        hasPhysical = false;
      }
    }

    PreferredSize appBar = Functions.getAppbarMainBack(
      context,
      Expanded(
        flex: 2,
        child: TextCustom(
          strScan,
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ),
      ),
      () {
        _drawerKey.currentState.openDrawer();
      },
      () {
        setState(() {
          _activeWidget = 'main';
        });
      },
    );

    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: _isLoading
          ? Loading()
          : Functions.isEmpty(deviceCustom)
              ? Center()
              : Scaffold(
                  appBar: appBar,
                  backgroundColor: Colors.transparent,
                  key: _drawerKey,
                  drawer: DrawerCustom(),
                  body: GestureClickOutside(
                    child: Stack(
                      children: [
                        Container(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                    left: ConfigCustom.globalPadding,
                                    right: ConfigCustom.globalPadding,
                                  ),
                                  child: Center(
                                      child: TimestampGroup(deviceCustom)),
                                ),
                                SpaceCustom(),
                                Center(
                                  child: TextCustom(
                                    strTitleScore.toUpperCase(),
                                    color: ConfigCustom.colorSecondary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: ConfigCustom.letterSpacing,
                                  ),
                                ),
                                SpaceCustom(),
                                widgetScanScore,
                                SpaceCustom(),
                                DeviceHeader(deviceCustom),
                                SpaceCustom(),
                                TextGroup('General'),
                                SpaceCustom(),
                                TouchscreenGroup(
                                  deviceCustom,
                                  image: deviceCustom['touch_url'],
                                ),
                                SpaceCustom(),
                                CameraGroup(deviceCustom),
                                SpaceCustom(),
                                FlashGroup(deviceCustom),
                                SpaceCustom(),
                                VolumeGroup(deviceCustom),
                                SpaceCustom(),
                                SpeakerGroup(deviceCustom),
                                SpaceCustom(),
                                MicrophoneGroup(deviceCustom),
                                SpaceCustom(),
                                FingerGroup(deviceCustom),
                                SpaceCustom(),
                                FaceIdGroup(deviceCustom),
                                TextGroup('Connection'),
                                SpaceCustom(),
                                WifiGroup(deviceCustom),
                                SpaceCustom(),
                                BluetoothGroup(deviceCustom),
                                !Functions.isEmpty(deviceCustom[
                                        ConfigCustom.sharedBlacklistStatus])
                                    ? SpaceCustom()
                                    : Center(),
                                !Functions.isEmpty(deviceCustom[
                                        ConfigCustom.sharedBlacklistStatus])
                                    ? TextGroup('Blacklist')
                                    : Center(),
                                !Functions.isEmpty(deviceCustom[
                                        ConfigCustom.sharedBlacklistStatus])
                                    ? SpaceCustom()
                                    : Center(),
                                !Functions.isEmpty(deviceCustom[
                                        ConfigCustom.sharedBlacklistStatus])
                                    ? BlacklistGroup(deviceCustom)
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedVoiceInbound)
                                    ? SpaceCustom()
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedVoiceInbound)
                                    ? TextGroup('Phone')
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedVoiceInbound)
                                    ? SpaceCustom()
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedVoiceInbound)
                                    ? VoiceInGroup(deviceCustom)
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedVoiceInbound)
                                    ? SpaceCustom()
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedVoiceOutbound)
                                    ? VoiceOutGroup(deviceCustom)
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedTextInbound)
                                    ? SpaceCustom()
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedTextInbound)
                                    ? TextGroup('SMS')
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedTextInbound)
                                    ? SpaceCustom()
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedTextInbound)
                                    ? TextInGroup(deviceCustom)
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedTextInbound)
                                    ? SpaceCustom()
                                    : Center(),
                                mainInfo.containsKey(
                                        ConfigCustom.sharedTextOutbound)
                                    ? TextOutGroup(deviceCustom)
                                    : Center(),
                                SpaceCustom(),
                                SpaceCustom(),
                                SpaceCustom(),
                                SpaceCustom(),
                              ],
                            ),
                          ),
                        ),
                        !hasPhysical
                            ? Center()
                            : Positioned(
                                bottom: 0,
                                left: 0,
                                child: ButtonBottom(
                                  'Add Physical Grading',
                                  MediaQuery.of(context).size.width,
                                  () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        ConfigCustom.routerBack,
                                        HistoryScanScreen.routeName);

                                    await prefs.setString(
                                        ConfigCustom.sharedSelectedScanId,
                                        _detail['id']);

                                    Functions.goToRoute(context,
                                        PhysicalGradingScreen.routeName);
                                  },
                                ),
                              )
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget widgetMain() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    PreferredSize appBar = Functions.getAppbarMainHome(
      context,
      Expanded(
        flex: 2,
        child: TextCustom(
          'HISTORY SCAN',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ),
      ),
      () {
        _drawerKey.currentState.openDrawer();
      },
      () {
        Functions.goToRoute(
          context,
          AskingProScreen.routeName,
        );
      },
    );
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: _isLoading
          ? Loading()
          : Scaffold(
              appBar: appBar,
              backgroundColor: Colors.transparent,
              key: _drawerKey,
              drawer: DrawerCustom(),
              body: Container(
                child: Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 70),
                              width: width - ConfigCustom.globalPadding * 2,
                              height: height - 100,
                              child: _list.length == 0
                                  ? Column(
                                      children: <Widget>[
                                        DividerCustom(),
                                        TextCustom('There are no scans'),
                                        DividerCustom(),
                                      ],
                                    )
                                  : ListView(
                                      children: <Widget>[
                                        widgetItemList(width -
                                            ConfigCustom.globalPadding * 2),
                                      ],
                                    ))
                        ]),
                      ),
                    ),
                    Positioned(
                      child: Container(
                          decoration: BoxDecoration(
                            color: ConfigCustom.colorWhite.withOpacity(0.1),
                          ),
                          height: 50.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              widgetItemTab('All', ConfigCustom.all),
                              widgetItemTab(
                                  'Transaction', ConfigCustom.userTransaction),
                              widgetItemTab('Pro', ConfigCustom.userPro),
                              widgetItemTab('Basic', ConfigCustom.userFree),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;

    if (_activeWidget == 'main')
      widget = widgetMain();
    else if (_activeWidget == 'detail') widget = widgetDetail();

    return WillPopScope(
      onWillPop: () {
        Functions.goToRoute(context, AskingProScreen.routeName);
        return Future.value(false);
      },
      child: widget,
    );
  }
}
