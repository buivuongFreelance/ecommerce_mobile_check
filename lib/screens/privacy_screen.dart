import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScreen extends StatefulWidget {
  static const routeName = '/privacy_screen';
  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isLoading = false;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Future sendMail(email, subject) async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto', path: email, queryParameters: {'subject': subject});

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      Functions.confirmOkModel(
          context, 'System do not have email sender', () {});
    }
  }

  Future launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget screenMain() {
    return Container(
      padding: EdgeInsets.only(
          left: ConfigCustom.globalPadding, right: ConfigCustom.globalPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SpaceCustom(),
            TextCustom(
              "Dingtoi Corporation Privacy Policy",
              fontSize: 16,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'This Privacy Policy describes how your personal information is collected, used and shared when you visit or perform a transaction on ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Dingtoi.com (the "Site")',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: ' or when using the '),
                  TextSpan(
                      text: 'Dingtoi Scanner App (the "App"). ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: '"Dingtoi Lite"',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: ' and '),
                  TextSpan(
                      text: '"Dingtoi Pro"',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          ' are free and premium versions, respectively, of the App. '),
                ],
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text: 'The ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: '"marketplace"',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          ' refers to the Site’s online buy, sell and trade platform for used smartphone shoppers and sellers.'),
                ],
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'The Dingtoi Lite Scanner App can be downloaded on Google Play and Apple App Store. The Dingtoi Pro Scanner App will be available in late August 2020.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text: '"Dingtoi Rating" ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        'is the rating given by the Dingtoi Scanner App after performing a diagnostic scan on a phone. The diagnostic scan generates a ',
                    style: TextStyle(fontWeight: FontWeight.w100),
                  ),
                  TextSpan(
                    text: '"Summary Report"',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' on the App.',
                    style: TextStyle(fontWeight: FontWeight.w100),
                  ),
                ],
              ),
            ),
            SpaceCustom(),
            TextCustom(
              "PERSONAL INFORMATION WE COLLECT",
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'When you visit the Site, we automatically collect certain information about your device, including information about your web browser, IP address, time zone and some of the cookies that are installed on your device. Additionally, as you browse the Site, we collect information about the products that you view. We refer to this collective data as ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: '"Device Information."',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'We collect Device Information using the following technologies:',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    '- "Cookies" are data files that are placed on your device or computer and often include an anonymous unique identifier. For more information about cookies, and how to disable cookies, visit ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchURL('http://www.allaboutcookies.org');
                        },
                      text: 'http://www.allaboutcookies.org.',
                      style: TextStyle(
                          fontWeight: FontWeight.w100,
                          color: ConfigCustom.colorPrimary2)),
                ],
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    '- "Log files" track actions occurring on the Site, and collect data including your IP address, browser type, Internet service provider, referring/exit pages, and date/time stamps.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    '- "Web beacons", "tags", and "pixels" are electronic files used to record information about how you browse the Site.',
                style: TextStyle(
                  fontFamily: 'AvenirNext',
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'Furthermore, when you register and create an account through Dingtoi.com, we collect certain information from you, including your name, billing address, shipping address, payment information (including PayPal information), email address and phone number.  We refer to this information as "Order Information."',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'In this Privacy Policy, "Personal Information" includes both Device Information and Order Information.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            TextCustom(
              "HOW DO WE USE YOUR PERSONAL INFORMATION?",
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'We use the Order Information that we collect to fulfill any transactions (sales and/or purchases) placed through the Site (including processing your payment information, arranging for shipping, and providing you with invoices and/or order confirmations).  In addition, we use this Order Information to: (i) communicate with you; (ii) screen our orders for potential risk or fraud; (iii) and when in line with the preferences you have shared with us, provide you with information or advertising relating to our products or services.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'We use the Device Information that we collect to help us screen for potential risk and fraud (in particular, your IP address), and more generally to improve and optimize our Site (for example, by generating analytics about how our customers browse and interact with the Site, and to assess the success of our marketing and advertising campaigns).',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'We also collect information on transactions performed on the Site (including brands of phones sold or posted, selling prices of phones, Dingtoi Ratings and Scan Reports of phones) in order to help guide buyers and sellers on a fair marketplace value for used smartphones.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'Furthermore, any additional information that you voluntarily provide through surveys (from the Site or from the App) will be used to optimize the services provided on the site and to improve our App.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            TextCustom(
              "SHARING YOUR PERSONAL INFORMATION ",
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'Your Personal Information will be used primarily by Dingtoi Corporation and its employees for reasons stated above.  If you use the Dingtoi Pro Scanner App, your Device IMEI (International Mobile Equipment Identity) will be shared with third parties strictly to check against blacklisted, stolen and iCloud locked registries, with the goal to ensure that the scanned phone is not stolen. Your Order Information will never be shared with third parties, unless for reasons stated within this Policy.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'Finally, we may also share your Personal Information to comply with applicable laws and regulations, to respond to a subpoena, search warrant or other lawful request for information we receive, or to otherwise protect our rights.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'As described above, we use your Personal Information to provide you with targeted advertisements or marketing communications we believe may be of interest to you.  For more information about how targeted advertising works, you can visit the Network Advertising Initiative’s ("NAI") educational page at ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchURL(
                              'http://www.networkadvertising.org/understanding-online-advertising/how-does-it-work');
                        },
                      text:
                          'http://www.networkadvertising.org/understanding-online-advertising/how-does-it-work.',
                      style: TextStyle(color: ConfigCustom.colorPrimary2)),
                ],
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'You can opt out of targeted advertising by sending your request to ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          sendMail('dingtoi.inc@gmail.com', '');
                        },
                      text: 'us.',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ConfigCustom.colorPrimary2)),
                ],
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'Additionally, you can opt out of some of these services by visiting the Digital Advertising Alliance’s opt-out portal at: ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchURL('http://optout.aboutads.info/');
                        },
                      text: 'http://optout.aboutads.info/.',
                      style: TextStyle(color: ConfigCustom.colorPrimary2)),
                ],
              ),
            ),
            SpaceCustom(),
            TextCustom(
              "DO NOT TRACK",
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'Please note that we do not alter our Site’s data collection and use practices when we see a Do Not Track signal from your browser.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            TextCustom(
              "DATA RETENTION",
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'When you perform a transaction through the Site, we will maintain your Order Information for our records unless and until you ask us to delete this information.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'The Site is not intended for individuals under the age of 18.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            TextCustom(
              "CHANGES",
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'We may update this privacy policy from time to time in order to reflect, for example, changes to our practices or for other operational, legal or regulatory reasons.',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
              ),
            ),
            SpaceCustom(),
            TextCustom(
              "CONTACT US",
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            SpaceCustom(),
            RichText(
              text: TextSpan(
                text:
                    'For more information about our privacy practices, if you have questions, or if you would like to make a complaint, please contact us by ',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  fontFamily: 'AvenirNext',
                ),
                children: <TextSpan>[
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          sendMail('dingtoicorp.it@gmail.com', '');
                        },
                      text: 'e-mail.',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ConfigCustom.colorPrimary2)),
                ],
              ),
            ),
            SpaceCustom(),
            SpaceCustom(),
          ],
        ),
      ),
    );
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
          'Privacy Policy',
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
