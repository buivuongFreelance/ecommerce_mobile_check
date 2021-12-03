import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ScannerRatingGroup extends StatefulWidget {
  final Map point;
  ScannerRatingGroup(this.point);

  @override
  _ScannerRatingGroupState createState() => _ScannerRatingGroupState();
}

class _ScannerRatingGroupState extends State<ScannerRatingGroup> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    top: ConfigCustom.globalPadding - 10,
                    bottom: ConfigCustom.globalPadding - 10),
                width: width - ConfigCustom.globalPadding * 2,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ConfigCustom.borderRadius2),
                    gradient: LinearGradient(
                        colors: [
                          const Color(0xFFfeef0c).withOpacity(0.2),
                          const Color(0xFFfcdb05).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Center(
                  child: SmoothStarRating(
                    allowHalfRating: false,
                    onRated: (v) {},
                    starCount: 5,
                    rating: Functions.getScannerPointRating(
                      widget.point[ConfigCustom.sharedPointScanner],
                    ),
                    size: 45.0,
                    isReadOnly: true,
                    filledIconData: Icons.star,
                    halfFilledIconData: Icons.star_half,
                    color: ConfigCustom.colorSecondary,
                    borderColor: ConfigCustom.colorSecondary,
                    spacing: ConfigCustom.globalPadding / 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
