import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/rules.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/physical_grading_screen.dart';
import 'package:dingtoimc/widgets/blacklist_group.dart';
import 'package:dingtoimc/widgets/bluetooth_group.dart';
import 'package:dingtoimc/widgets/button_bottom.dart';
import 'package:dingtoimc/widgets/button_check.dart';
import 'package:dingtoimc/widgets/camera_group.dart';
import 'package:dingtoimc/widgets/device_header.dart';
import 'package:dingtoimc/widgets/divider_custom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/faceid_group.dart';
import 'package:dingtoimc/widgets/finger_group.dart';
import 'package:dingtoimc/widgets/flash_group.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:dingtoimc/widgets/microphone_group.dart';
import 'package:dingtoimc/widgets/over_repaint_boundary.dart';
import 'package:dingtoimc/widgets/scanner_rating_group.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/speaker_group.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/text_group.dart';
import 'package:dingtoimc/widgets/text_in_group.dart';
import 'package:dingtoimc/widgets/text_out_group.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:dingtoimc/widgets/timestamp_group.dart';
import 'package:dingtoimc/widgets/touchscreen_group.dart';
import 'package:dingtoimc/widgets/voice_in_group.dart';
import 'package:dingtoimc/widgets/voice_out_group.dart';
import 'package:dingtoimc/widgets/volume_group.dart';
import 'package:dingtoimc/widgets/wifi_group.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ScannerBasicScreen extends StatefulWidget {
  static const routeName = '/scanner_basic';

  @override
  _ScannerBasicScreenState createState() => _ScannerBasicScreenState();
}

class _ScannerBasicScreenState extends State<ScannerBasicScreen> {
  Map _device;
  Map _point;
  Map _scan = {};
  Map blacklist;
  bool isPhone = false;
  bool isText = false;
  bool _isLoading = false;
  bool isSave = false;
  Map rules = Rules.getRulesDiamond();
  Map myScan = {};
  Map ownerScan = {};
  String mode = ConfigCustom.defaultMode;
  String transactionCode = '';
  GlobalKey globalKey = GlobalKey();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Uint8List _pngBytes;
  bool modeCompare = false;
  bool modeOpenDispute = false;

  List questions = [];
  List selectedQuestions = [];

  StreamSubscription subscription;
  ConnectivityResult connect = ConnectivityResult.wifi;

  Future _shareFileImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Share.file(
          'Dingtoi MC', ConfigCustom.imageScan, _pngBytes, 'image/png',
          text: 'Dingtoi MC.');
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      Functions.confirmSomethingError(
          context, 'Gallery', 'Something Wrong ... Please Try Again');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _checkPermissionShareImage() async {
    PermissionStatus status = await Permission.photos.status;
    if (status.isUndetermined || status.isDenied || status.isRestricted) {
      if (await Permission.photos.request().isGranted) {
        _shareFileImage();
      }
    } else if (status.isGranted) {
      _shareFileImage();
    }
  }

  Future _initCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    imageCache.clear();
    try {
      if (!await User.auth(context)) return;
      var userPay =
          prefs.get(ConfigCustom.sharedUserPay) ?? ConfigCustom.userFree;
      var userScan = prefs.get(ConfigCustom.authScan) ?? ConfigCustom.no;

      var scan = {
        ConfigCustom.sharedUserPay: userPay,
        ConfigCustom.authScan: userScan,
      };
      await Device.checkUserAnonymous(context);

      Map _rules = await Rules.listRules();
      String customMode = await Functions.getModeType(context);
      if (customMode == ConfigCustom.defaultMode) {
        await User.emptyTimer();
      }

      if (customMode == ConfigCustom.transactionCodeLockScan) {
        transactionCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
        List list = await Device.listQuestionBuyerReject(context);
        setState(() {
          questions = list;
        });
      }

      rules = _rules;
      setState(() {
        _isLoading = true;
        _scan = scan;
        mode = customMode;
      });
      _initPlatform();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            AskingProScreen.routeName, (Route<dynamic> route) => false);
      }
    }
  }

  Future<double> _calculatePoint(device) async {
    double total = double.parse(rules['total'].toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int ptsTouchScreen = rules[ConfigCustom.sharedPointTouchScreen];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointTouchScreen])) {
      total -= ptsTouchScreen;
    }
    int ptsBluetooth = rules[ConfigCustom.sharedPointBluetooth];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointBluetooth])) {
      if (total > 0) total -= ptsBluetooth;
    }
    int ptsWifi = rules[ConfigCustom.sharedPointWifi];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointWifi])) {
      if (total > 0) total -= ptsWifi;
    }
    int ptsFinger = rules[ConfigCustom.sharedPointFinger];
    if (device[ConfigCustom.sharedPointFinger] == ConfigCustom.nothave) {
      if (Functions.isEmpty(device[ConfigCustom.sharedPointFinger])) {
        if (total > 0) total -= ptsFinger;
      }
    }

    int ptsFaceId = rules[ConfigCustom.sharedPointFaceID];
    if (device[ConfigCustom.sharedPointFaceID] == ConfigCustom.nothave) {
      if (Functions.isEmpty(device[ConfigCustom.sharedPointFaceID])) {
        if (total > 0) total -= ptsFaceId;
      }
    }
    int ptsCamera = rules[ConfigCustom.sharedPointCamera];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointCamera])) {
      if (total > 0) total -= ptsCamera;
    }
    int ptsFlash = rules[ConfigCustom.sharedPointFlash];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointFlash])) {
      if (total > 0) total -= ptsFlash;
    }
    int ptsStorage = rules[ConfigCustom.sharedPointStorage];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointStorage])) {
      if (total > 0) total -= ptsStorage;
    }
    int ptsOS = rules[ConfigCustom.sharedPointReleased];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointReleased])) {
      if (total > 0) total -= ptsOS;
    }
    int ptsProcessor = rules[ConfigCustom.sharedPointProcessor];
    if (Functions.isEmpty(device[ConfigCustom.sharedPointProcessor])) {
      if (total > 0) total -= ptsProcessor;
    }

    await prefs.setString(ConfigCustom.sharedPointScanner, total.toString());

    return Future.value(total);
  }

  Future _initPlatform() async {
    String model = '';
    String version = '';
    String hardware = '';
    String brand = '';
    String camera = '';
    String faceId = '';
    String fingerprint = '';
    String volume = '';
    String wifi = '';
    String bluetooth = '';
    String flash = '';
    String microphone = '';

    camera = await Device.checkCamera();
    flash = await Functions.checkFlash();
    volume = await Functions.checkVolume();
    wifi = await Functions.checkWifi();
    bluetooth = await Functions.checkBluetooth();
    Map diskSpace = await Functions.getDiskSpace();
    String touchscreen = await Device.getTouchscreen(context);

    List systemFeatures = [];

    if (Platform.isAndroid) {
      Map dataAndroid = await Device.getDeviceDataAndroid();
      try {
        if (Functions.isEmpty(model))
          model = dataAndroid[ConfigCustom.sharedDeviceModel];
      } catch (error) {
        model = dataAndroid[ConfigCustom.sharedDeviceModel];
      }

      version = dataAndroid[ConfigCustom.sharedPointReleased];
      hardware = dataAndroid[ConfigCustom.sharedPointProcessor];
      brand = dataAndroid['brand'];
      systemFeatures = dataAndroid['systemFeatures'];
    } else if (Platform.isIOS) {
      Map dataIOS = await Device.getDeviceDataIOS();
      Map deviceInfo = await Device.getDeviceInfoIOS(dataIOS['machine']);

      model = deviceInfo[ConfigCustom.sharedDeviceModel];
      version = dataIOS[ConfigCustom.sharedPointReleased];
      hardware = deviceInfo[ConfigCustom.sharedPointProcessor];
      brand = dataIOS['brand'];
      systemFeatures = deviceInfo['systemFeatures'];
    }

    faceId = await Device.checkBiometricsFace(systemFeatures);
    fingerprint =
        await Device.checkBiometricsFingerprint(systemFeatures, brand);

    microphone = await Device.checkMicrophone(systemFeatures, brand);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime dt = DateTime.now();
    await prefs.setString(ConfigCustom.sharedTimestamp, dt.toString());

    Map device = {
      ConfigCustom.sharedDeviceModel: model,
      ConfigCustom.sharedPointReleased: version,
      ConfigCustom.sharedPointProcessor: hardware,
      'brand': brand,
      ConfigCustom.sharedPointCamera: camera,
      ConfigCustom.sharedPointFaceID: faceId,
      ConfigCustom.sharedPointFinger: fingerprint,
      ConfigCustom.sharedPointVolume: volume,
      ConfigCustom.sharedPointWifi: wifi,
      ConfigCustom.sharedPointBluetooth: bluetooth,
      ConfigCustom.sharedPointStorage: diskSpace['total'],
      ConfigCustom.sharedPointStorageUsed: diskSpace['used'],
      ConfigCustom.sharedPointFlash: flash,
      ConfigCustom.sharedPointTouchScreen: touchscreen,
      ConfigCustom.sharedTimestamp: dt,
      ConfigCustom.sharedPointMicrophone: microphone,
    };

    Map point = {
      ConfigCustom.sharedPointScanner: await _calculatePoint(device),
    };

    Map _blacklist;
    if (prefs.containsKey(ConfigCustom.sharedBlacklistStatus) &&
        prefs.containsKey(ConfigCustom.sharedBlacklistType)) {
      _blacklist = {
        ConfigCustom.sharedBlacklistStatus:
            prefs.getString(ConfigCustom.sharedBlacklistStatus),
        ConfigCustom.sharedBlacklistType:
            prefs.getString(ConfigCustom.sharedBlacklistType),
      };
    }

    bool _isVoice = false;
    bool _isText = false;
    if (prefs.containsKey(ConfigCustom.sharedVoice)) {
      if (prefs.getString(ConfigCustom.sharedVoice) == ConfigCustom.yes) {
        _isVoice = true;
        device[ConfigCustom.sharedVoiceInbound] =
            prefs.getString(ConfigCustom.sharedVoiceInbound);
        device[ConfigCustom.sharedVoiceOutbound] =
            prefs.getString(ConfigCustom.sharedVoiceOutbound);
      }
    }
    if (prefs.containsKey(ConfigCustom.sharedText)) {
      if (prefs.getString(ConfigCustom.sharedText) == ConfigCustom.yes) {
        _isText = true;
        device[ConfigCustom.sharedTextInbound] =
            prefs.getString(ConfigCustom.sharedTextInbound);
        device[ConfigCustom.sharedTextOutbound] =
            prefs.getString(ConfigCustom.sharedTextOutbound);
      }
    }

    setState(() {
      _device = device;
      _isLoading = false;
      _point = point;
      blacklist = _blacklist;
      isPhone = _isVoice;
      isText = _isText;
    });
    _initPaint();
  }

  Future _initPaint() async {
    try {
      if (Functions.isEmpty(globalKey.currentContext)) {
        await Future.delayed(const Duration(seconds: 2));
        _initPaint();
      } else {
        var renderObject = globalKey.currentContext.findRenderObject();
        RenderRepaintBoundary boundary = renderObject;
        ui.Image captureImage =
            await boundary.toImage(pixelRatio: ConfigCustom.pngRatio);
        ByteData byteData =
            await captureImage.toByteData(format: ui.ImageByteFormat.png);
        String tempPath = await Functions.getTemporaryPath();
        File file = new File('$tempPath/${ConfigCustom.imageScan}');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        setState(() {
          _pngBytes = byteData.buffer.asUint8List();
        });
        await confirmReport();
      }
    } catch (error) {}
  }

  Future confirmReport() async {
    try {
      String customMode = await Functions.getModeType(context);
      Map _blacklist = Functions.isEmpty(blacklist) ? {} : blacklist;
      Map obj = {
        ..._device,
        ..._point,
        ..._blacklist,
      };

      String tempPath = await Functions.getTemporaryPath();

      if (_device[ConfigCustom.sharedPointTouchScreen] == ConfigCustom.no) {
        String urlTouch =
            await Device.uploadImage('$tempPath/${ConfigCustom.imageTouch}');
        obj['touch_url'] = urlTouch;
      }

      String urlMain =
          await Device.uploadImage('$tempPath/${ConfigCustom.imageScan}');

      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userPay = prefs.get(ConfigCustom.sharedUserPay);
      String id;

      if (customMode == ConfigCustom.defaultMode) {
        id = await Device.confirmReport(
          context,
          _device[ConfigCustom.sharedTimestamp],
          userPay,
          urlMain,
          obj,
        );
      } else {
        id = await Device.confirmReportWeb(
          context,
          customMode,
          _device[ConfigCustom.sharedTimestamp],
          userPay,
          urlMain,
          obj,
        );
      }

      await prefs.setString(ConfigCustom.sharedSelectedScanId, id);
      setState(() {
        isSave = true;
      });
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
  }

  Future goToPhysical() async {
    if (mode != ConfigCustom.transactionCodeLockScan)
      Functions.goToRoute(context, PhysicalGradingScreen.routeName);
    else
      Functions.goToRoute(context, PhysicalGradingScreen.routeName);
  }

  Future initCompare() async {
    try {
      setState(() {
        _isLoading = true;
      });
      Map obj = await Device.transactionListCompare(context, transactionCode);
      setState(() {
        _isLoading = false;
        modeCompare = true;
        myScan = obj['myScan'];
        ownerScan = obj['ownerScan'];
      });
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
  }

  Widget widgetMain(width) {
    return Stack(
      children: <Widget>[
        Container(
          width: width,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
          height: ConfigCustom.heightHeadScan / 2.5,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, ConfigCustom.heightHeadScan / 2.5, 0,
              ConfigCustom.heightButton),
          child: SingleChildScrollView(
            child: OverRepaintBoundary(
              key: globalKey,
              child: RepaintBoundary(
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    gradient: ConfigCustom.colorBgBlendBottom,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ConfigCustom.borderRadius2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Center(child: TimestampGroup(_device)),
                      SpaceCustom(),
                      Center(
                        child: TextCustom(
                          "SCAN SCORE",
                          color: ConfigCustom.colorSecondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: ConfigCustom.letterSpacing,
                        ),
                      ),
                      SpaceCustom(),
                      ScannerRatingGroup(_point),
                      SpaceCustom(),
                      !Functions.isEmpty(blacklist) ? SpaceCustom() : Center(),
                      !Functions.isEmpty(blacklist)
                          ? TextGroup('Blacklist')
                          : Center(),
                      !Functions.isEmpty(blacklist) ? SpaceCustom() : Center(),
                      !Functions.isEmpty(blacklist)
                          ? BlacklistGroup(blacklist)
                          : Center(),
                      SpaceCustom(),
                      TextGroup('General'),
                      SpaceCustom(),
                      TouchscreenGroup(_device),
                      SpaceCustom(),
                      CameraGroup(_device),
                      SpaceCustom(),
                      FlashGroup(_device),
                      SpaceCustom(),
                      VolumeGroup(_device),
                      SpaceCustom(),
                      SpeakerGroup(_device),
                      SpaceCustom(),
                      MicrophoneGroup(_device),
                      SpaceCustom(),
                      FingerGroup(_device),
                      FaceIdGroup(_device),
                      TextGroup('Connection'),
                      SpaceCustom(),
                      WifiGroup(_device),
                      SpaceCustom(),
                      BluetoothGroup(_device),
                      isPhone ? SpaceCustom() : Center(),
                      isPhone ? TextGroup('Phone') : Center(),
                      isPhone ? SpaceCustom() : Center(),
                      isPhone ? VoiceInGroup(_device) : Center(),
                      isPhone ? SpaceCustom() : Center(),
                      isPhone ? VoiceOutGroup(_device) : Center(),
                      isText ? SpaceCustom() : Center(),
                      isText ? TextGroup('SMS') : Center(),
                      isText ? SpaceCustom() : Center(),
                      isText ? TextInGroup(_device) : Center(),
                      isText ? SpaceCustom() : Center(),
                      isText ? TextOutGroup(_device) : Center(),
                      SpaceCustom(),
                      DeviceHeader(_device),
                      SpaceCustom(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: ConfigCustom.heightHeadScan - ConfigCustom.globalPadding * 7.7,
          right: ConfigCustom.globalPadding,
          child: InkWell(
            onTap: () {
              _checkPermissionShareImage();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ConfigCustom.colorPrimary2,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Functions.isEmpty(_pngBytes)
                    ? LoadingWidget()
                    : SizedBox(
                        width: 20,
                        child: Image.asset(
                          Platform.isAndroid
                              ? 'assets/app/com_share_and.png'
                              : 'assets/app/com_share_ios.png',
                          fit: BoxFit.contain,
                        )),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: _scan[ConfigCustom.sharedUserPay] != ConfigCustom.userFree
              ? ButtonBottom(
                  mode == ConfigCustom.transactionCodeLockScan
                      // ? 'Compare Scan'
                      ? 'Go To Physical Grading'
                      : 'Go To Physical Grading',
                  MediaQuery.of(context).size.width,
                  () {
                    if (isSave) {
                      goToPhysical();
                    }
                  },
                  isLoading: !isSave,
                )
              : ButtonBottom(
                  'Go To Physical Grading',
                  MediaQuery.of(context).size.width,
                  () {
                    if (isSave) {
                      goToPhysical();
                    }
                  },
                  isLoading: !isSave,
                ),
        )
      ],
    );
  }

  Widget widgetQuestions() {
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < questions.length; i++) {
      list.add(
        new ListTile(
          leading: CircularCheckBox(
              value:
                  selectedQuestions.contains(questions[i]['id']) ? true : false,
              checkColor: Colors.white,
              activeColor: Colors.green,
              inactiveColor: Colors.redAccent,
              disabledColor: Colors.grey,
              onChanged: (val) => this.setState(() {
                    if (val) {
                      selectedQuestions.add(questions[i]['id']);
                    } else {
                      selectedQuestions.remove(questions[i]['id']);
                    }
                  })),
          title: TextCustom(questions[i]['name'],
              letterSpacing: ConfigCustom.letterSpacing2,
              fontSize: 15,
              color: ConfigCustom.colorWhite,
              fontWeight: FontWeight.w600),
          onTap: () => this.setState(() {
            if (selectedQuestions.contains(questions[i]['id'])) {
              selectedQuestions.remove(questions[i]['id']);
            } else {
              selectedQuestions.add(questions[i]['id']);
            }
          }),
        ),
      );
    }
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: list);
  }

  Widget widgetOpenDispute(appbar, widthWidget) {
    return Stack(
      children: <Widget>[
        Column(
          children: [
            SpaceCustom(),
            SpaceCustom(),
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextCustom(
                "Why do you select Open Dispute ?",
                fontSize: 16,
                textAlign: TextAlign.center,
              ),
            ),
            SpaceCustom(),
            SpaceCustom(),
            Container(
              child: SingleChildScrollView(child: widgetQuestions()),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: ButtonBottom(
            'Send',
            MediaQuery.of(context).size.width,
            () {
              handlerSendNo();
            },
            isLoading: false,
          ),
        )
      ],
    );
  }

  Widget compareHeader(widthCustom, text) {
    return Container(
      width: widthCustom / 3,
      height: ConfigCustom.heightWidget,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextCustom(
          text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: ConfigCustom.letterSpacing2,
        ),
      ),
    );
  }

  Widget widgetCompare(appBar) {
    double width = MediaQuery.of(context).size.width;
    double widthCustom = width - 60;
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            width: width,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
            padding: EdgeInsets.fromLTRB(
                ConfigCustom.globalPadding,
                ConfigCustom.globalPadding,
                ConfigCustom.globalPadding,
                ConfigCustom.globalPadding * 4),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, ConfigCustom.globalPadding, 0,
                      ConfigCustom.globalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Image.asset("assets/app/com_compare_scan.png"),
                      ),
                      myScan.containsKey(ConfigCustom.sharedTimestamp) &&
                              ownerScan
                                  .containsKey(ConfigCustom.sharedTimestamp)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        modeOpenDispute = true;
                                      });
                                    },
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: TextCustom(
                                        'Open Dispute',
                                        color: ConfigCustom.colorErrorLight,
                                      ),
                                    ),
                                  ),
                                ),
                                SpaceCustom(),
                                Row(
                                  children: [
                                    Container(
                                      width: widthCustom / 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextCustom(
                                            'YOUR SCAN',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          TextCustom(
                                            Functions.getDateCustom(myScan[
                                                ConfigCustom.sharedTimestamp]),
                                            fontSize: 11,
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          TextCustom(
                                            Functions.getTimeCustom(myScan[
                                                ConfigCustom.sharedTimestamp]),
                                            fontSize: 11,
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: widthCustom / 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextCustom(
                                            'OWNER SCAN',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          TextCustom(
                                            Functions.getDateCustom(ownerScan[
                                                ConfigCustom.sharedTimestamp]),
                                            fontSize: 11,
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          TextCustom(
                                            Functions.getTimeCustom(ownerScan[
                                                ConfigCustom.sharedTimestamp]),
                                            fontSize: 11,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : Center()
                    ],
                  ),
                ),
                DividerCustom(),
                myScan.containsKey('main_info') &&
                        ownerScan.containsKey('main_info')
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Dingtoi Rating'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: SmoothStarRating(
                                    allowHalfRating: false,
                                    onRated: (v) {},
                                    starCount: 5,
                                    rating: double.tryParse(myScan['main_info']
                                            ['diamondRating']
                                        .toString()),
                                    size: 16,
                                    isReadOnly: true,
                                    filledIconData: Icons.star,
                                    halfFilledIconData: Icons.star_half,
                                    color: ConfigCustom.colorSecondary,
                                    borderColor: ConfigCustom.colorSecondary,
                                    spacing: ConfigCustom.globalPadding / 10,
                                  ),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: SmoothStarRating(
                                    allowHalfRating: false,
                                    onRated: (v) {},
                                    starCount: 5,
                                    rating: double.tryParse(
                                        ownerScan['main_info']['diamondRating']
                                            .toString()),
                                    size: 16,
                                    isReadOnly: true,
                                    filledIconData: Icons.star,
                                    halfFilledIconData: Icons.star_half,
                                    color: ConfigCustom.colorSecondary,
                                    borderColor: ConfigCustom.colorSecondary,
                                    spacing: ConfigCustom.globalPadding / 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     compareHeader(widthCustom, 'Physical Grading'),
                          //     Container(
                          //       height: ConfigCustom.heightWidget,
                          //       width: widthCustom / 3,
                          //       child: Align(
                          //         alignment: Alignment.centerRight,
                          //         child: TextCustom(
                          //           myScan['physical_grading'],
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ),
                          //     Container(
                          //       width: widthCustom / 3,
                          //       height: ConfigCustom.heightWidget,
                          //       child: Align(
                          //         alignment: Alignment.centerRight,
                          //         child: TextCustom(
                          //           ownerScan['physical_grading'],
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // DividerCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Touch Screen'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: myScan['main_info'][ConfigCustom
                                              .sharedPointTouchScreen] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ownerScan['main_info'][ConfigCustom
                                              .sharedPointTouchScreen] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Camera'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: myScan['main_info'][
                                              ConfigCustom.sharedPointCamera] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ownerScan['main_info'][
                                              ConfigCustom.sharedPointCamera] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Flash'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: myScan['main_info']
                                              [ConfigCustom.sharedPointFlash] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ownerScan['main_info']
                                              [ConfigCustom.sharedPointFlash] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Volume'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: myScan['main_info'][
                                              ConfigCustom.sharedPointVolume] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ownerScan['main_info'][
                                              ConfigCustom.sharedPointVolume] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Speaker'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: myScan['main_info'][
                                              ConfigCustom.sharedPointVolume] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ownerScan['main_info'][
                                              ConfigCustom.sharedPointVolume] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Wifi'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: myScan['main_info']
                                              [ConfigCustom.sharedPointWifi] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ownerScan['main_info']
                                              [ConfigCustom.sharedPointWifi] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Bluetooth'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: myScan['main_info'][ConfigCustom
                                              .sharedPointBluetooth] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ownerScan['main_info'][ConfigCustom
                                              .sharedPointBluetooth] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
                        ],
                      )
                    : Center(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Row(
            children: [
              ButtonBottom(
                'Next',
                width,
                () {
                  if (isSave) {
                    Functions.goToRoute(
                        context, PhysicalGradingScreen.routeName);
                  }
                },
                isLoading: !isSave ? true : false,
              )
            ],
          ),
        )
      ],
    );
  }

  Future handlerSendNo() async {
    if (selectedQuestions.length == 0) {
      Functions.confirmSomethingError(context,
          'You must give at least a reason to reject this device.', () {});
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
        String transactionCode =
            prefs.getString(ConfigCustom.transactionCodeLockScan);
        await Device.transactionBuyerReject(
            context, transactionCode, selectedQuestions);
      }
      Functions.goToRoute(context, AskingProScreen.routeName);
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

  @override
  void initState() {
    _initCheck();
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != connect) {
        connect = result;
        _initCheck();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widthWidget =
        MediaQuery.of(context).size.width - ConfigCustom.globalPadding * 4;
    Widget widget = Center();

    PreferredSize appBar = !isSave
        ? null
        : modeCompare || modeOpenDispute
            ? Functions.getAppbarMainBack(
                context,
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextCustom(
                        modeCompare
                            ? modeOpenDispute
                                ? 'Open Dispute'
                                : 'Compare Scan'
                            : 'Scan Report',
                        maxLines: 1,
                        fontWeight: FontWeight.w900,
                        textAlign: TextAlign.center,
                        fontSize: 16,
                        letterSpacing: ConfigCustom.letterSpacing2,
                      ),
                      mode == ConfigCustom.deviceScanMode ||
                              mode == ConfigCustom.transactionOwnerMode ||
                              mode == ConfigCustom.transactionCodeLockScan
                          ? TimerCustom(
                              widget: true,
                            )
                          : Center(),
                    ],
                  ),
                ),
                () {
                  _drawerKey.currentState.openDrawer();
                },
                () {
                  if (modeOpenDispute) {
                    setState(() {
                      modeOpenDispute = false;
                    });
                  } else if (modeCompare) {
                    setState(() {
                      modeCompare = false;
                    });
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        PhysicalGradingScreen.routeName,
                        (Route<dynamic> route) => false);
                  }
                },
              )
            : Functions.getAppbarScanner(
                context,
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextCustom(
                        modeCompare
                            ? modeOpenDispute
                                ? 'Open Dispute'
                                : 'Compare Scan'
                            : 'Scan Report',
                        maxLines: 1,
                        fontWeight: FontWeight.w900,
                        textAlign: TextAlign.center,
                        fontSize: 16,
                        letterSpacing: ConfigCustom.letterSpacing2,
                      ),
                      mode == ConfigCustom.deviceScanMode ||
                              mode == ConfigCustom.transactionCodeLockScan ||
                              mode == ConfigCustom.transactionOwnerMode
                          ? TimerCustom(
                              widget: true,
                            )
                          : Center(),
                    ],
                  ),
                ), () {
                _drawerKey.currentState.openDrawer();
              });

    if (modeOpenDispute) {
      widget = widgetOpenDispute(appBar, widthWidget);
    } else if (modeCompare) {
      widget = widgetCompare(appBar);
    } else {
      widget = widgetMain(width);
    }

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: Container(
        color: ConfigCustom.colorPrimary,
        child: Functions.isEmpty(_device) ||
                _isLoading ||
                Functions.isEmpty(_point)
            ? Loading()
            : Scaffold(
                appBar: appBar,
                backgroundColor: Colors.transparent,
                key: _drawerKey,
                drawer: mode == ConfigCustom.defaultMode
                    ? DrawerCustom()
                    : DrawerScan(),
                body: Container(
                  child: WillPopScope(
                    onWillPop: () {
                      return Functions.confirmScanAgain(context);
                    },
                    child: widget,
                  ),
                ),
              ),
      ),
    );
  }
}
