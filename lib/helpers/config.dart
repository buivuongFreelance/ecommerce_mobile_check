import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ConfigCustom {
  static String transactionCodeLockScan = 'transactionCodeLockScan';

  static String errNotExists = 'ERR_NOT_EXISTS';

  static String deviceScanMode = 'deviceScanMode';
  static String defaultMode = 'defaultMode';
  static String transactionOwnerMode = 'transactionOwnerMode';

  static String imageScan = 'dingtoimc.png';
  static String imageMain = 'main.png';
  static String imageTouch = 'touch.png';

  static String errCommon = 'Error Common';
  static String errUsage = 'UsageError';
  static String errImei = 'Error Imei';
  static String errTransactionAuthorized = 'ERR_TRANSACTION_AUTHORIZED';

  static String authFromWeb = 'authFromWeb';
  static String transactionCodeOwnerWeb = 'transactionOwnerWeb';
  static String deviceIdWeb = 'deviceIdWeb';

  static String authToken = 'authToken';
  static String authEmail = 'authEmail';
  static String authUserId = 'authUserId';
  static String authPricePro = 'pricePro';
  static String authWallet = 'wallet';
  static String authScan = 'authScan';
  static String authProItem = 'authProItem';
  static String authTwilioNumber = 'twilioNumber';
  static String authIsPay = 'authIsPay';
  static String authStartTimer = 'authStartTimer';
  static String authEndTimer = 'authEndTimer';
  static String authTimer = 'authTimer';
  static String authTimerBasic = 'authTimerBasic';

  static String notAvailable = 'not_available';
  static String notVerified = 'not_verified';
  static String exists = 'Exists';
  static String notExists = 'Not Exists';
  static String yes = 'y';
  static String no = 'n';
  static String nothave = 'nothave';
  static String pay = 'pay';
  static String clean = 'clean';
  static String isPermanent = 'isPermanent';
  static String isDisabled = 'isDisabled';
  static String isReject = 'isReject';
  static String isLoading = 'isLoading';
  static String isNotReady = 'isNotReady';
  static String userPro = 'pro';
  static String userProSummary = 'pro-summary';
  static String userFree = 'basic';
  static String userFreeSummary = 'basic-summary';
  static String userTransaction = 'transaction';
  static String userTransactionSummary = 'transaction-summary';
  static String all = 'all';
  static String error = 'error';
  static String success = 'success';
  static String auto = 'auto';
  static String manual = 'manual';
  static String others = 'others';
  static int touchscreenRow = 6;
  static int touchscreenCol = 7;
  static String notFoundInternet = 'Not Found Internet';
  static String notFoundKey = 'Not Found Key';

  static String sharedUserPay = 'userPay';
  static String sharedDeviceModel = 'model';
  static String sharedPointTouchScreen = 'touchscreen';
  static String sharedPointProcessor = 'processor';
  static String sharedPointReleased = 'released';
  static String sharedPointStorage = 'storage';
  static String sharedPointStorageUsed = 'storageUsed';
  static String sharedPointCamera = 'camera';
  static String sharedPointFlash = 'flash';
  static String sharedPointVolume = 'volume';
  static String sharedPointMicrophone = 'microphone';
  static String sharedPointWifi = 'wifi';
  static String sharedPointBluetooth = 'bluetooth';
  static String sharedPointFinger = 'finger';
  static String sharedPointFaceID = 'faceID';
  static String sharedPointScanner = 'pointScanner';
  static String sharedPointPhysical = 'physical';
  static String sharedPointDiamond = 'diamond';
  static String sharedTimestamp = 'timestamp';
  static String sharedBacklist = 'blacklist';
  static String sharedBlacklistStatus = 'blacklistStatus';
  static String sharedBlacklistType = 'blacklistType';
  static String sharedVoice = 'voice';
  static String sharedText = 'text';
  static String sharedImei = 'imei';
  static String sharedStep = 'step';
  static String sharedCountryCode = 'countryCode';
  static String sharedSimCarrierName = 'simCarrierName';
  static String sharedSimCountryCode = 'simCountryCode';
  static String sharedSimCountryPhonePrefix = 'simCountryPhonePrefix';
  static String sharedSim = 'sim';
  static String sharedVoiceInbound = 'voiceInbound';
  static String sharedVoiceOutbound = 'voiceOutbound';
  static String sharedTextInbound = 'textInbound';
  static String sharedTextOutbound = 'textOutbound';
  static String sharedPhoneType = 'phoneType';
  static String sharedPhoneNumber = 'phoneNumber';
  static String sharedIsCheckPhoneManual = 'isCheckPhoneManual';
  static String sharedIsCheckTextManual = 'isCheckTextManual';
  static String sharedComment = 'comment';
  static String sharedSelectedScanId = 'selectedScanId';
  static String routerBack = 'routerBack';

  static int timeout = 15;
  static double pngRatio = 2.0;
  static double globalPadding = 24.0;
  static double letterSpacing = 2;
  static double letterSpacing2 = 0.705882;
  static double heightBar = 70;
  static double heightButton = 50;
  static double heightHeadScan = 200;
  static double heightBoxScan = 80;
  static double borderRadius = 20;
  static double borderRadius2 = 45;
  static double borderRadius3 = 30;
  static double borderRadius4 = 10;

  static double heightWidget = 40;

  static Color colorText = const Color(0xFF75829D);
  static Color colorError = const Color(0xFFE76E54);
  static Color colorErrorLight = const Color(0xFFF64E60);
  static Color colorErrorLight2 = const Color(0xFFE6CFCF);
  static Color colorPrimary2 = Color(0xFF3699FF);
  static Color colorDisabled = const Color(0xFFFEFEFE);
  static Color colorReadonly = Colors.grey[300];
  static Color colorReadonly2 = const Color(0xFFAAAAAA);
  static Color colorReadonly3 = const Color(0xFFF6F6F6);
  static Color colorDivider = const Color(0xFFE0E0E0);
  static Color colorPrimaryLight = const Color(0xFFEEF6FF);
  static Color colorShadow = const Color(0xFF888888);
  static Color colorSteel = const Color(0xFF75829D);
  static Color colorVerified = const Color(0xFFFF9800);

  static LinearGradient colorBgLogin = LinearGradient(
    colors: <Color>[Color(0XD5160336), Color(0XD5160336)],
  );

  static LinearGradient colorBgBlendBottom = LinearGradient(colors: [
    const Color(0xFF2F3A97),
    const Color(0xFF091158),
  ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  static LinearGradient colorBgThank = LinearGradient(colors: [
    const Color(0xFFFFFFFF),
    const Color(0xFF75829D),
  ], begin: Alignment.topCenter, end: Alignment.bottomCenter);

  static LinearGradient colorBg = LinearGradient(
    colors: [
      const Color(0xFF2F3A97),
      const Color(0xFF352888),
    ],
    begin: Alignment.topLeft,
    end: Alignment(0.8, 0.0),
  );

  static LinearGradient colorBgSuccess = LinearGradient(
    colors: [
      const Color(0xFF4CAF50),
      const Color(0xFF2AD67F),
    ],
    begin: Alignment.topLeft,
    end: Alignment(0.8, 0.0),
  );

  static LinearGradient colorBgError = LinearGradient(colors: [
    const Color(0xFFE76E54),
    const Color(0xFFF95B45),
  ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  static LinearGradient colorBgCircleOutline = LinearGradient(
    colors: [
      const Color(0xFFFFFFFF).withOpacity(0.3),
      const Color(0xFFFFFFFF).withOpacity(0.0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
  );

  static Color colorWhite = const Color(0xFFFFFFFF);
  static Color colorPrimary = Color(0xFF2F3A97);
  static Color colorSecondary = const Color(0xFFFCDB05);
  static Color colorGrey = const Color(0xFF555555);
  static Color colorGreyWarm = const Color(0xFF888888);
  static Color colorSuccess = const Color(0xFF00CE66);
  static Color colorSuccess1 = const Color(0xFF2AD67F);

  static double pricePro = 1.5;
  static String isLocked = 'IS_LOCKED';
  static String isNormal = 'IS_NORMAL';
  static String isNotValid = 'IS_NOT_VALID';
  static String transactionCodeLockScanSummary =
      'transactionCodeLockScan-summary';

  static String timerOnWeb = 'timerOnWeb';
}
