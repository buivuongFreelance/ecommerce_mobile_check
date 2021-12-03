import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/widgets/button_custom.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/input_text.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/notify.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ContactScreen extends StatefulWidget {
  static const routeName = '/contact_screen';
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool errorEmail = false;
  bool errorName = false;
  bool errorMessage = false;
  String email;
  String name;
  String company;
  String message;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Future _sendContact() async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => Notify(
            message: 'Send Contact Successfully',
          ),
        );
      } catch (error) {
        if (error == ConfigCustom.notFoundInternet) {
          Functions.confirmAlertConnectivity(context, () {});
        } else {
          Functions.confirmError(context, () {});
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget screenMain() {
    double width = MediaQuery.of(context).size.width;
    return Center(
        child: SingleChildScrollView(
            child: Container(
      padding: EdgeInsets.only(
          left: ConfigCustom.globalPadding, right: ConfigCustom.globalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SpaceCustom(),
          SizedBox(
              width: width - ConfigCustom.globalPadding * 4,
              child: Image.asset("assets/app/com_contact.png")),
          SizedBox(height: 28),
          TextCustom(
            "GET IN TOUCH",
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
          SpaceCustom(),
          SpaceCustom(),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  'NAME',
                  letterSpacing: ConfigCustom.letterSpacing2,
                  fontSize: 12,
                  color: ConfigCustom.colorWhite.withOpacity(0.7),
                ),
                InputText(
                  hint: 'Your name',
                  hintColor: errorName
                      ? ConfigCustom.colorError
                      : ConfigCustom.colorGreyWarm,
                  textInputType: TextInputType.text,
                  onChanged: (String value) {
                    name = value;
                  },
                  validator: (value) {
                    String multiValidator = RequiredValidator(
                      errorText: 'Name is required',
                    ).call(value);
                    setState(() {
                      errorName =
                          Functions.isEmpty(multiValidator) ? false : true;
                    });
                    return multiValidator;
                  },
                  prefixIcon: Icon(
                    Icons.person,
                    color: errorName
                        ? ConfigCustom.colorErrorLight
                        : ConfigCustom.colorGreyWarm.withOpacity(0.6),
                  ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                TextCustom(
                  'EMAIL',
                  letterSpacing: ConfigCustom.letterSpacing2,
                  fontSize: 12,
                  color: ConfigCustom.colorWhite.withOpacity(0.7),
                ),
                InputText(
                  hint: 'Your email',
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
                      errorEmail =
                          Functions.isEmpty(multiValidator) ? false : true;
                    });
                    return multiValidator;
                  },
                  prefixIcon: Icon(
                    Icons.email,
                    color: errorEmail
                        ? ConfigCustom.colorErrorLight
                        : ConfigCustom.colorGreyWarm.withOpacity(0.6),
                  ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                TextCustom(
                  'COMPANY',
                  letterSpacing: ConfigCustom.letterSpacing2,
                  fontSize: 12,
                  color: ConfigCustom.colorWhite.withOpacity(0.7),
                ),
                InputText(
                  hint: 'Your company',
                  textInputType: TextInputType.text,
                  onChanged: (String value) {
                    company = value;
                  },
                  validator: (value) {},
                  prefixIcon: Icon(
                    Icons.location_city,
                    color: ConfigCustom.colorGreyWarm.withOpacity(0.6),
                  ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                TextCustom(
                  'MESSAGE',
                  letterSpacing: ConfigCustom.letterSpacing2,
                  fontSize: 12,
                  color: ConfigCustom.colorWhite.withOpacity(0.7),
                ),
                InputText(
                  hint: 'Your feedback',
                  hintColor: errorMessage
                      ? ConfigCustom.colorError
                      : ConfigCustom.colorGreyWarm,
                  textInputType: TextInputType.multiline,
                  maxLines: 4,
                  onChanged: (String value) {
                    message = value;
                  },
                  validator: (value) {
                    String multiValidator = MultiValidator([
                      RequiredValidator(
                        errorText: 'Message is required',
                      ),
                    ]).call(value);
                    setState(() {
                      errorMessage =
                          Functions.isEmpty(multiValidator) ? false : true;
                    });
                    return multiValidator;
                  },
                  // prefixIcon: Icon(
                  //   Icons.textsms,
                  //   color: errorMessage
                  //       ? ConfigCustom.colorErrorLight
                  //       : ConfigCustom.colorGreyWarm.withOpacity(0.6),
                  // ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                SpaceCustom(),
                Center(
                  child: ButtonCustom(
                    "SEND",
                    onTap: () {
                      _sendContact();
                    },
                  ),
                ),
                SpaceCustom(),
                SpaceCustom(),
                SpaceCustom(),
              ],
            ),
          ),
        ],
      ),
    )));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = screenMain();
    PreferredSize appBar = Functions.getAppbarMainHome(
        context,
        TextCustom(
          'Contact',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      _drawerKey.currentState.openDrawer();
    }, () {
      Functions.goToRoute(context, AskingProScreen.routeName);
    });

    return WillPopScope(
      onWillPop: () {
        Functions.goToRoute(context, AskingProScreen.routeName);
        return Future.value(false);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: ConfigCustom.colorBgBlendBottom,
        ),
        child: _isLoading
            ? Loading()
            : Scaffold(
                key: _drawerKey,
                backgroundColor: Colors.transparent,
                appBar: appBar,
                body: widget,
                drawer: DrawerCustom(),
              ),
      ),
    );
  }
}
