import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/manual_call_inbound.dart';
import 'package:dingtoimc/screens/manual_text_inbound.dart';
import 'package:dingtoimc/screens/welcome_phone_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer_scan.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/input_phone.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:dingtoimc/widgets/timer_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asking_pro_screen.dart';

class PhoneFormScreen extends StatefulWidget {
  static const routeName = '/phone-form-screen';
  @override
  _PhoneFormScreenState createState() => _PhoneFormScreenState();
}

class _PhoneFormScreenState extends State<PhoneFormScreen> {
  String phone = '';
  bool _isLoading = false;
  int phoneCode = 1;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool errorPhone = false;

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      Functions.confirmYesNo(
        context,
        'Do you accept your phone: $phone to us',
        () async {
          setState(() {
            _isLoading = true;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt(ConfigCustom.sharedPhoneNumber,
              int.tryParse('${phoneCode.toString()}${phone.toString()}'));

          setState(() {
            _isLoading = false;
          });

          if (prefs.containsKey(ConfigCustom.sharedVoice)) {
            if (prefs.get(ConfigCustom.sharedVoice) == ConfigCustom.yes) {
              if (prefs.containsKey(ConfigCustom.sharedIsCheckPhoneManual)) {
                Functions.goToRoute(context, ManualTextInboundScreen.routeName);
              } else {
                Functions.goToRoute(context, ManualCallInboundScreen.routeName);
              }
            } else {
              if (prefs.containsKey(ConfigCustom.sharedText)) {
                if (prefs.get(ConfigCustom.sharedText) == ConfigCustom.yes) {
                  Functions.goToRoute(
                      context, ManualTextInboundScreen.routeName);
                }
              }
            }
          }
        },
        false,
      );
    }
  }

  Future _init() async {
    setState(() {
      _isLoading = true;
    });
    if (!await User.auth(context)) return;
    await User.checkUserIsScanning(context);
    await Device.checkUserAnonymous(context);
    await Device.checkScannerBasic(context);

    int _phoneCode = 1;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedSimCountryCode)) {
      if (prefs.get(ConfigCustom.sharedSimCountryCode) == 'vn') {
        _phoneCode = 84;
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
    }

    setState(() {
      _isLoading = false;
      phoneCode = _phoneCode;
    });
  }

  Widget widgetMain() {
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
          WelcomePhoneScreen.routeName, (Route<dynamic> route) => false);
    });
    return BackgroundImage(
      child: _isLoading
          ? Loading()
          : Scaffold(
              appBar: appBar,
              backgroundColor: Colors.transparent,
              key: _drawerKey,
              drawer: DrawerScan(),
              body: GestureClickOutside(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(
                        left: ConfigCustom.globalPadding,
                        right: ConfigCustom.globalPadding,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TimerCustom(
                              widget: false,
                            ),
                            Container(
                              width: width / 4,
                              child: Icon(
                                MaterialCommunityIcons.phone_classic,
                                color: ConfigCustom.colorWhite,
                                size: width / 5,
                              ),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            TextCustom(
                              'INPUT YOUR PHONE',
                              letterSpacing: ConfigCustom.letterSpacing2,
                              color: errorPhone
                                  ? ConfigCustom.colorError
                                  : ConfigCustom.colorWhite,
                            ),
                            SpaceCustom(),
                            InputPhone(
                              textInputType: TextInputType.number,
                              phoneCode: phoneCode,
                              hint: 'Your Phone',
                              onChanged: (String value) {
                                phone = value;
                              },
                              validator: (value) {
                                String multiValidator = MultiValidator([
                                  RequiredValidator(
                                    errorText: 'Phone Is Required',
                                  ),
                                  PatternValidator(
                                    r'(^(?:[+0]9)?[0-9]{9,10}$)',
                                    errorText: 'Phone Number is Wrong',
                                  ),
                                ]).call(value);
                                setState(() {
                                  errorPhone = Functions.isEmpty(multiValidator)
                                      ? false
                                      : true;
                                });
                                return multiValidator;
                              },
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            InkWell(
                              onTap: () {
                                Functions.readMoreInfo(
                                    context,
                                    "WHAT CAN I CHECK BY NUMBER PHONE?",
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextCustom(
                                          "You can check voice calls:",
                                          fontSize: 12,
                                        ),
                                        TextCustom(
                                          "- Check voice inbound",
                                          fontSize: 12,
                                        ),
                                        TextCustom(
                                          "- Check voice outbound",
                                          fontSize: 12,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextCustom(
                                          "You can check SMS:",
                                          fontSize: 12,
                                        ),
                                        TextCustom(
                                          "- Check SMS inbound",
                                          fontSize: 12,
                                        ),
                                        TextCustom(
                                          "- Check SMS outbound",
                                          fontSize: 12,
                                        ),
                                      ],
                                    ));
                              },
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      SimpleLineIcons.question,
                                      color: ConfigCustom.colorPrimary2,
                                      size: 22,
                                    ),
                                  ),
                                  TextCustom(
                                    "What can I check by phone number ?",
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: ConfigCustom.colorPrimary2,
                                  )
                                ],
                              ),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            Container(
                              width: width / 2,
                              child: ButtonCustom(
                                'Start',
                                color: ConfigCustom.colorPrimary,
                                backgroundColor: ConfigCustom.colorWhite,
                                onTap: () {
                                  _submit();
                                },
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
              ),
            ),
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = widgetMain();
    return WillPopScope(
      onWillPop: () {
        return Functions.confirmScanAgain(context);
      },
      child: widget,
    );
  }
}
