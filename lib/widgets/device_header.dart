import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';

class DeviceHeader extends StatefulWidget {
  final Map device;

  DeviceHeader(this.device);

  @override
  _DeviceHeaderState createState() => _DeviceHeaderState();
}

class _DeviceHeaderState extends State<DeviceHeader> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Positioned(
            top: 30,
            left: 28,
            child: Container(
              child: Container(
                width: width - ConfigCustom.globalPadding * 2.3,
                height: 185,
                decoration: BoxDecoration(
                  color: ConfigCustom.colorWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            )),
        Positioned(
            top: 19,
            left: 38,
            child: Container(
              child: Container(
                width: width - ConfigCustom.globalPadding * 3.1,
                height: 185,
                decoration: BoxDecoration(
                  color: ConfigCustom.colorWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.only(bottom: 30, top: 30),
          child: Center(
            child: Container(
              height: 185,
              width: width - ConfigCustom.globalPadding * 4,
              padding: EdgeInsets.fromLTRB(
                  ConfigCustom.globalPadding,
                  ConfigCustom.globalPadding / 2,
                  ConfigCustom.globalPadding,
                  ConfigCustom.globalPadding / 2),
              decoration: BoxDecoration(
                color: ConfigCustom.colorWhite.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SpaceCustom(),
                  widget.device.isNotEmpty
                      ? TextCustom(
                          widget.device[ConfigCustom.sharedDeviceModel],
                          fontSize: 18,
                          maxLines: 1,
                        )
                      : null,
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextCustom(
                    'Phone OS - latest version: ${widget.device[ConfigCustom.sharedPointReleased]}',
                    fontSize: 12,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextCustom(
                    'Phone Processor: ${widget.device[ConfigCustom.sharedPointProcessor]}',
                    fontSize: 12,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextCustom(
                    'Storage Capacity: ${widget.device[ConfigCustom.sharedPointStorageUsed]} of ${widget.device[ConfigCustom.sharedPointStorage]} used',
                    fontSize: 12,
                  ),
                  SpaceCustom(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
