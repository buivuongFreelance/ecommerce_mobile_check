import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepProWizard extends StatefulWidget {
  @override
  _StepProWizardState createState() => _StepProWizardState();
}

class _StepProWizardState extends State<StepProWizard> {
  int step = 0;
  String userPay = '';
  Color colorStatusStep1 = Colors.white;
  Color colorStatusStep2 = Colors.white;
  Color colorStatusStep3 = Colors.white;
  Widget iconStatusStep1 = Icon(Icons.check_circle);
  Widget iconStatusStep2 = Icon(Icons.check_circle);
  Widget iconStatusStep3 = Icon(Icons.check_circle);

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(ConfigCustom.sharedStep)) {
      step = prefs.getInt(ConfigCustom.sharedStep);
      if (step == 1) {
        colorStatusStep1 = ConfigCustom.colorSecondary;
        colorStatusStep2 = ConfigCustom.colorText;
        colorStatusStep3 = ConfigCustom.colorText;
        iconStatusStep1 = Icon(Icons.brightness_1,
            color: ConfigCustom.colorSecondary, size: 18);
        iconStatusStep2 =
            Icon(Icons.brightness_1, color: ConfigCustom.colorText, size: 18);
        iconStatusStep3 =
            Icon(Icons.brightness_1, color: ConfigCustom.colorText, size: 18);
      } else if (step == 2) {
        colorStatusStep1 = ConfigCustom.colorSuccess;
        colorStatusStep2 = ConfigCustom.colorSecondary;
        colorStatusStep3 = ConfigCustom.colorText;
        iconStatusStep1 = Icon(Icons.check_circle,
            color: ConfigCustom.colorSuccess, size: 18);
        iconStatusStep2 = Icon(Icons.brightness_1,
            color: ConfigCustom.colorSecondary, size: 18);
        iconStatusStep3 =
            Icon(Icons.brightness_1, color: ConfigCustom.colorText, size: 18);
      } else {
        colorStatusStep1 = ConfigCustom.colorSuccess;
        colorStatusStep2 = ConfigCustom.colorSuccess;
        colorStatusStep3 = ConfigCustom.colorSecondary;
        iconStatusStep1 = Icon(Icons.check_circle,
            color: ConfigCustom.colorSuccess, size: 18);
        iconStatusStep2 = Icon(Icons.check_circle,
            color: ConfigCustom.colorSuccess, size: 18);
        iconStatusStep3 = Icon(Icons.brightness_1,
            color: ConfigCustom.colorSecondary, size: 18);
      }

      setState(() {
        userPay = prefs.getString(ConfigCustom.sharedUserPay);
      });
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Widget pageView() {
    double width = MediaQuery.of(context).size.width;

    if (userPay == ConfigCustom.userPro ||
        userPay == ConfigCustom.userTransaction) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorStatusStep1, width: 1)),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent, width: 4)),
                  child: Container(child: iconStatusStep1),
                ),
              ),
              Container(
                width: 2,
                height: width / 5.5,
                color: colorStatusStep1,
              ),
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorStatusStep2, width: 1)),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent, width: 4)),
                  child: Container(child: iconStatusStep2),
                ),
              ),
              Container(
                width: 2,
                height: width / 5.5,
                color: colorStatusStep3,
              ),
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorStatusStep3, width: 1)),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent, width: 4)),
                  child: Container(child: iconStatusStep3),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Functions.readMoreInfo(
                      context,
                      "CHECK GENERAL",
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                              "- Check model, storage, version, processor",
                              fontSize: 14),
                          TextCustom("- Check Touchscreen", fontSize: 14),
                          TextCustom("- Check Camera and Flash", fontSize: 14),
                          TextCustom("- Check Volume and Speaker",
                              fontSize: 14),
                          TextCustom("- Check Microphone", fontSize: 14),
                          TextCustom("- Check Wi-fi and Bluetooth",
                              fontSize: 14),
                        ],
                      ));
                },
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: ConfigCustom.globalPadding / 3,
                          right: ConfigCustom.globalPadding / 3,
                          top: ConfigCustom.globalPadding / 8),
                      child: TextCustom(
                        'CHECK GENERAL',
                        maxLines: 1,
                        fontSize: 12,
                        letterSpacing: ConfigCustom.letterSpacing2,
                        fontWeight: FontWeight.w900,
                        color: step == 1
                            ? ConfigCustom.colorSecondary
                            : ConfigCustom.colorWhite,
                      ),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: step == 1
                          ? ConfigCustom.colorSecondary
                          : ConfigCustom.colorWhite,
                      size: 18,
                    )
                  ],
                ),
              ),
              SizedBox(height: width / 5),
              InkWell(
                onTap: () {
                  Functions.readMoreInfo(
                      context,
                      "CHECK VOICE / SMS",
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            "Cheking voice outbound/ voice inbound and SMS outbound/ SMS inbound",
                            fontSize: 14,
                            maxLines: 10,
                          ),
                        ],
                      ));
                },
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: ConfigCustom.globalPadding / 3,
                          right: ConfigCustom.globalPadding / 3,
                          top: ConfigCustom.globalPadding / 8),
                      child: TextCustom(
                        'CHECK VOICE/ SMS',
                        fontSize: 12,
                        color: step == 2
                            ? ConfigCustom.colorSecondary
                            : ConfigCustom.colorWhite,
                        letterSpacing: ConfigCustom.letterSpacing2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: step == 2
                          ? ConfigCustom.colorSecondary
                          : ConfigCustom.colorWhite,
                      size: 18,
                    )
                  ],
                ),
              ),
              SizedBox(height: width / 5),
              InkWell(
                onTap: () {
                  Functions.readMoreInfo(
                      context,
                      "CHECK BLACKLIST",
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            "The blacklist is a shared database that lists smartphones that have been reported lost/stolen.",
                            fontSize: 14,
                            maxLines: 10,
                          ),
                        ],
                      ));
                },
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: ConfigCustom.globalPadding / 3,
                          right: ConfigCustom.globalPadding / 3,
                          top: ConfigCustom.globalPadding / 8),
                      child: TextCustom(
                        'CHECK BLACKLIST',
                        color: step == 3
                            ? ConfigCustom.colorSecondary
                            : ConfigCustom.colorWhite,
                        fontSize: 12,
                        letterSpacing: ConfigCustom.letterSpacing2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: step == 3
                          ? ConfigCustom.colorSecondary
                          : ConfigCustom.colorWhite,
                      size: 18,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: ConfigCustom.colorSecondary, width: 1)),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.transparent, width: 5)),
                    child: Container(
                      padding: EdgeInsets.all(ConfigCustom.globalPadding / 4),
                      decoration: BoxDecoration(
                        color: ConfigCustom.colorSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Functions.readMoreInfo(
                        context,
                        "CHECK GENERAL",
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(
                                "- Check model, storage, version, processor",
                                fontSize: 14),
                            TextCustom("- Check Touchscreen", fontSize: 14),
                            TextCustom("- Check Camera and Flash",
                                fontSize: 14),
                            TextCustom("- Check Volume and Speaker",
                                fontSize: 14),
                            TextCustom("- Check Microphone", fontSize: 14),
                            TextCustom("- Check Wi-fi and Bluetooth",
                                fontSize: 14),
                          ],
                        ));
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: ConfigCustom.globalPadding / 3,
                            right: ConfigCustom.globalPadding / 3,
                            top: ConfigCustom.globalPadding / 8),
                        child: TextCustom(
                          'CHECK GENERAL',
                          maxLines: 1,
                          fontSize: 12,
                          letterSpacing: ConfigCustom.letterSpacing2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Icon(
                        Icons.info_outline,
                        color: ConfigCustom.colorWhite,
                        size: 18,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(ConfigCustom.globalPadding, 0,
                ConfigCustom.globalPadding, ConfigCustom.globalPadding / 1.5),
            child: TextCustom("You are at current step:")),
        Container(
            padding: EdgeInsets.fromLTRB(
                ConfigCustom.globalPadding,
                ConfigCustom.globalPadding,
                ConfigCustom.globalPadding,
                ConfigCustom.globalPadding),
            decoration:
                BoxDecoration(color: ConfigCustom.colorWhite.withOpacity(0.1)),
            child: pageView()),
      ],
    );
  }
}
