import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/providers/user.dart';
import 'package:dingtoimc/screens/timeout_screen.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

class TimerCustom extends StatefulWidget {
  final bool widget;
  final Function onEndTime;
  final bool inverse;

  TimerCustom({
    this.onEndTime,
    this.widget,
    this.inverse = false,
  });

  @override
  _TimerCustomState createState() => _TimerCustomState();
}

class _TimerCustomState extends State<TimerCustom> {
  Map _user;

  Future init() async {
    Map user = await User.checkUserIsScanning(context);

    setState(() {
      _user = user;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Future endScan() async {
    if (!Functions.isEmpty(_user[ConfigCustom.authScan])) {
      Functions.goToRoute(context, TimeoutScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Functions.isEmpty(_user)
        ? Center()
        : TimerBuilder.scheduled(
            [
              _user[ConfigCustom.authStartTimer],
              _user[ConfigCustom.authEndTimer],
            ],
            builder: (context) {
              final now = DateTime.now();
              final ended =
                  now.compareTo(_user[ConfigCustom.authEndTimer]) >= 0;
              if (ended) {
                endScan();
                return Center();
              } else
                return !widget.widget
                    ? Center()
                    : Container(
                        child: TimerBuilder.periodic(Duration(seconds: 1),
                            alignment: Duration.zero, builder: (context) {
                          final now = DateTime.now();
                          var remaining =
                              _user[ConfigCustom.authEndTimer].difference(now);
                          return TextCustom(
                            'Remaining Time ${Functions.formatDuration(remaining)}',
                            color: !widget.inverse
                                ? ConfigCustom.colorError
                                : ConfigCustom.colorWhite,
                            fontSize: 12,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            fontWeight: FontWeight.w900,
                          );
                        }),
                      );
            },
          );
  }
}
