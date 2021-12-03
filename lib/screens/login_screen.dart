import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/device.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/forgot_password_screen.dart';
import 'package:dingtoimc/screens/lock_phone_screen.dart';
import 'package:dingtoimc/screens/registration_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:dingtoimc/widgets/background_image.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/divider_custom.dart';
import 'package:dingtoimc/widgets/gesture_click_outside.dart';
import 'package:dingtoimc/widgets/input_password.dart';
import 'package:dingtoimc/widgets/input_text.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/notify.dart';
import 'package:dingtoimc/widgets/social_login.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String email;
  String password;
  bool errorEmail = false;
  bool errorPassword = false;
  final _formKey = GlobalKey<FormState>();
  Future _checkAuth() async {
    await User.notAuth(context);
  }

  Future _submitLoginFacebook(user) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!Functions.isEmpty(user.user.email)) {
        bool checkIsPhoneTransactionScan =
            await Device.checkIsPhoneTransactionScan(context);
        if (checkIsPhoneTransactionScan) {
          Map status = await User.loginWithFacebookTransaction(user.user.email);
          if (status.containsKey('error')) {
            if (status['error'] == ConfigCustom.isLocked)
              Functions.confirmSomethingError(
                  context,
                  'You have no authorization to scan this device, are you an exchanger ?',
                  () {});
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                AskingProScreen.routeName, (Route<dynamic> route) => false);
          }
        } else {
          await User.loginWithFacebook(user.user.email);
          Functions.goToRoute(context, AskingProScreen.routeName);
        }
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

  Future _submitLoginApple(id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
        Functions.confirmSomethingError(
            context,
            'You have no authorization to scan this device, are you an exchanger ?',
            () {});
      } else {
        await User.loginWithApple(id);
        Functions.goToRoute(context, AskingProScreen.routeName);
      }
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

  Future _submitLoginGoogle(email) async {
    try {
      setState(() {
        _isLoading = true;
      });
      bool checkIsPhoneTransactionScan =
          await Device.checkIsPhoneTransactionScan(context);
      if (checkIsPhoneTransactionScan) {
        Map status = await User.loginWithGoogleTransaction(email);
        if (status.containsKey('error')) {
          if (status['error'] == ConfigCustom.isLocked)
            Functions.confirmSomethingError(
                context,
                'You have no authorization to scan this device, are you an exchanger ?',
                () {});
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              AskingProScreen.routeName, (Route<dynamic> route) => false);
        }
      } else {
        await User.loginWithGoogle(email);
        Navigator.of(context).pushNamedAndRemoveUntil(
            AskingProScreen.routeName, (Route<dynamic> route) => false);
      }
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

  Future _submitLogin() async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        bool checkIsPhoneTransactionScan =
            await Device.checkIsPhoneTransactionScan(context);

        if (checkIsPhoneTransactionScan) {
          Map status = await User.loginWithTransactionCode(email, password);
          if (status.containsKey('error')) {
            if (status['error'] == ConfigCustom.isLocked)
              Functions.confirmSomethingError(
                  context,
                  'You have no authorization to scan this device, are you an exchanger ?',
                  () {});
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                AskingProScreen.routeName, (Route<dynamic> route) => false);
          }
        } else {
          await User.login(email, password);
          Navigator.of(context).pushNamedAndRemoveUntil(
              AskingProScreen.routeName, (Route<dynamic> route) => false);
        }
        setState(() {
          _isLoading = false;
        });
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
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _checkAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSize appBar = Functions.getAppbar(
        context,
        TextCustom(
          'Sign In',
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(ConfigCustom.transactionCodeLockScan)) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            LockPhoneScreen.routeName, (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            WelcomeScreen.routeName, (Route<dynamic> route) => false);
      }
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
                            SpaceCustom(),
                            SpaceCustom(),
                            SocialLogin(
                              onRegistrationGoogle: (_email) {
                                _submitLoginGoogle(_email);
                              },
                              onRegistrationFacebook: (_user) {
                                _submitLoginFacebook(_user);
                              },
                              onRegistrationApple: (_id) {
                                _submitLoginApple(_id);
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
                                    errorText: 'Email Is Required',
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
                              height: 36,
                            ),
                            TextCustom(
                              'YOUR PASSWORD',
                              letterSpacing: ConfigCustom.letterSpacing2,
                              fontSize: 12,
                              color: ConfigCustom.colorWhite.withOpacity(0.7),
                            ),
                            InputPassword(
                              hint: 'Password',
                              hintColor: errorPassword
                                  ? ConfigCustom.colorError
                                  : ConfigCustom.colorGreyWarm,
                              onChanged: (String value) {
                                password = value;
                              },
                              validator: (value) {
                                String multiValidator = MultiValidator([
                                  RequiredValidator(
                                      errorText: 'Password Is Required'),
                                  MinLengthValidator(6,
                                      errorText:
                                          'Password must be at least 6 digits long')
                                ]).call(value);
                                setState(() {
                                  errorPassword =
                                      Functions.isEmpty(multiValidator)
                                          ? false
                                          : true;
                                });
                                return multiValidator;
                              },
                              prefixIcon: Icon(
                                SimpleLineIcons.lock,
                                color: errorPassword
                                    ? ConfigCustom.colorError
                                    : ConfigCustom.colorGreyWarm,
                              ),
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            ButtonCustom(
                              'Sign In',
                              color: ConfigCustom.colorPrimary,
                              backgroundColor: ConfigCustom.colorWhite,
                              onTap: () {
                                _submitLogin();
                              },
                            ),
                            SpaceCustom(),
                            ButtonCustom(
                              'Sign Up',
                              color: ConfigCustom.colorWhite,
                              backgroundColor: Colors.transparent,
                              colorOutline: ConfigCustom.colorWhite,
                              onTap: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    RegistrationScreen.routeName,
                                    (Route<dynamic> route) => false);
                              },
                            ),
                            SpaceCustom(),
                            InkWell(
                              onTap: () {
                                Functions.goToRoute(
                                    context, ForgotPasswordScreen.routeName);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: TextCustom(
                                  'Forgot Password ?',
                                  color: ConfigCustom.colorPrimary2,
                                  textAlign: TextAlign.center,
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
              ),
            ),
    );
  }
}
