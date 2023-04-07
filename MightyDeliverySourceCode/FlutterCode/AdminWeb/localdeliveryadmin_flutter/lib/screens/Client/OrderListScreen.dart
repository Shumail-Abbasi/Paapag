import 'package:flutter/material.dart';

import '../../components/Client/OrderComponent.dart';

class OrderListScreen extends StatefulWidget {
  static String tag = '/orders';

  @override
  OrderListScreenState createState() => OrderListScreenState();
}

class OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async{
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return OrderComponent();
  }
}