import 'package:flutter/material.dart';
import '../components/HomeWidget.dart';
import '../main.dart';
import '../utils/Extensions/constants.dart';
import '../utils/Extensions/text_styles.dart';
import 'AdminLoginScreen.dart';

class SplashScreen extends StatefulWidget {
  static String route = 'admin/splash';

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
    Future.delayed(
      Duration(seconds: 2),
      () {
        if (appStore.isLoggedIn) {
          Navigator.pushNamedAndRemoveUntil(context, AdminHomeWidget.route, (route) { return true;});
        } else {
          Navigator.pushNamedAndRemoveUntil(context, AdminLoginScreen.route, (route) { return true;});
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(defaultRadius),
              child: Image.asset('assets/app_logo_primary.png',width: 100,height: 100,fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            Text(language.app_name, style: boldTextStyle(size: 20)),
          ],
        ),
      ),
    );
  }
}
