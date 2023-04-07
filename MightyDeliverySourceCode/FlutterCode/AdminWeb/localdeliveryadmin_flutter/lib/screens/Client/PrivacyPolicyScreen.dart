import 'package:flutter/material.dart';
import '../../main.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../components/Client/FooterComponent.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/colors.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const String route = '/privacyPolicy';

  @override
  PrivacyPolicyScreenState createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.width(),
              color: primaryColor,
              height: context.height() * 0.4,
              child: Text(language.privacyPolicy, style: boldTextStyle(color: whiteColor, size: 40)).center(),
            ),
            50.height,
            Text('At MeetMighty, accessible from https://meetmighty.com/mighty/, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by MeetMighty and how we use it. If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us. This Privacy Policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in MeetMighty. This policy is not applicable to any information collected offline or via channels other than this website. If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.',
                    style: primaryTextStyle(color: textSecondaryColorGlobal))
                .paddingSymmetric(horizontal: mCommonPadding(context)),
            16.height,
            Text('At MeetMighty, accessible from https://meetmighty.com/mighty/, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by MeetMighty and how we use it. If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us. This Privacy Policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in MeetMighty. This policy is not applicable to any information collected offline or via channels other than this website. If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.',
                    style: primaryTextStyle(color: textSecondaryColorGlobal))
                .paddingSymmetric(horizontal: mCommonPadding(context)),
            16.height,
            Text('At MeetMighty, accessible from https://meetmighty.com/mighty/, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by MeetMighty and how we use it. If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us. This Privacy Policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in MeetMighty. This policy is not applicable to any information collected offline or via channels other than this website. If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.',
                    style: primaryTextStyle(color: textSecondaryColorGlobal))
                .paddingSymmetric(horizontal: mCommonPadding(context)),
            50.height,
            FooterComponent(privacyPolicy: false),
          ],
        ),
      ),
    );
  }
}
