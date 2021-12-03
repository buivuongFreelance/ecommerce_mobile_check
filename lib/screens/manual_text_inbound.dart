import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/phone_form_screen.dart';
import 'package:dingtoimc/screens/physical_grading_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/button_small.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/input_code.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualTextInboundScreen extends StatefulWidget {
  static const routeName = '/manual_text_inbound';
  @override
  _ManualTextInboundScreenState createState() =>
      _ManualTextInboundScreenState();
}

class _ManualTextInboundScreenState extends State<ManualTextInboundScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool _isLoading = false;
  bool _isNotVerify = false;
  int phoneNumber;
  int step = 1;
  String verificationCode = '';

  bool errorCode = false;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  Future init() async {
    setState(() {
      _isLoading = true;
    });
    if (!await User.auth(context)) return;
    await User.checkUserIsScanning(context);
    await Device.checkUserAnonymous(context);
    await Device.checkScannerBasic(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedText)) {
      if (prefs.get(ConfigCustom.sharedText) != ConfigCustom.yes) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            AskingProScreen.routeName, (Route<dynamic> route) => false);
      } else {
        if (prefs.containsKey(ConfigCustom.sharedPhoneNumber)) {
          phoneNumber = prefs.getInt(ConfigCustom.sharedPhoneNumber);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              AskingProScreen.routeName, (Route<dynamic> route) => false);
        }
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future _saveOutbound() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedText)) {
      if (prefs.get(ConfigCustom.sharedText) == ConfigCustom.yes) {
        const url = 'sms:0906603187';
        if (await canLaunch(url)) {
          await prefs.setString(
              ConfigCustom.sharedTextInbound, ConfigCustom.yes);
          await prefs.setString(
              ConfigCustom.sharedTextOutbound, ConfigCustom.yes);
          await prefs.setString(
              ConfigCustom.sharedIsCheckPhoneManual, ConfigCustom.yes);
        }
      }
    }
    Functions.goToRoute(context, PhysicalGradingScreen.routeName);
  }

  Future _skipToText() async {
    Functions.goToRoute(context, PhysicalGradingScreen.routeName);
  }

  Future _textVerificationCode() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      int _step = 2;
      try {
        await Device.sendVerificationInboundText(
          context,
          phoneNumber.toString(),
          'text_inbound',
          verificationCode,
        );

        setState(() {
          _step = 3;
        });
      } catch (error) {
        if (error == ConfigCustom.notFoundInternet) {
          Functions.confirmAlertConnectivity(context, () {});
        } else if (error == ConfigCustom.notExists) {
          setState(() {
            _isNotVerify = true;
            _errorMessage = 'Verification Code Wrong';
            errorCode = true;
          });
        } else {
          Functions.confirmError(context, () {});
        }
      }

      setState(() {
        _isLoading = false;
        step = _step;
      });
    }
  }

  Future _textInbound() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String type =
          await Device.sendInboundText(context, phoneNumber.toString());

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (type == ConfigCustom.success) {
        if (prefs.containsKey(ConfigCustom.authPricePro) &&
            prefs.containsKey(ConfigCustom.authIsPay)) {
          if (!prefs.getBool(ConfigCustom.authIsPay)) {
            await User.removeWallet(
                context, prefs.getDouble(ConfigCustom.authPricePro));
          }
        }
      }

      setState(() {
        step = 2;
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
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget widgetSuccess(appBar, width) {
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgSuccess,
      ),
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        drawer: DrawerScan(),
        body: Container(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  TimerCustom(
                    widget: false,
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: new BoxDecoration(
                      gradient: ConfigCustom.colorBgCircleOutline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: new BoxDecoration(
                      color: ConfigCustom.colorWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.check,
                    color: ConfigCustom.colorSuccess1,
                    size: 60,
                  ),
                ],
              ),
              SpaceCustom(),
              SpaceCustom(),
              Container(
                width: width / 1.2,
                child: TextCustom(
                  '100% Working Successfully',
                  fontSize: 20,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SpaceCustom(),
              Container(
                width: width / 1.2,
                child: TextCustom(
                  'Congratulations. Now you can continue to scan your phone.',
                  textAlign: TextAlign.center,
                ),
              ),
              SpaceCustom(),
              SpaceCustom(),
              SpaceCustom(),
              SpaceCustom(),
              ButtonSmallCustom(
                'Complete',
                onTap: () {
                  _saveOutbound();
                },
                color: ConfigCustom.colorSuccess,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget widgetVerify(appBar, width) {
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        drawer: DrawerScan(),
        body: Container(
          padding: EdgeInsets.only(
              left: ConfigCustom.globalPadding,
              right: ConfigCustom.globalPadding),
          child: Center(
            child: Container(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TimerCustom(
                        widget: false,
                      ),
                      Container(
                        child: RawMaterialButton(
                          onPressed: () {},
                          elevation: 0.0,
                          fillColor: ConfigCustom.colorPrimary2,
                          child: Icon(
                            MaterialCommunityIcons.message_reply_text,
                            color: ConfigCustom.colorWhite,
                            size: width / 7,
                          ),
                          padding:
                              EdgeInsets.all(ConfigCustom.globalPadding / 1.8),
                          shape: CircleBorder(),
                        ),
                      ),
                      SpaceCustom(),
                      SpaceCustom(),
                      TextCustom(
                        _isNotVerify
                            ? 'Verification Code Wrong'
                            : 'Verification Code',
                        letterSpacing: ConfigCustom.letterSpacing2,
                        color: errorCode
                            ? ConfigCustom.colorError
                            : _isNotVerify
                                ? ConfigCustom.colorError
                                : ConfigCustom.colorWhite,
                      ),
                      SpaceCustom(),
                      InputCode(
                        textInputType: TextInputType.number,
                        hint: 'Your Verification Code',
                        onChanged: (String value) {
                          verificationCode = value;
                        },
                        validator: (value) {
                          String multiValidator = MultiValidator([
                            RequiredValidator(
                              errorText: 'Required Error',
                            ),
                          ]).call(value);
                          setState(
                            () {
                              errorCode = Functions.isEmpty(multiValidator)
                                  ? false
                                  : true;
                              _errorMessage = Functions.isEmpty(multiValidator)
                                  ? ''
                                  : 'Verification Code Is Required';
                            },
                          );
                          return Functions.isEmpty(multiValidator) ? null : '';
                        },
                      ),
                      !_isNotVerify ? Center() : SpaceCustom(),
                      !errorCode
                          ? Center()
                          : TextCustom(
                              _errorMessage,
                              letterSpacing: ConfigCustom.letterSpacing2,
                              color: ConfigCustom.colorError,
                            ),
                      SpaceCustom(),
                      SpaceCustom(),
                      SpaceCustom(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: width / 2.7,
                            child: ButtonCustom(
                              'Skip',
                              colorOutline: ConfigCustom.colorWhite,
                              backgroundColor: Colors.transparent,
                              color: ConfigCustom.colorWhite,
                              onTap: () {
                                _skipToText();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: width / 2.5,
                            child: ButtonCustom(
                              'Send',
                              backgroundColor: ConfigCustom.colorWhite,
                              onTap: () {
                                _textVerificationCode();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget widgetMain(appBar, width) {
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgBlendBottom,
      ),
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        drawer: DrawerScan(),
        body: Container(
          padding: EdgeInsets.only(
              left: ConfigCustom.globalPadding,
              right: ConfigCustom.globalPadding),
          child: Center(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TimerCustom(
                      widget: false,
                    ),
                    Container(
                      child: RawMaterialButton(
                        onPressed: () {},
                        elevation: 0.0,
                        fillColor: ConfigCustom.colorPrimary2,
                        child: Icon(
                          MaterialCommunityIcons.message_reply_text,
                          color: ConfigCustom.colorWhite,
                          size: width / 7,
                        ),
                        padding:
                            EdgeInsets.all(ConfigCustom.globalPadding / 1.8),
                        shape: CircleBorder(),
                      ),
                    ),
                    SpaceCustom(),
                    SpaceCustom(),
                    TextCustom(
                      'CHECK SMS INBOUND',
                      textAlign: TextAlign.center,
                      fontSize: 18,
                      letterSpacing: ConfigCustom.letterSpacing2,
                    ),
                    SpaceCustom(),
                    SpaceCustom(),
                    SpaceCustom(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: width / 2.7,
                          child: ButtonCustom(
                            'Skip',
                            colorOutline: ConfigCustom.colorWhite,
                            backgroundColor: Colors.transparent,
                            color: ConfigCustom.colorWhite,
                            onTap: () {
                              _skipToText();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: width / 2.5,
                          child: ButtonCustom(
                            'Check',
                            onTap: () {
                              _textInbound();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 55),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    PreferredSize appBar = Functions.getAppbarMainBack(
        context,
        TextCustom(
          'Check Voice / SMS',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      _drawerKey.currentState.openDrawer();
    }, () {
      Navigator.of(context).pushNamedAndRemoveUntil(
        PhoneFormScreen.routeName,
        (Route<dynamic> route) => false,
      );
    });

    PreferredSize appBarNotBack = Functions.getAppbarMain(
      context,
      TextCustom(
        'SMS Inbound',
        maxLines: 1,
        fontWeight: FontWeight.w900,
        textAlign: TextAlign.center,
        fontSize: 18,
        letterSpacing: ConfigCustom.letterSpacing2,
      ),
      () {
        _drawerKey.currentState.openDrawer();
      },
    );

    Widget widget = widgetMain(appBar, width);
    if (step == 2) {
      widget = widgetVerify(appBarNotBack, width);
    } else if (step == 3) {
      widget = widgetSuccess(appBarNotBack, width);
    }

    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: _isLoading ? Loading() : widget,
    );
  }
}
