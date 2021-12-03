import 'package:dingtoimc/helpers/config.dart';
import 'package:dingtoimc/helpers/functions.dart';
import 'package:dingtoimc/screens/asking_pro_screen.dart';
import 'package:dingtoimc/widgets/drawer.dart';
import 'package:dingtoimc/widgets/loading.dart';
import 'package:dingtoimc/widgets/space_custom.dart';
import 'package:dingtoimc/widgets/text_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableScreen extends StatefulWidget {
  static const routeName = '/slidable_screen';
  @override
  _SlidableScreenState createState() => _SlidableScreenState();
}

class _SlidableScreenState extends State<SlidableScreen> {
  bool _isLoading = false;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Widget screenMain() {
    return Container(
      padding: EdgeInsets.only(
          left: ConfigCustom.globalPadding, right: ConfigCustom.globalPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SpaceCustom(),
            TextCustom(
              "Slidable",
              fontSize: 16,
            ),
            SpaceCustom(),
            Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                color: Colors.white,
                child: ListTile(
                  title: Text('Slidable'),
                  subtitle: Text('SlidableDrawerDelegate'),
                ),
              ),
              // actions: <Widget>[
              //   IconSlideAction(
              //     caption: 'Archive',
              //     color: Colors.blue,
              //     icon: Icons.archive,
              //     //onTap: () => {},
              //   ),
              //   IconSlideAction(
              //     caption: 'Share',
              //     color: Colors.indigo,
              //     icon: Icons.share,
              //     onTap: () => {},
              //   ),
              // ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'More',
                  color: Colors.black45,
                  icon: Icons.more_horiz,
                  onTap: () => {},
                ),
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = screenMain();
    PreferredSize appBar = Functions.getAppbarMainHome(
        context,
        TextCustom(
          'Slidable',
          maxLines: 1,
          fontWeight: FontWeight.w900,
          textAlign: TextAlign.center,
          fontSize: 18,
          letterSpacing: ConfigCustom.letterSpacing2,
        ), () {
      _drawerKey.currentState.openDrawer();
    }, () {
      Functions.goToRoute(context, AskingProScreen.routeName);
    });

    return WillPopScope(
      onWillPop: () {
        Functions.goToRoute(context, AskingProScreen.routeName);
        return Future.value(false);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: ConfigCustom.colorBgBlendBottom,
        ),
        child: _isLoading
            ? Loading()
            : Scaffold(
                key: _drawerKey,
                backgroundColor: Colors.transparent,
                appBar: appBar,
                body: widget,
                drawer: DrawerCustom(),
              ),
      ),
    );
  }
}
