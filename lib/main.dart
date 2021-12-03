import 'package:dingtoimc/screens/ask_blackicloud_screen.dart';
import 'package:dingtoimc/screens/ask_phone_manual_screen.dart';
import 'package:dingtoimc/screens/ask_phone_voice.dart';
import 'package:dingtoimc/screens/ask_transaction_screen.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/screens/asking_user_screen.dart';
import 'package:dingtoimc/screens/auto_phone_voice_screen.dart';
import 'package:dingtoimc/screens/blacklist_status_screen.dart';
import 'package:dingtoimc/screens/confirm_imei_transaction_screen.dart';
import 'package:dingtoimc/screens/contact_screen.dart';
import 'package:dingtoimc/screens/forgot_password_screen.dart';
import 'package:dingtoimc/screens/history_scan_screen.dart';
import 'package:dingtoimc/screens/imei_form_screen.dart';
import 'package:dingtoimc/screens/location_checking_screen.dart';
import 'package:dingtoimc/screens/lock_phone_screen.dart';
import 'package:dingtoimc/screens/login_screen.dart';
import 'package:dingtoimc/screens/manual_call_inbound.dart';
import 'package:dingtoimc/screens/manual_text_inbound.dart';
import 'package:dingtoimc/screens/payment_screen.dart';
import 'package:dingtoimc/screens/phone_form_screen.dart';
import 'package:dingtoimc/screens/privacy_screen.dart';
import 'package:dingtoimc/screens/qr_scan_screen.dart';
import 'package:dingtoimc/screens/qr_scan_transaction_screen.dart';
import 'package:dingtoimc/screens/registration_screen.dart';
import 'package:dingtoimc/screens/sim_checking_screen.dart';
import 'package:dingtoimc/screens/timeout_screen.dart';
import 'package:dingtoimc/screens/touch_screen_fail.dart';
import 'package:dingtoimc/screens/touch_screen_success.dart';
import 'package:dingtoimc/screens/transaction_buyer_confirm_screen.dart';
import 'package:dingtoimc/screens/voice_status_screen.dart';
import 'package:dingtoimc/screens/wallet_screen.dart';
import 'package:dingtoimc/screens/welcome_phone_screen.dart';
import 'package:dingtoimc/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dingtoimc/screens/physical_grading_screen.dart';
import 'package:dingtoimc/screens/scanner_basic_screen.dart';
import 'package:dingtoimc/screens/thank_screen.dart';
import 'package:dingtoimc/screens/touch_screen.dart';
import 'package:dingtoimc/screens/scanner_confirm_screen.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );

    return MaterialApp(
      title: 'Dingtoi MC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'AvenirNext',
      ),
      home: WelcomeScreen(),
      routes: {
        TransactionBuyerConfirmScreen.routeName: (ctx) =>
            TransactionBuyerConfirmScreen(),
        LockPhoneScreen.routeName: (ctx) => LockPhoneScreen(),
        WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
        QrScanScreen.routeName: (ctx) => QrScanScreen(),
        QrScanTransactionScreen.routeName: (ctx) => QrScanTransactionScreen(),
        WelcomePhoneScreen.routeName: (ctx) => WelcomePhoneScreen(),
        LoginScreen.routeName: (ctx) => LoginScreen(),
        RegistrationScreen.routeName: (ctx) => RegistrationScreen(),
        AskingProScreen.routeName: (ctx) => AskingProScreen(),
        AskingUserScreen.routeName: (ctx) => AskingUserScreen(),
        AskingBlacklistIcloudScreen.routeName: (ctx) =>
            AskingBlacklistIcloudScreen(),
        TouchScreen.routeName: (ctx) => TouchScreen(),
        TouchScreenSuccess.routeName: (ctx) => TouchScreenSuccess(),
        TouchScreenFail.routeName: (ctx) => TouchScreenFail(),
        ScannerBasicScreen.routeName: (ctx) => ScannerBasicScreen(),
        ThankScreen.routeName: (ctx) => ThankScreen(),
        PhysicalGradingScreen.routeName: (ctx) => PhysicalGradingScreen(),
        ScannerConfirmScreen.routeName: (ctx) => ScannerConfirmScreen(),
        ImeiFormScreen.routeName: (ctx) => ImeiFormScreen(),
        PhoneFormScreen.routeName: (ctx) => PhoneFormScreen(),
        LocationCheckingScreen.routeName: (ctx) => LocationCheckingScreen(),
        BlacklistStatusScreen.routeName: (ctx) => BlacklistStatusScreen(),
        AskingPhoneVoiceScreen.routeName: (ctx) => AskingPhoneVoiceScreen(),
        SimCheckingScreen.routeName: (ctx) => SimCheckingScreen(),
        VoiceStatusScreen.routeName: (ctx) => VoiceStatusScreen(),
        AskingPhoneVoiceManualScreen.routeName: (ctx) =>
            AskingPhoneVoiceManualScreen(),
        AutoPhoneVoiceManualScreen.routeName: (ctx) =>
            AutoPhoneVoiceManualScreen(),
        ManualCallInboundScreen.routeName: (ctx) => ManualCallInboundScreen(),
        PaymentScreen.routeName: (ctx) => PaymentScreen(),
        WalletScreen.routeName: (ctx) => WalletScreen(),
        ManualTextInboundScreen.routeName: (ctx) => ManualTextInboundScreen(),
        TimeoutScreen.routeName: (ctx) => TimeoutScreen(),
        HistoryScanScreen.routeName: (ctx) => HistoryScanScreen(),
        ForgotPasswordScreen.routeName: (ctx) => ForgotPasswordScreen(),
        PrivacyScreen.routeName: (ctx) => PrivacyScreen(),
        ContactScreen.routeName: (ctx) => ContactScreen(),
        AskTransactionScreen.routeName: (ctx) => AskTransactionScreen(),
        ConfirmImeiTransactionScreen.routeName: (ctx) =>
            ConfirmImeiTransactionScreen(),
      },
    );
  }
}
