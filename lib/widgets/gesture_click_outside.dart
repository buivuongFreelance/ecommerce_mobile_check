import 'package:flutter/material.dart';

class GestureClickOutside extends StatefulWidget {
  final Widget child;

  const GestureClickOutside({Key key, this.child}) : super(key: key);
  @override
  _GestureClickOutsideState createState() => _GestureClickOutsideState();
}

class _GestureClickOutsideState extends State<GestureClickOutside> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: widget.child,
    );
  }
}
