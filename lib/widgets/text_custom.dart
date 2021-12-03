import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TextCustom extends StatefulWidget {
  final String message;
  final int maxLines;
  final Color color;
  final TextAlign textAlign;
  final double fontSize;
  final double minFontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final FontStyle fontStyle;
  final TextDecoration textDecoration;

  TextCustom(
    this.message, {
    Key key,
    this.maxLines = 10,
    this.color = Colors.white,
    this.textAlign = TextAlign.left,
    this.fontSize = 15,
    this.minFontSize = 11,
    this.fontWeight = FontWeight.w100,
    this.fontStyle,
    this.letterSpacing = 0,
    this.textDecoration = TextDecoration.none,
  }) : super(key: key);

  @override
  _TextCustomState createState() => _TextCustomState();
}

class _TextCustomState extends State<TextCustom> {
  @override
  Widget build(BuildContext context) {
    String fontFamily = 'AvenirNext';

    return AutoSizeText(
      widget.message,
      maxLines: widget.maxLines,
      minFontSize: widget.minFontSize,
      textAlign: widget.textAlign,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontFamily: fontFamily,
        color: widget.color,
        fontWeight: widget.fontWeight,
        letterSpacing: widget.letterSpacing,
        fontStyle: widget.fontStyle,
        decoration: widget.textDecoration,
      ),
    );
  }
}
