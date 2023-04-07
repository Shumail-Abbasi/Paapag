import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import '../../utils/Extensions/StringExtensions.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Extensions/widget_extensions.dart';

import '../../components/Client/ConfirmationDialog.dart';
import '../../components/Client/LoaderComponent.dart';
import '../../utils/Colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import 'colors.dart';
import 'constants.dart';
import 'decorations.dart';

T? makeNullable<T>(T? value) => value;

enum PageRouteAnimation { Fade, Scale, Rotate, Slide, SlideBottomTop }

bool hasMatch(String? s, String p) {
  return (s == null) ? false : RegExp(p).hasMatch(s);
}

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');

/// Prints only if in debug or profile mode
void log(Object? value) {
  if (!kReleaseMode) print(value);
}

/// Show SnackBar
void snackBar(
  BuildContext context, {
  String title = '',
  Widget? content,
  SnackBarAction? snackBarAction,
  Function? onVisible,
  Color? textColor,
  Color? backgroundColor,
  EdgeInsets? margin,
  EdgeInsets? padding,
  Animation<double>? animation,
  double? width,
  ShapeBorder? shape,
  Duration? duration,
  SnackBarBehavior? behavior,
  double? elevation,
}) {
  if (title.isEmpty && content == null) {
    print('SnackBar message is empty');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        action: snackBarAction,
        margin: margin,
        animation: animation,
        width: width,
        shape: shape,
        duration: duration ?? 4.seconds,
        behavior: margin != null ? SnackBarBehavior.floating : behavior,
        elevation: elevation,
        onVisible: onVisible?.call(),
        content: content ??
            Padding(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                title,
                style: primaryTextStyle(color: textColor ?? Colors.white),
              ),
            ),
      ),
    );
  }
}

/// Hide soft keyboard
void hideKeyboard(context) => FocusScope.of(context).requestFocus(FocusNode());

/// Returns a string from Clipboard
Future<String> paste() async {
  ClipboardData? data = await Clipboard.getData('text/plain');
  return data?.text?.toString() ?? "";
}

/// Returns a string from Clipboard
Future<dynamic> pasteObject() async {
  ClipboardData? data = await Clipboard.getData('text/plain');
  return data;
}

enum LinkProvider { PLAY_STORE, APPSTORE, FACEBOOK, INSTAGRAM, LINKEDIN, TWITTER, YOUTUBE, REDDIT, TELEGRAM, WHATSAPP, FB_MESSENGER, GOOGLE_DRIVE }

class SBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

String getSocialMediaLink(LinkProvider linkProvider, {String url = ''}) {
  switch (linkProvider) {
    case LinkProvider.PLAY_STORE:
      return "$playStoreBaseURL$url";
    case LinkProvider.APPSTORE:
      return "$appStoreBaseURL$url";
    case LinkProvider.FACEBOOK:
      return "$facebookBaseURL$url";
    case LinkProvider.INSTAGRAM:
      return "$instagramBaseURL$url";
    case LinkProvider.LINKEDIN:
      return "$linkedinBaseURL$url";
    case LinkProvider.TWITTER:
      return "$twitterBaseURL$url";
    case LinkProvider.YOUTUBE:
      return "$youtubeBaseURL$url";
    case LinkProvider.REDDIT:
      return "$redditBaseURL$url";
    case LinkProvider.TELEGRAM:
      return "$telegramBaseURL$url";
    case LinkProvider.FB_MESSENGER:
      return "$facebookMessengerURL$url";
    case LinkProvider.WHATSAPP:
      return "$whatsappURL$url";
    case LinkProvider.GOOGLE_DRIVE:
      return "$googleDriveURL$url";
  }
}

const double degrees2Radians = pi / 180.0;

double radians(double degrees) => degrees * degrees2Radians;

void afterBuildCreated(Function()? onCreated) {
  makeNullable(SchedulerBinding.instance)!.addPostFrameCallback((_) => onCreated?.call());
}

Route<T> buildPageRoute<T>(Widget child, PageRouteAnimation? pageRouteAnimation, Duration? duration) {
  if (pageRouteAnimation != null) {
    if (pageRouteAnimation == PageRouteAnimation.Fade) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Rotate) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => RotationTransition(turns: ReverseAnimation(anim), child: child),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Scale) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => ScaleTransition(scale: anim, child: child),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Slide) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => SlideTransition(
          position: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).animate(anim),
          child: child,
        ),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.SlideBottomTop) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) => SlideTransition(
          position: Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).animate(anim),
          child: child,
        ),
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    }
  }
  return MaterialPageRoute<T>(builder: (_) => child);
}

EdgeInsets dynamicAppButtonPadding(BuildContext context) {
  if (context.isDesktop()) {
    return const EdgeInsets.symmetric(vertical: 20, horizontal: 20);
  } else if (context.isTablet()) {
    return const EdgeInsets.symmetric(vertical: 16, horizontal: 16);
  } else {
    return const EdgeInsets.symmetric(vertical: 14, horizontal: 16);
  }
}

Widget appButton(BuildContext context, {String? title, Function? onCall, Color? color,Color? textColor}) {
  return InkWell(
    onTap: () {
      onCall!();
    },
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: radius(defaultRadius), color: color ?? primaryColor),
      child: Text(title!, style: boldTextStyle(color: textColor ?? Colors.white)),
    ),
  );
}

Widget snapWidgetHelper<T>(
  AsyncSnapshot<T> snapshot, {
  Widget? errorWidget,
  Widget? loadingWidget,
  String? defaultErrorMessage,
  @Deprecated('Do not use this') bool checkHasData = false,
  Widget Function(String)? errorBuilder,
}) {
  if (snapshot.hasError) {
    // log(snapshot.error);
    if (errorBuilder != null) {
      return errorBuilder.call(defaultErrorMessage ?? snapshot.error.toString());
    }
    return errorWidget ?? Text(defaultErrorMessage ?? snapshot.error.toString(), style: primaryTextStyle()).center();
  } else if (!snapshot.hasData) {
    return loadingWidget ?? Loader();
  } else {
    return SizedBox();
  }
}

/// Returns true is snapshot is loading
bool isSnapshotLoading(AsyncSnapshot snap, {bool checkHasData = false}) {
  return snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.waiting;
}

void finish(BuildContext context, [Object? result]) {
  if (Navigator.canPop(context)) Navigator.pop(context, result);
}

Widget dialogAnimatedWrapperWidget({
  required Animation<double> animation,
  required Widget child,
  required DialogAnimation dialogAnimation,
  required Curve curve,
}) {
  switch (dialogAnimation) {
    case DialogAnimation.ROTATE:
      return Transform.rotate(
        angle: radians(animation.value * 360),
        child: Opacity(opacity: animation.value, child: FadeTransition(opacity: animation, child: child)),
      );

    case DialogAnimation.SLIDE_TOP_BOTTOM:
      final curvedValue = curve.transform(animation.value) - 1.0;

      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 300, 0.0),
        child: Opacity(opacity: animation.value, child: FadeTransition(opacity: animation, child: child)),
      );

    case DialogAnimation.SCALE:
      return Transform.scale(scale: animation.value, child: FadeTransition(opacity: animation, child: child));

    case DialogAnimation.SLIDE_BOTTOM_TOP:
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: curve)).animate(animation),
        child: Opacity(opacity: animation.value, child: FadeTransition(opacity: animation, child: child)),
      );

    case DialogAnimation.SLIDE_LEFT_RIGHT:
      return SlideTransition(
        position: Tween(begin: Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: curve)).animate(animation),
        child: Opacity(opacity: animation.value, child: FadeTransition(opacity: animation, child: child)),
      );

    case DialogAnimation.SLIDE_RIGHT_LEFT:
      return SlideTransition(
        position: Tween(begin: Offset(-1, 0), end: Offset.zero).chain(CurveTween(curve: curve)).animate(animation),
        child: Opacity(opacity: animation.value, child: FadeTransition(opacity: animation, child: child)),
      );

    case DialogAnimation.DEFAULT:
      return FadeTransition(opacity: animation, child: child);
  }
}

Widget mStatus(String? value, Color? color) {
  return Container(
    decoration: boxDecorationWithRoundedCorners(backgroundColor: color!),
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Text(value!, style: primaryTextStyle(color: whiteColor)),
  );
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

toast(String? value, {ToastGravity? gravity, length = Toast.LENGTH_SHORT, Color? bgColor, Color? textColor}) {
  Fluttertoast.showToast(
    msg: value!.validate(),
    toastLength: length,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: bgColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}