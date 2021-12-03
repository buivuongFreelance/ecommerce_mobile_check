import 'dart:io';

import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/button_check.dart';
import 'package:dingtoimc/widgets/button_transparent.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class TouchscreenGroup extends StatefulWidget {
  final Map device;
  final String image;

  TouchscreenGroup(
    this.device, {
    this.image = '',
  });

  @override
  _TouchscreenGroupState createState() => _TouchscreenGroupState();
}

class _TouchscreenGroupState extends State<TouchscreenGroup> {
  var config = ConfigCustom();

  Future _showError() async {
    if (widget.image.isEmpty) {
      String path = await Functions.getTemporaryPath();
      File file = new File('$path/${ConfigCustom.imageTouch}');
      return showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext bc) {
                return Stack(
                  children: <Widget>[
                    Image.file(file),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ButtonTransparent('OK', () {
                        Navigator.of(context).pop();
                      }),
                    ),
                  ],
                );
              }) ??
          false;
    } else {
      return showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext bc) {
                return Stack(
                  children: <Widget>[
                    Image.network(widget.image),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ButtonTransparent('OK', () {
                        Navigator.of(context).pop();
                      }),
                    ),
                  ],
                );
              }) ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.device[ConfigCustom.sharedPointTouchScreen] ==
            ConfigCustom.no) _showError();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            ConfigCustom.globalPadding, 0, ConfigCustom.globalPadding, 0),
        child: Container(
          height: ConfigCustom.heightBoxScan,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ConfigCustom.borderRadius4),
            color: widget.device[ConfigCustom.sharedPointTouchScreen] ==
                    ConfigCustom.yes
                ? ConfigCustom.colorWhite.withOpacity(0.3)
                : ConfigCustom.colorErrorLight.withOpacity(0.3),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: ConfigCustom.heightBoxScan,
                    decoration: BoxDecoration(
                      color: ConfigCustom.colorWhite.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ConfigCustom.borderRadius4),
                        bottomLeft: Radius.circular(ConfigCustom.borderRadius4),
                      ),
                    ),
                    child: Icon(
                      Ionicons.ios_phone_portrait,
                      size: 42,
                      color:
                          widget.device[ConfigCustom.sharedPointTouchScreen] ==
                                  ConfigCustom.yes
                              ? ConfigCustom.colorWhite
                              : ConfigCustom.colorErrorLight,
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 0, 5.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextCustom('Touch screen',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: widget.device[ConfigCustom
                                          .sharedPointTouchScreen] ==
                                      ConfigCustom.yes
                                  ? ConfigCustom.colorWhite
                                  : ConfigCustom.colorErrorLight),
                          SizedBox(
                            height: 3,
                          ),
                          TextCustom(
                            widget.device[
                                        ConfigCustom.sharedPointTouchScreen] ==
                                    ConfigCustom.yes
                                ? 'Touchscreen working'
                                : 'Touchscreen not working',
                            fontSize: 13,
                            color: widget.device[
                                        ConfigCustom.sharedPointTouchScreen] ==
                                    ConfigCustom.yes
                                ? ConfigCustom.colorWhite
                                : ConfigCustom.colorErrorLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  widget.device[ConfigCustom.sharedPointTouchScreen] ==
                          ConfigCustom.yes
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: ConfigCustom.globalPadding),
                          child: Center(
                            child: widget.device[
                                        ConfigCustom.sharedPointTouchScreen] ==
                                    ConfigCustom.yes
                                ? ButtonCheck('yes')
                                : ButtonCheck('no'),
                          ),
                        )
                      : Container(
                          height: ConfigCustom.heightBoxScan,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Center(
                                  child: widget.device[ConfigCustom
                                              .sharedPointTouchScreen] ==
                                          ConfigCustom.yes
                                      ? ButtonCheck('yes')
                                      : ButtonCheck('no'),
                                ),
                              ),
                              Container(
                                width: 53,
                                height: 20,
                                child: Center(
                                    child: TextCustom(
                                  'Show',
                                  fontSize: 8,
                                )),
                                decoration: BoxDecoration(
                                  color: ConfigCustom.colorErrorLight,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(60.0),
                                    bottomRight: const Radius.circular(40),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
