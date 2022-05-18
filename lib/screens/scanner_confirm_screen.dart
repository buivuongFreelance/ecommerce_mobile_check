import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/physical_grading_screen.dart';
import 'package:dingtoimc/screens/thank_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:dingtoimc/widgets/blacklist_group.dart';
import 'package:dingtoimc/widgets/bluetooth_group.dart';
import 'package:dingtoimc/widgets/button_bottom.dart';
import 'package:dingtoimc/widgets/button_check.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/camera_group.dart';
import 'package:dingtoimc/widgets/device_header.dart';
import 'package:dingtoimc/widgets/diamond_rating_group.dart';
import 'package:dingtoimc/widgets/divider_custom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/faceid_group.dart';
import 'package:dingtoimc/widgets/finger_group.dart';
import 'package:dingtoimc/widgets/flash_group.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/loading_widget.dart';
import 'package:dingtoimc/widgets/microphone_group.dart';
import 'package:dingtoimc/widgets/over_repaint_boundary.dart';
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

import 'dart:ui' as ui;

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ScannerConfirmScreen extends StatefulWidget {
  static const routeName = '/scanner_confirm';

  @override
  _ScannerConfirmScreenState createState() => _ScannerConfirmScreenState();
}

class _ScannerConfirmScreenState extends State<ScannerConfirmScreen> {
  bool modeCompare = false;
  bool modeOpenDispute = false;
  Map device;
  Map point;
  Map blacklist;
  Map myScan = {};
  Map ownerScan = {};
  bool _isLoading = false;
  bool isPhone = false;
  bool isText = false;
  String comment = '';
  String mode = ConfigCustom.defaultMode;
  int step = 1;
  GlobalKey globalKey = GlobalKey();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Uint8List _pngBytes;
  bool isSave = false;
  String transactionCode = '';

  List questions = [];
  List selectedQuestions = [];

  StreamSubscription subscription;
  ConnectivityResult connect = ConnectivityResult.wifi;

  Future saveComment() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String id = prefs.getString(ConfigCustom.sharedSelectedScanId);
      await Device.saveCommentReport(context, id, comment);
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        Functions.confirmError(context, () {});
      }
    }
    Functions.goToRoute(context, ThankScreen.routeName);
    setState(() {
      _isLoading = false;
    });
  }

  Future _shareFileImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Share.file('Dingtoi MC', 'dingtoimc.png', _pngBytes, 'image/png',
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
    try {
      imageCache.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map _device;
      Map _point = {};
      Map _blacklist;
      bool _isVoice = false;
      bool _isText = false;
      if (!prefs.containsKey(ConfigCustom.sharedPointPhysical)) {
        Functions.goToRoute(context, PhysicalGradingScreen.routeName);
        return;
      }
      if (!prefs.containsKey(ConfigCustom.sharedSelectedScanId)) {
        Functions.goToRoute(context, AskingProScreen.routeName);
        return;
      }
      String customMode = await Functions.getModeType(context);
      if (customMode == ConfigCustom.transactionCodeLockScan) {
        transactionCode = prefs.getString(ConfigCustom.transactionCodeLockScan);
        List list = await Device.listQuestionBuyerReject(context);
        setState(() {
          questions = list;
        });
      }
      if (customMode == ConfigCustom.defaultMode) {
        await User.emptyTimer();
        _device = await Device.detailScanningHistory(
            context, prefs.getString(ConfigCustom.sharedSelectedScanId));
      } else {
        _device = await Device.detailScanningHistoryWeb(
            context, prefs.getString(ConfigCustom.sharedSelectedScanId));
      }

      _point['physicalGrading'] = prefs.get(ConfigCustom.sharedPointPhysical);
      _point['scannerPoint'] =
          _device['main_info'][ConfigCustom.sharedPointScanner];
      _device['main_info'][ConfigCustom.sharedTimestamp] =
          DateTime.tryParse(_device['timestamp'].toString());
      double diamondRating = await _checkRules(_point);
      _point['diamondRating'] = diamondRating;
      if (_device['type'] == ConfigCustom.userPro ||
          _device['type'] == ConfigCustom.userProSummary ||
          _device['type'] == ConfigCustom.userTransaction ||
          _device['type'] == ConfigCustom.userTransactionSummary ||
          customMode == ConfigCustom.transactionCodeLockScan) {
        _blacklist = {
          ConfigCustom.sharedBlacklistStatus: _device['main_info']
              [ConfigCustom.sharedBlacklistStatus],
          ConfigCustom.sharedBlacklistType: _device['main_info']
              [ConfigCustom.sharedBlacklistType],
        };
      }
      if (_device['main_info'].containsKey(ConfigCustom.sharedVoiceInbound)) {
        _isVoice = true;
        _isText = true;
      }
      setState(() {
        device = _device['main_info'];
        point = _point;
        blacklist = _blacklist;
        isPhone = _isVoice;
        isText = _isText;
        mode = customMode;
      });
      _initPaint();
    } catch (error) {
      Functions.goToRoute(context, AskingProScreen.routeName);
    }
  }

  Future<double> _checkRules(point) async {
    double total = double.parse(point['scannerPoint'].toString()) +
        double.parse(point['physicalGrading'].toString());

    double rating = 0;

    if (total < 60) {
      rating = 1;
    } else if (total >= 60 && total <= 69) {
      rating = 2;
    } else if (total >= 70 && total <= 79) {
      rating = 3;
    } else if (total >= 80 && total <= 89) {
      rating = 4;
    } else if (total >= 90 && total <= 100) {
      rating = 5;
    }

    return Future.value(rating);
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
        File file = new File('$tempPath/${ConfigCustom.imageMain}');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        setState(() {
          _pngBytes = byteData.buffer.asUint8List();
        });
        await _confirmReport();
      }
    } catch (error) {
      Functions.goToRoute(context, AskingProScreen.routeName);
    }
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

  Future _confirmReport() async {
    try {
      Map _blacklist = Functions.isEmpty(blacklist) ? {} : blacklist;
      Map obj = {
        ...device,
        ...point,
        ..._blacklist,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();

      String tempPath = await Functions.getTemporaryPath();

      var userPay = prefs.get(ConfigCustom.sharedUserPay);
      if (prefs.containsKey(ConfigCustom.sharedPhoneType)) {
        obj[ConfigCustom.sharedPhoneType] =
            prefs.getString(ConfigCustom.sharedPhoneType);
      }

      String urlSummaryReport =
          await Device.uploadImage('$tempPath/${ConfigCustom.imageMain}');

      obj['url_summary_report'] = urlSummaryReport;

      String id = prefs.getString(ConfigCustom.sharedSelectedScanId);
      String type = ConfigCustom.userFreeSummary;
      if (userPay == ConfigCustom.userPro) {
        type = ConfigCustom.userProSummary;
      } else if (userPay == ConfigCustom.userTransaction) {
        type = ConfigCustom.userTransactionSummary;
      }

      if (transactionCode.isNotEmpty) {
        type = ConfigCustom.transactionCodeLockScanSummary;
      }

      if (mode == ConfigCustom.defaultMode) {
        await Device.updateConfirmReport(
          context,
          id,
          type,
          obj,
        );
      } else if (mode == ConfigCustom.transactionOwnerMode ||
          transactionCode.isNotEmpty) {
        await Device.updateConfirmReportTransactionWeb(
          context,
          id,
          type,
          obj,
        );
      } else {
        await Device.updateConfirmReportWeb(
          context,
          id,
          type,
          obj,
        );
      }
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

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != connect) {
        connect = result;
        _initCheck();
      }
    });
    _initCheck();
  }

  Future logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(ConfigCustom.authToken)) {
        setState(() {
          _isLoading = true;
        });
        await User.logoutLocked(context);
        Functions.goToRoute(context, WelcomeScreen.routeName);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      Functions.confirmError(context, () => {});
    }
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

  Widget widgetComment(appBar) {
    double widthWidget =
        MediaQuery.of(context).size.width - ConfigCustom.globalPadding * 2;
    double width = MediaQuery.of(context).size.width;
    return GestureClickOutside(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: ConfigCustom.colorBgBlendBottom,
            ),
            child: Center(
              child: Container(
                width: widthWidget,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SpaceCustom(),
                      SizedBox(
                        width: width / 2.5,
                        child: Image.asset(
                          'assets/app/com_comment.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SpaceCustom(),
                      SizedBox(
                        child: TextCustom(
                          'Please tell us how we can improve the',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(
                        child: TextCustom('Dingtoi App',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            color: ConfigCustom.colorSecondary),
                      ),
                      SpaceCustom(),
                      SpaceCustom(),
                      TextField(
                        controller: TextEditingController()..text = comment,
                        onChanged: (value) {
                          comment = value;
                        },
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: ConfigCustom.colorWhite,
                        ),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          filled: true,
                          fillColor: ConfigCustom.colorWhite.withOpacity(0.2),
                          hintText: 'Enter your comment...',
                          hintStyle: TextStyle(
                            color: ConfigCustom.colorWhite,
                          ),
                        ),
                      ),
                      SpaceCustom(),
                      SpaceCustom(),
                      Center(
                        child: Container(
                          width: width,
                          child: ButtonCustom(
                            'Submit',
                            onTap: () {
                              saveComment();
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
    );
  }

  Widget widgetMain(appBar) {
    double width = MediaQuery.of(context).size.width;
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
                      Center(child: TimestampGroup(device)),
                      SpaceCustom(),
                      Center(
                        child: TextCustom(
                          "DINGTOI RATING",
                          color: ConfigCustom.colorSecondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: ConfigCustom.letterSpacing,
                        ),
                      ),
                      SpaceCustom(),
                      DiamondRatingGroup(point),
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
                      TouchscreenGroup(device),
                      SpaceCustom(),
                      CameraGroup(device),
                      SpaceCustom(),
                      FlashGroup(device),
                      SpaceCustom(),
                      VolumeGroup(device),
                      SpaceCustom(),
                      SpeakerGroup(device),
                      SpaceCustom(),
                      MicrophoneGroup(device),
                      SpaceCustom(),
                      FingerGroup(device),
                      FaceIdGroup(device),
                      TextGroup('Connection'),
                      SpaceCustom(),
                      WifiGroup(device),
                      SpaceCustom(),
                      BluetoothGroup(device),
                      isPhone ? SpaceCustom() : Center(),
                      isPhone ? TextGroup('Phone') : Center(),
                      isPhone ? SpaceCustom() : Center(),
                      isPhone ? VoiceInGroup(device) : Center(),
                      isPhone ? SpaceCustom() : Center(),
                      isPhone ? VoiceOutGroup(device) : Center(),
                      isText ? SpaceCustom() : Center(),
                      isText ? TextGroup('SMS') : Center(),
                      isText ? SpaceCustom() : Center(),
                      isText ? TextInGroup(device) : Center(),
                      isText ? SpaceCustom() : Center(),
                      isText ? TextOutGroup(device) : Center(),
                      SpaceCustom(),
                      DeviceHeader(device),
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
          child: Row(
            children: [
              // mode == ConfigCustom.transactionCodeLockScan
              //     ? !isSave
              //         ? LoadingWidget()
              //         : Container(
              //             width: width / 2.7,
              //             child: ButtonCustom(
              //               'Compare',
              //               onTap: () {
              //                 setState(() {
              //                   initCompare();
              //                 });
              //               },
              //             ),
              //           )
              //     : Center(),
              SizedBox(
                width: 10,
              ),
              InkWell(
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
                              ))),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Row(
            children: [
              mode == ConfigCustom.defaultMode
                  ? ButtonBottom(
                      step == 1 ? 'Next' : 'Confirm',
                      width,
                      () {
                        if (isSave) {
                          if (step == 1) {
                            setState(() {
                              step = 2;
                            });
                          } else {
                            Functions.goToRoute(context, ThankScreen.routeName);
                          }
                        }
                      },
                      isLoading: !isSave ? true : false,
                    )
                  : ButtonBottom(
                      mode == ConfigCustom.transactionOwnerMode ||
                              mode == ConfigCustom.deviceScanMode
                          ? 'Confirm'
                          : 'Compare Scan',
                      width,
                      () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (isSave) {
                          try {
                            if (mode == ConfigCustom.transactionOwnerMode) {
                              await Device.onwerScanAccept(context);
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              if (prefs.containsKey(
                                  ConfigCustom.transactionCodeOwnerWeb))
                                prefs.setString(
                                    ConfigCustom.transactionCodeLockScan,
                                    prefs.getString(
                                        ConfigCustom.transactionCodeOwnerWeb));
                              await logout();
                              Functions.goToRoute(
                                  context, WelcomeScreen.routeName);
                            } else if (transactionCode.isNotEmpty) {
                              initCompare();
                            } else {
                              Functions.goToRoute(
                                  context, ThankScreen.routeName);
                            }
                          } catch (error) {
                            if (error == ConfigCustom.notFoundInternet) {
                              Functions.confirmAlertConnectivity(
                                  context, () {});
                            } else {
                              Functions.confirmError(context, () {});
                            }
                          }
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      isLoading: !isSave ? true : false,
                    )
            ],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              compareHeader(widthCustom, 'Physical Grading'),
                              Container(
                                height: ConfigCustom.heightWidget,
                                width: widthCustom / 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextCustom(
                                    myScan['physical_grading'],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: widthCustom / 3,
                                height: ConfigCustom.heightWidget,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextCustom(
                                    ownerScan['physical_grading'],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DividerCustom(),
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
              mode == ConfigCustom.defaultMode
                  ? ButtonBottom(
                      step == 1 ? 'Next' : 'Confirm',
                      width,
                      () {
                        if (isSave) {
                          if (step == 1) {
                            setState(() {
                              step = 2;
                            });
                          } else {
                            Functions.goToRoute(context, ThankScreen.routeName);
                          }
                        }
                      },
                      isLoading: !isSave ? true : false,
                    )
                  : ButtonBottom(
                      'Confirm',
                      width,
                      () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (isSave) {
                          try {
                            if (mode == ConfigCustom.transactionOwnerMode) {
                              await Device.onwerScanAccept(context);
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              if (prefs.containsKey(
                                  ConfigCustom.transactionCodeOwnerWeb))
                                prefs.setString(
                                    ConfigCustom.transactionCodeLockScan,
                                    prefs.getString(
                                        ConfigCustom.transactionCodeOwnerWeb));
                              await logout();
                              Functions.goToRoute(
                                  context, WelcomeScreen.routeName);
                            } else if (transactionCode.isNotEmpty) {
                              handleYes();
                            } else {
                              Functions.goToRoute(
                                  context, ThankScreen.routeName);
                            }
                          } catch (error) {
                            if (error == ConfigCustom.notFoundInternet) {
                              Functions.confirmAlertConnectivity(
                                  context, () {});
                            } else {
                              Functions.confirmError(context, () {});
                            }
                          }
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      isLoading: !isSave ? true : false,
                    )
            ],
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

  Future handleYes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Device.transactionBuyerAccept(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(ConfigCustom.transactionCodeLockScan);
      await prefs.remove(ConfigCustom.transactionCodeOwnerWeb);
      Functions.goToRoute(context, ThankScreen.routeName);
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
  Widget build(BuildContext context) {
    Widget widget = Center();
    double widthWidget =
        MediaQuery.of(context).size.width - ConfigCustom.globalPadding * 4;
    PreferredSize appBar;
    if (step == 1) {
      appBar = !isSave
          ? null
          : Functions.getAppbarMainBack(
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
                          : 'Summary Report',
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
            );
      if (modeOpenDispute) {
        widget = widgetOpenDispute(appBar, widthWidget);
      } else if (modeCompare) {
        widget = widgetCompare(appBar);
      } else {
        widget = widgetMain(appBar);
      }
    } else {
      appBar = Functions.getAppbarMainBack(
          context,
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextCustom(
                  'Summary Report',
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
      }, () {
        setState(() {
          step = 1;
        });
      });
      widget = widgetComment(appBar);
    }

    return Container(
      color: ConfigCustom.colorPrimary,
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.transparent,
        key: _drawerKey,
        drawer:
            mode == ConfigCustom.defaultMode ? DrawerCustom() : DrawerScan(),
        body: Container(
          child: WillPopScope(
            onWillPop: () {
              return Functions.confirmScanAgain(context);
            },
            child: Functions.isEmpty(device) ||
                    Functions.isEmpty(point) ||
                    _isLoading
                ? Loading()
                : widget,
          ),
        ),
      ),
    );
  }
}
