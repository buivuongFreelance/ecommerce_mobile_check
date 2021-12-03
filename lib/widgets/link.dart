import 'package:flutter/material.dart';

class Link extends StatelessWidget {
  final String message;
  final Function onPressed;

  Link(this.message, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: const Color(0xFF369AFE),
        ),
      ),
    );
  }
}
