import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/login_screen.dart';
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

import 'asking_pro_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = '/registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String password;
  bool errorEmail = false;
  bool errorPassword = false;
  bool errorConfirmPassword = false;
  bool _isLoading = false;

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

  Future _submitLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await User.login(email, password);
      Navigator.of(context).pushNamedAndRemoveUntil(
          AskingProScreen.routeName, (Route<dynamic> route) => false);
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

  Future _submitRegistration() async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        await User.registration(email, password);
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => Notify(
            message: 'Sign Up Successfully',
            onTap: () {
              _submitLogin();
            },
          ),
        );
      } catch (error) {
        if (error == ConfigCustom.notFoundInternet) {
          Functions.confirmAlertConnectivity(context, () {});
        } else {
          if (error == ConfigCustom.exists) {
            showDialog(
              context: context,
              builder: (BuildContext context) => Notify(
                message: 'Email Exists On Dingtoi !',
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
  Widget build(BuildContext context) {
    final PreferredSize appBar = Functions.getAppbar(
        context,
        TextCustom(
          'Sign Up',
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          maxLines: 1,
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
                            SpaceCustom(),
                            SpaceCustom(),
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
                              prefixIcon: Icon(
                                SimpleLineIcons.envelope,
                                color: errorEmail
                                    ? ConfigCustom.colorError
                                    : ConfigCustom.colorGreyWarm,
                              ),
                              onChanged: (String value) {
                                email = value;
                              },
                              validator: (value) {
                                String multiValidator = MultiValidator([
                                  RequiredValidator(
                                      errorText: 'Email is required'),
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
                              prefixIcon: Icon(
                                SimpleLineIcons.lock,
                                color: errorPassword
                                    ? ConfigCustom.colorError
                                    : ConfigCustom.colorGreyWarm,
                              ),
                              onChanged: (String value) {
                                password = value;
                              },
                              validator: (value) {
                                String multiValidator = MultiValidator([
                                  RequiredValidator(
                                      errorText: 'Password is required'),
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
                            ),
                            SizedBox(
                              height: 36,
                            ),
                            TextCustom(
                              'CONFIRM PASSWORD',
                              letterSpacing: ConfigCustom.letterSpacing2,
                              fontSize: 12,
                              color: ConfigCustom.colorWhite.withOpacity(0.7),
                            ),
                            InputPassword(
                              hint: 'Confirm Password',
                              hintColor: errorConfirmPassword
                                  ? ConfigCustom.colorError
                                  : ConfigCustom.colorGreyWarm,
                              prefixIcon: Icon(
                                SimpleLineIcons.lock,
                                color: errorConfirmPassword
                                    ? ConfigCustom.colorError
                                    : ConfigCustom.colorGreyWarm,
                              ),
                              validator: (value) {
                                String validator = MatchValidator(
                                  errorText: 'Passwords do not match',
                                ).validateMatch(value, password);
                                setState(() {
                                  errorConfirmPassword =
                                      Functions.isEmpty(validator)
                                          ? false
                                          : true;
                                });
                                return validator;
                              },
                            ),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            SpaceCustom(),
                            ButtonCustom(
                              'Sign Up',
                              color: ConfigCustom.colorPrimary,
                              backgroundColor: ConfigCustom.colorWhite,
                              onTap: () {
                                _submitRegistration();
                              },
                            ),
                            SpaceCustom(),
                            ButtonCustom(
                              'Sign In',
                              color: ConfigCustom.colorWhite,
                              backgroundColor: Colors.transparent,
                              colorOutline: ConfigCustom.colorWhite,
                              onTap: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    LoginScreen.routeName,
                                    (Route<dynamic> route) => false);
                              },
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
