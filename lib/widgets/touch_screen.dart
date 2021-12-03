import 'package:animator/animator.dart';
import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/screens/touch_screen_fail.dart';
import 'package:dingtoimc/screens/touch_screen_success.dart';
import 'package:dingtoimc/widgets/button_transparent.dart';
import 'package:dingtoimc/widgets/touchscreen_static.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TouchScreenCustom extends StatefulWidget {
  @override
  _TouchScreenCustomState createState() => _TouchScreenCustomState();
}

class _TouchScreenCustomState extends State<TouchScreenCustom> {
  List<Widget> _rectangles = [];
  List _touchChecked = [];
  int _numChecked = 0;
  bool _isTouch = false;
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    List touchChecked = [];

    for (int i = 0;
        i < ConfigCustom.touchscreenRow * ConfigCustom.touchscreenCol;
        i++) {
      touchChecked.add({
        'checked': false,
      });
    }

    setState(() {
      _touchChecked = touchChecked;
    });
    refreshRectangles();
    super.didChangeDependencies();
  }

  calculateToDraw(Offset position) {
    double itemWidth =
        MediaQuery.of(context).size.width / ConfigCustom.touchscreenRow;
    double itemHeight =
        MediaQuery.of(context).size.height / ConfigCustom.touchscreenCol;

    try {
      int _row = (position.dx / itemWidth).ceil();
      int _col = (position.dy / itemHeight).ceil();
      int _index = (_row + ((_col - 1) * ConfigCustom.touchscreenRow)) - 1;
      if (!_touchChecked[_index]['checked']) {
        _numChecked++;
        setState(() {
          _touchChecked[_index]['checked'] = true;
        });
        refreshRectangles();
      }
    } catch (error) {}
  }

  forceToDraw(index) {
    if (!_touchChecked[index]['checked']) {
      _numChecked++;
      setState(() {
        _touchChecked[index]['checked'] = true;
      });
      refreshRectangles();
    }
  }

  checkTouch(value) {
    if (value != _isTouch)
      setState(() {
        _isTouch = value;
      });
  }

  _showStatic(String route) {
    return showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext bc) {
              return TouchScreenStatic(List.from(_touchChecked), route);
            }) ??
        false;
  }

  refreshRectangles() {
    List<Widget> rectangles = [];
    for (var i = 0;
        i < ConfigCustom.touchscreenRow * ConfigCustom.touchscreenCol;
        i++) {
      rectangles.add(GestureDetector(
        onTap: () {
          checkTouch(false);
          forceToDraw(i);
        },
        onTapDown: (_) {
          checkTouch(true);
          forceToDraw(i);
        },
        onHorizontalDragDown: (_) {},
        onHorizontalDragStart: (DragStartDetails details) {
          checkTouch(true);
          calculateToDraw(details.globalPosition);
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          calculateToDraw(details.globalPosition);
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          forceToDraw(i);
          checkTouch(false);
        },
        onVerticalDragDown: (_) {
          forceToDraw(i);
        },
        onVerticalDragStart: (DragStartDetails details) {
          checkTouch(true);
          calculateToDraw(details.globalPosition);
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          calculateToDraw(details.globalPosition);
        },
        onVerticalDragEnd: (DragEndDetails details) {
          forceToDraw(i);
          checkTouch(false);
        },
        child: Container(
          decoration: BoxDecoration(
              color: _touchChecked[i]['checked']
                  ? ConfigCustom.colorPrimary
                  : _numChecked > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
              border: Border.fromBorderSide(BorderSide.none)),
        ),
      ));
    }

    setState(() {
      _rectangles = rectangles;
    });

    if (_numChecked ==
        ConfigCustom.touchscreenRow * ConfigCustom.touchscreenCol) {
      _showStatic(TouchScreenSuccess.routeName);
      return;
    }
  }

  Future _next() async {
    _showStatic(TouchScreenFail.routeName);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double itemWidth =
        MediaQuery.of(context).size.width / ConfigCustom.touchscreenRow;
    double itemHeight =
        MediaQuery.of(context).size.height / ConfigCustom.touchscreenCol;

    return Container(
      color: _numChecked > 0 ? ConfigCustom.colorPrimary : Colors.white,
      child: Stack(
        children: <Widget>[
          _numChecked > 0
              ? Center()
              : Center(
                  child: Animator(
                    tweenMap: {
                      'translateAnim': Tween<Offset>(
                          begin: Offset(-2, 0), end: Offset(2, 0)),
                    },
                    cycles: 0,
                    duration: const Duration(
                      seconds: 2,
                    ),
                    builder: (context, animatorState, child) => Center(
                      child: FractionalTranslation(
                        translation: animatorState
                            .getAnimation<Offset>('translateAnim')
                            .value,
                        child: Container(
                          width: width / 6,
                          child: Icon(
                            Icons.touch_app,
                            color: ConfigCustom.colorPrimary,
                            size: width / 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          GridView.extent(
            maxCrossAxisExtent: itemWidth,
            childAspectRatio: itemWidth / itemHeight,
            padding: const EdgeInsets.all(0),
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            children: _rectangles,
          ),
          _isTouch
              ? Center()
              : Positioned(
                  bottom: 0,
                  left: 0,
                  child: ButtonTransparent('Complete', () {
                    _next();
                  }),
                ),
        ],
      ),
    );
  }
}
