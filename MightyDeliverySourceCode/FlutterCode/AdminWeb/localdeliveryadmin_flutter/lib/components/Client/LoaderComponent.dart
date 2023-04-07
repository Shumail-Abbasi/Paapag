import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../utils/Extensions/context_extensions.dart';

import '../../utils/Colors.dart';

class Loader extends StatefulWidget {
  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Container(
        height: context.height(),
        width: context.width(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),
        ),
      ),
    );
  }
}
