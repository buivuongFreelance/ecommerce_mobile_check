import 'package:dingtoimc/helpers/config.dart';
import 'package:flutter/material.dart';

class BackgroundImage extends StatefulWidget {
  final Widget child;
  final String url;

  const BackgroundImage({
    Key key,
    this.child,
    this.url = 'assets/app/com_background_2.jpeg',
  }) : super(key: key);
  @override
  _BackgroundImageState createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<BackgroundImage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: ConfigCustom.colorBgBlendBottom,
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
