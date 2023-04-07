import 'package:flutter/material.dart';
import '../../../../../../utils/Extensions/StringExtensions.dart';
import '../../../../../../utils/Extensions/context_extensions.dart';
import '../../../../../../utils/Extensions/int_extensions.dart';
import '../../../../../../utils/Extensions/widget_extensions.dart';

import '../../../../main.dart';
import '../../../../screens/Client/DashboardScreen.dart';
import '../../../../screens/Client/SendPackageFragment.dart';
import '../../../../screens/Client/SignInScreen.dart';
import '../../../../screens/Client/UserCitySelectScreen.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/ResponsiveWidget.dart';
import '../../../../utils/Extensions/common.dart';
import '../../../../utils/Extensions/constants.dart';
import '../../../../utils/Extensions/shared_pref.dart';
import '../../../../utils/Extensions/text_styles.dart';
import '../../../../utils/Images.dart';

class HeaderComponent extends StatefulWidget {
  static String tag = '/HeaderComponent';

  @override
  HeaderComponentState createState() => HeaderComponentState();
}

class HeaderComponentState extends State<HeaderComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        mHeading(builderResponse.appName.validate()),
        20.height,
        Text(
          '${builderResponse.createOrderDescription.validate()}',
          style: secondaryTextStyle(weight: FontWeight.w500, wordSpacing: 0.5, size: 16),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.justify,
        ),
        40.height,
        SizedBox(
          width: !ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.13 : context.width(),
          child: appButton(context, title: language.crete_order.toUpperCase(), onCall: () async {
            if (appStore.isLoggedIn && getStringAsync(USER_TYPE) == CLIENT) {
              if (getIntAsync(CITY_ID) != 0 && getIntAsync(COUNTRY_ID) != 0) {
                Navigator.of(context).pushNamed(SendPackageFragment.route);
              } else {
                await showDialog(
                    context: getContext,
                    builder: (_) {
                      return UserCitySelectScreen(
                        onUpdate: () {
                          Navigator.pushNamedAndRemoveUntil(getContext, DashboardScreen.route, (route) {
                            return true;
                          });
                        },
                      );
                    });
              }
            } else {
              showDialog(
                  context: context,
                  builder: (_) {
                    return SignInScreen();
                  });
            }
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      color: accentColor,
      padding: EdgeInsets.only(bottom: ResponsiveWidget.isExtraSmallScreen(context) ? 80 : 100),
      child: Stack(
        children: [
          FittedBox(
            child: GradientText(
              builderResponse.appName.validate(),
              style: TextStyle(color: textPrimaryColorGlobal, decorationStyle: TextDecorationStyle.dashed, decorationThickness: 1, letterSpacing: 2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineGradient1.withOpacity(0.2),
                  lineGradient2.withOpacity(0.08),
                ],
              ),
            ).paddingSymmetric(horizontal: mCommonPadding(context)),
          ),
          ResponsiveWidget.isExtraSmallScreen(context)
              ? Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(left: 0, right: 0, bottom: -100, child: Image.asset(ic_road_pattern, height: 150, width: context.width(), fit: BoxFit.fill)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        mContent(),
                        Image.asset(builderResponse.deliveryManImage.validate()).paddingTop(80),
                      ],
                    ).paddingSymmetric(horizontal: mCommonPadding(context)),
                  ],
                ).paddingTop(context.height() * 0.1)
              : Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(left: 0, right: 0, bottom: -100, child: Image.asset(ic_road_pattern, width: context.width(), fit: BoxFit.fill)),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        mContent().expand(),
                        100.width,
                        Image.asset(builderResponse.deliveryManImage.validate()).paddingTop(70).expand(),
                      ],
                    ).paddingSymmetric(horizontal: mCommonPadding(context)),
                  ],
                ).paddingTop(context.height() * 0.19),
        ],
      ),
    );
  }
}
