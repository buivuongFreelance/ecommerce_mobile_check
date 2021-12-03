import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/button_check.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class FaceIdGroup extends StatefulWidget {
  final Map device;

  FaceIdGroup(this.device);

  @override
  _FaceIdGroupState createState() => _FaceIdGroupState();
}

class _FaceIdGroupState extends State<FaceIdGroup> {
  @override
  Widget build(BuildContext context) {
    return widget.device[ConfigCustom.sharedPointFaceID] == ConfigCustom.nothave
        ? Center()
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(ConfigCustom.globalPadding, 0,
                    ConfigCustom.globalPadding, 0),
                child: Container(
                  height: ConfigCustom.heightBoxScan,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ConfigCustom.borderRadius4),
                    color: widget.device[ConfigCustom.sharedPointFaceID] ==
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
                                topLeft:
                                    Radius.circular(ConfigCustom.borderRadius4),
                                bottomLeft:
                                    Radius.circular(ConfigCustom.borderRadius4),
                              ),
                            ),
                            child: Icon(
                              MaterialCommunityIcons.face_recognition,
                              size: 28,
                              color: widget.device[
                                          ConfigCustom.sharedPointFaceID] ==
                                      ConfigCustom.yes
                                  ? ConfigCustom.colorWhite
                                  : ConfigCustom.colorErrorLight,
                            ),
                          ),
                          Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(15.0, 0, 5.0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TextCustom('Face ID',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: widget.device[ConfigCustom
                                                  .sharedPointFaceID] ==
                                              ConfigCustom.yes
                                          ? ConfigCustom.colorWhite
                                          : ConfigCustom.colorErrorLight),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  TextCustom(
                                    widget.device[ConfigCustom
                                                .sharedPointFaceID] ==
                                            ConfigCustom.yes
                                        ? 'Face ID working'
                                        : 'Face ID not working',
                                    fontSize: 13,
                                    color: widget.device[ConfigCustom
                                                .sharedPointFaceID] ==
                                            ConfigCustom.yes
                                        ? ConfigCustom.colorWhite
                                        : ConfigCustom.colorErrorLight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(
                                right: ConfigCustom.globalPadding),
                            child: Center(
                              child: widget.device[
                                          ConfigCustom.sharedPointFaceID] ==
                                      ConfigCustom.yes
                                  ? ButtonCheck('yes')
                                  : ButtonCheck('no'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SpaceCustom()
            ],
          );
  }
}
