import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:flutter/material.dart';

class InputText extends StatefulWidget {
  final double fontSize;
  final Color textColor;
  final Color hintColor;
  final String hint;
  final TextEditingController mController;
  final Function onChanged;
  final Widget prefixIcon;
  final double bottomIcon;
  final Function validator;
  final TextInputType textInputType;
  final int maxLines;

  InputText(
      {this.fontSize = 15,
      this.textColor = Colors.white,
      this.hintColor = const Color(0xFF888888),
      this.hint = '',
      this.mController,
      this.onChanged,
      this.prefixIcon,
      this.bottomIcon = 0,
      this.validator,
      this.textInputType = TextInputType.text,
      this.maxLines = 1});
  @override
  _InputTextState createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.textInputType,
      controller: widget.mController,
      validator: widget.validator,
      maxLines: widget.maxLines,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontFamily: 'AvenirNext',
        color: widget.textColor,
      ),
      decoration: InputDecoration(
        errorStyle: TextStyle(
          fontSize: 15,
          color: ConfigCustom.colorError,
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 23, maxHeight: 30),
        prefixIcon: Functions.isEmpty(widget.prefixIcon)
            ? null
            : Container(
                padding: EdgeInsets.only(
                  right: ConfigCustom.globalPadding / 2,
                  bottom: widget.bottomIcon,
                ),
                child: widget.prefixIcon,
              ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ConfigCustom.colorGreyWarm,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ConfigCustom.colorGreyWarm,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ConfigCustom.colorWhite,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ConfigCustom.colorError,
          ),
        ),
        filled: false,
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: widget.hintColor,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
