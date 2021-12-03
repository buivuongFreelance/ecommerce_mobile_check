import 'dart:io';
import 'dart:typed_data';

import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'loading.dart';

class TouchScreenStatic extends StatefulWidget {
  final List list;
  final String route;

  TouchScreenStatic(this.list, this.route);
  @override
  _TouchScreenStaticState createState() => _TouchScreenStaticState();
}

class _TouchScreenStaticState extends State<TouchScreenStatic> {
  List<Widget> _rectangles = [];
  GlobalKey globalKey = GlobalKey();

  Future _initPaint() async {
    try {
      if (Functions.isEmpty(globalKey.currentContext)) {
        await Future.delayed(const Duration(seconds: 2));
        _initPaint();
      } else {
        var renderObject = globalKey.currentContext.findRenderObject();
        RenderRepaintBoundary boundary = renderObject;
        ui.Image captureImage =
            await boundary.toImage(pixelRatio: ConfigCustom.pngRatio);
        ByteData byteData =
            await captureImage.toByteData(format: ui.ImageByteFormat.png);
        String tempPath = await Functions.getTemporaryPath();
        File file = new File('$tempPath/${ConfigCustom.imageTouch}');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        Navigator.of(globalKey.currentContext).pushNamedAndRemoveUntil(
            widget.route, (Route<dynamic> route) => false);
      }
    } catch (error) {}
  }

  @override
  void initState() {
    refreshRectangles();
    _initPaint();
    super.initState();
  }

  refreshRectangles() {
    List<Widget> rectangles = [];
    try {
      for (var i = 0;
          i < ConfigCustom.touchscreenRow * ConfigCustom.touchscreenCol;
          i++) {
        rectangles.add(
          Container(
            decoration: BoxDecoration(
                color: widget.list[i]['checked']
                    ? ConfigCustom.colorPrimary
                    : Colors.white,
                border: Border.fromBorderSide(BorderSide.none)),
          ),
        );
      }

      setState(() {
        _rectangles = rectangles;
      });
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth =
        MediaQuery.of(context).size.width / ConfigCustom.touchscreenRow;
    double itemHeight =
        MediaQuery.of(context).size.height / ConfigCustom.touchscreenCol;

    return Container(
      child: Stack(
        children: <Widget>[
          RepaintBoundary(
            key: globalKey,
            child: Container(
              color: ConfigCustom.colorWhite,
              child: GridView.extent(
                maxCrossAxisExtent: itemWidth,
                childAspectRatio: itemWidth / itemHeight,
                padding: const EdgeInsets.all(0),
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                children: _rectangles,
              ),
            ),
          ),
          Loading(),
        ],
      ),
    );
  }
}
