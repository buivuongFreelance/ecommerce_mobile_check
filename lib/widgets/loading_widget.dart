import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.0,
      width: 20.0,
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}
