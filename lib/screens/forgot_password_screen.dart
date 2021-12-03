import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/login_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/divider_custom.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/input_text.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/notify.dart';
import 'package:dingtoimc/widgets/social_login.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot_password';
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  String email;
  bool errorEmail = false;
  final _formKey = GlobalKey<FormState>();
  String _widget = 'main';

  Future _checkAuth() async {
    await User.notAuth(context);
  }

  Future _submitLoginFacebook(user) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!Functions.isEmpty(user.user.email)) {
        await User.loginWithFacebook(user.user.email);
        Functions.goToRoute(context, AskingProScreen.routeName);
      } else {
        Functions.confirmSomethingError(
            context,
            'Your Facebook do not have an email. Dingtoi user must have an email.',
            () {});
      }
    } catch (error) {
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        if (error == ConfigCustom.errCommon) {
          showDialog(
            context: context,
            builder: (BuildContext context) => Notify(
              message: 'Email Or Password Wrong !',
              type: 'error',
            ),
          );
        } else
          Functions.confirmError(context, () {});
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future _submitLoginGoogle(email) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await User.loginWithGoogle(email);
      Functions.goToRoute(context, AskingProScreen.routeName);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error == ConfigCustom.notFoundInternet) {
        Functions.confirmAlertConnectivity(context, () {});
      } else {
        if (error == ConfigCustom.errCommon) {
          showDialog(
            context: context,
            builder: (BuildContext context) => Notify(
              message: 'Email Or Password Wrong !',
              type: 'error',
            ),
          );
        } else
          Functions.confirmError(context, () {});
      }
    }
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await User.forgotPassword(email);

        setState(() {
          _widget = 'success';
        });
      } catch (error) {
        if (error == ConfigCustom.notFoundInternet) {
          Functions.confirmAlertConnectivity(context, () {});
        } else {
          if (error == ConfigCustom.notExists) {
            Functions.confirmOkModel(
                context, 'Your email is not exists on Dingtoi !', () {});
          } else
            Functions.confirmError(context, () {});
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _checkAuth();
    super.initState();
  }

  Widget widgetSuccess() {
    double width = MediaQuery.of(context).size.width;
    final PreferredSize appBar = Functions.getAppbar(
        context,
        TextCustom(
          'Forgot Password',
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName, (Route<dynamic> route) => false);
    });
    return Container(
      decoration: BoxDecoration(
        gradient: ConfigCustom.colorBgSuccess,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: Container(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
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
                  'You should soon receive an email allowing you to reset your password.',
                  fontSize: 20,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SpaceCustom(),
              Container(
                width: width / 1.2,
                child: TextCustom(
                  'Please make sure to check your spam and trash if you can\'t find the email.',
                  textAlign: TextAlign.center,
                ),
              ),
              SpaceCustom(),
              SpaceCustom(),
              SpaceCustom(),
              SpaceCustom(),
              Container(
                width: width / 1.5,
                child: ButtonCustom(
                  'BACK TO LOGIN',
                  onTap: () {
                    Functions.goToRoute(context, LoginScreen.routeName);
                  },
                  backgroundColor: ConfigCustom.colorWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget widgetMain() {
    final PreferredSize appBar = Functions.getAppbar(
        context,
        TextCustom(
          'Forgot Password',
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName, (Route<dynamic> route) => false);
    });

    return BackgroundImage(
      child: _isLoading
          ? Loading()
          : Scaffold(
              backgroundColor: Colors.transparent,
              appBar: appBar,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SocialLogin(
                              onRegistrationGoogle: (_email) {
                                _submitLoginGoogle(_email);
                              },
                              onRegistrationFacebook: (_user) {
                                _submitLoginFacebook(_user);
                              },
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: DividerCustom(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: ConfigCustom.globalPadding / 2,
                                      left: ConfigCustom.globalPadding / 2),
                                  child: TextCustom(
                                    'OR',
                                    color: ConfigCustom.colorWhite
                                        .withOpacity(0.7),
                                  ),
                                ),
                                Expanded(
                                  child: DividerCustom(),
                                ),
                              ],
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            TextCustom(
                              'YOUR EMAIL',
                              letterSpacing: ConfigCustom.letterSpacing2,
                              fontSize: 12,
                              color: ConfigCustom.colorWhite.withOpacity(0.7),
                            ),
                            InputText(
                              hint: 'Email',
                              hintColor: errorEmail
                                  ? ConfigCustom.colorError
                                  : ConfigCustom.colorGreyWarm,
                              textInputType: TextInputType.emailAddress,
                              onChanged: (String value) {
                                email = value;
                              },
                              validator: (value) {
                                String multiValidator = MultiValidator([
                                  RequiredValidator(
                                    errorText: 'Email is required',
                                  ),
                                  EmailValidator(
                                    errorText: 'Invalid Email Address',
                                  ),
                                ]).call(value);
                                setState(() {
                                  errorEmail = Functions.isEmpty(multiValidator)
                                      ? false
                                      : true;
                                });
                                return multiValidator;
                              },
                              prefixIcon: Icon(
                                SimpleLineIcons.envelope,
                                color: errorEmail
                                    ? ConfigCustom.colorError
                                    : ConfigCustom.colorGreyWarm,
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            ButtonCustom(
                              'Send',
                              color: ConfigCustom.colorPrimary,
                              backgroundColor: ConfigCustom.colorWhite,
                              onTap: () {
                                _submit();
                              },
                            ),
                            SpaceCustom(),
                            ButtonCustom(
                              'Sign In',
                              color: ConfigCustom.colorWhite,
                              backgroundColor: Colors.transparent,
                              colorOutline: ConfigCustom.colorWhite,
                              onTap: () {
                                Functions.goToRoute(
                                    context, LoginScreen.routeName);
                              },
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

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (_widget == 'main') {
      widget = widgetMain();
    } else if (_widget == 'success') {
      widget = widgetSuccess();
    }

    return widget;
  }
}
