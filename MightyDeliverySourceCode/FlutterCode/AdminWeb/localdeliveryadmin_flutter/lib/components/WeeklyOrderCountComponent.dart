import 'package:flutter/material.dart';
import '../main.dart';
import '../models/DashboardModel.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../utils/Extensions/constants.dart';
import '../utils/Extensions/text_styles.dart';

class WeeklyOrderCountComponent extends StatefulWidget {
  static String tag = '/WeeklyOrderCountComponent';
  final List<WeeklyDataModel> weeklyOrderCount;

  WeeklyOrderCountComponent({required this.weeklyOrderCount});

  @override
  WeeklyOrderCountComponentState createState() => WeeklyOrderCountComponentState();
}

class WeeklyOrderCountComponentState extends State<WeeklyOrderCountComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 350,
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        title: ChartTitle(text: language.weekly_order_count, textStyle: boldTextStyle(color: primaryColor)),
        tooltipBehavior: TooltipBehavior(enable: true),
        legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
        series: <CircularSeries>[
          PieSeries<WeeklyDataModel, String>(
              dataSource: widget.weeklyOrderCount,
              xValueMapper: (WeeklyDataModel data, _) => dayTranslate(data.day!),
              yValueMapper: (WeeklyDataModel data, _) => data.total,
              dataLabelSettings: DataLabelSettings(isVisible: true, textStyle: boldTextStyle()))
        ],
      ),
      decoration: BoxDecoration(
        boxShadow: commonBoxShadow(),
        color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    );
  }
}
