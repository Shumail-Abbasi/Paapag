import 'package:flutter/material.dart';

import '../../components/Client/OrderComponent.dart';

class DraftScreen extends StatefulWidget {
  static String tag = '/draftOrders';

  @override
  DraftScreenState createState() => DraftScreenState();
}

class DraftScreenState extends State<DraftScreen> {
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
    return OrderComponent(isDraft: true);
  }
}
