import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/widgets/divider_custom.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class DiamondRatingGroup extends StatefulWidget {
  final Map point;
  DiamondRatingGroup(this.point);

  @override
  _DiamondRatingGroupState createState() => _DiamondRatingGroupState();
}

class _DiamondRatingGroupState extends State<DiamondRatingGroup> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String grade;
    if (widget.point['physicalGrading'] == 50)
      grade = 'A';
    else if (widget.point['physicalGrading'] == 40)
      grade = 'B';
    else if (widget.point['physicalGrading'] == 30)
      grade = 'C';
    else if (widget.point['physicalGrading'] == 10) grade = 'D';

    return Container(
      padding: EdgeInsets.fromLTRB(
          ConfigCustom.globalPadding, 0, ConfigCustom.globalPadding, 0),
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
                child: Functions.isEmpty(widget.point['diamondRating'])
                    ? Center()
                    : Center(
                        child: SmoothStarRating(
                          allowHalfRating: false,
                          onRated: (v) {},
                          starCount: 5,
                          rating: double.tryParse(
                              widget.point['diamondRating'].toString()),
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
          SpaceCustom(),
          DividerCustom(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextCustom(
                'Physical Grading',
                fontWeight: FontWeight.w900,
              ),
              TextCustom(
                "Grade $grade",
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
          DividerCustom(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextCustom(
                'Scan Score',
                fontWeight: FontWeight.w900,
              ),
              SmoothStarRating(
                allowHalfRating: false,
                onRated: (v) {},
                starCount: 5,
                rating: Functions.getScannerPointRating(
                    double.parse(widget.point['scannerPoint'].toString())),
                size: 20.0,
                isReadOnly: true,
                filledIconData: Icons.star,
                halfFilledIconData: Icons.star_half,
                color: ConfigCustom.colorSecondary,
                borderColor: ConfigCustom.colorSecondary,
                spacing: ConfigCustom.globalPadding / 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
