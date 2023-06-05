import 'package:flutter/material.dart';
import 'package:paapag/delivery/screens/DeliveryDashBoard.dart';
import 'package:paapag/main/components/UserCitySelectScreen.dart';
import 'package:paapag/main/models/CityListModel.dart';
import 'package:paapag/main/network/RestApis.dart';
import 'package:paapag/main/screens/LoginScreen.dart';
import 'package:paapag/main/screens/WalkThroughScreen.dart';
import 'package:paapag/main/utils/Constants.dart';
import 'package:paapag/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(appStore.isDarkMode ? Colors.black : Colors.white, statusBarBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark);
    Future.delayed(
      Duration(seconds: 1),
      () {
        if (appStore.isLoggedIn) {
          getUserDetail(getIntAsync(USER_ID).validate()).then((value) {
            if (value.deletedAt != null) {
              logout(context);
            } else {
              if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
                if (getStringAsync(USER_TYPE) == CLIENT) {
                  DashboardScreen().launch(context, isNewTask: true);
                } else {
                  DeliveryDashBoard().launch(context, isNewTask: true);
                }
              } else {
                UserCitySelectScreen().launch(context);
              }
            }
          }).catchError((_) {
            LoginScreen().launch(context, isNewTask: true);
          });
        } else {
          if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
            WalkThroughScreen().launch(context, isNewTask: true);
          } else {
            LoginScreen().launch(context, isNewTask: true);
          }
        }
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/app_logo.jpg', height: 80, width: 80, fit: BoxFit.fill).cornerRadiusWithClipRRect(defaultRadius),
            16.height,
            Text(language.appName, style: boldTextStyle(size: 20), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
