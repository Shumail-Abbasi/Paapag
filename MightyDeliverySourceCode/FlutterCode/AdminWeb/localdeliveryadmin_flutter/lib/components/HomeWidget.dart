import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../components/BodyCornerWidget.dart';
import '../components/DeliveryBoyWidget.dart';
import '../components/UserWidget.dart';
import '../screens/Client/DashboardScreen.dart';
import '../utils/Extensions/ResponsiveWidget.dart';
import '../components/HomeWidgetUserList.dart';
import '../models/DashboardModel.dart';
import '../models/models.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../main.dart';
import '../utils/Extensions/common.dart';
import '../utils/Extensions/constants.dart';
import '../utils/Extensions/text_styles.dart';
import 'WeeklyOrderCountComponent.dart';
import 'WeeklyUserCountComponent.dart';

class AdminHomeWidget extends StatefulWidget {
  static String route = '/admin/dashboard';

  @override
  AdminHomeWidgetState createState() => AdminHomeWidgetState();
}

class AdminHomeWidgetState extends State<AdminHomeWidget> {
  List<MenuItemModel> menuList = getMenuItems();

  ScrollController scrollController = ScrollController();
  ScrollController recentOrderController = ScrollController();
  ScrollController recentOrderHorizontalController = ScrollController();
  ScrollController upcomingOrderController = ScrollController();
  ScrollController upcomingOrderHorizontalController = ScrollController();
  ScrollController userController = ScrollController();
  ScrollController userHorizontalController = ScrollController();
  ScrollController deliveryBoyController = ScrollController();
  ScrollController deliveryBoyHorizontalController = ScrollController();

  List<WeeklyDataModel> userWeeklyCount = [];
  List<WeeklyDataModel> weeklyOrderCount = [];
  List<WeeklyDataModel> weeklyPaymentReport = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(DASHBOARD_INDEX);
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? currencyCodeDefault);
      appStore.setCurrencySymbol(value.currency ?? currencySymbolDefault);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
    }).catchError((error) {
      log(error.toString());
    });
    firebaseOnMessage();
    LiveStream().on(streamLanguage, (p0) {
      menuList.clear();
      menuList = getMenuItems();
      setState(() {});
    });
    LiveStream().on(streamDarkMode, (p0) {
      setState(() {});
    });
  }

  void firebaseOnMessage() {
    FirebaseMessaging.onMessage.listen((event) async {
      ElegantNotification.info(
        title: Text(event.notification!.title.validate(), style: boldTextStyle(color: primaryColor, size: 18)),
        description: Text(event.notification!.body.validate(), style: primaryTextStyle(color: Colors.black, size: 16)),
        notificationPosition: NotificationPosition.topCenter,
        autoDismiss: true,
        animation: AnimationType.fromTop,
        showProgressIndicator: false,
        width: 400,
        height: 100,
        toastDuration: Duration(seconds: 10),
        iconSize: 0,
      ).show(context);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void callMethod(int count) {
    afterBuildCreated(() => appStore.setAllUnreadCount(count));
  }

  double? getChartWidth() {
    return ResponsiveWidget.isSmallScreen(context) ? null : (getBodyWidth(context) - 40) * 0.5;
  }

  double getTableWidth() {
    return ResponsiveWidget.isLargeScreen(context) ? (getBodyWidth(context) - 40) * 0.5 : getBodyWidth(context) - 16;
  }

  double? getTableHeight() {
    return ResponsiveWidget.isLargeScreen(context) ? 500 : null;
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveWidget.isSmallScreen(context)) {
      appStore.setExpandedMenu(false);
    } else {
      appStore.setExpandedMenu(true);
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, DashboardScreen.route);
        return false;
      },
      child: BodyCornerWidget(
        child: Stack(
          children: [
            FutureBuilder<DashboardModel>(
              future: getDashBoardData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  userWeeklyCount = snapshot.data!.user_weekly_count ?? [];
                  weeklyOrderCount = snapshot.data!.weekly_order_count ?? [];
                  weeklyPaymentReport = snapshot.data!.weekly_payment_report ?? [];
                  callMethod(snapshot.data!.all_unread_count ?? 0);
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            totalUserWidget(title: language.total_user, totalCount: snapshot.data!.total_client, image: 'assets/icons/ic_users.png'),
                            totalUserWidget(title: language.total_delivery_person, totalCount: snapshot.data!.total_delivery_man, image: 'assets/icons/ic_users.png'),
                            totalUserWidget(title: language.total_country, totalCount: snapshot.data!.total_country, image: 'assets/icons/ic_country.png'),
                            totalUserWidget(title: language.total_city, totalCount: snapshot.data!.total_city, image: 'assets/icons/ic_city.png'),
                            totalUserWidget(title: language.total_order, totalCount: snapshot.data!.total_order, image: 'assets/icons/ic_orders.png'),
                          ],
                        ),
                        SizedBox(height: 16),
                        ResponsiveWidget.isLargeScreen(context)
                            ? Row(
                                children: [
                                  Expanded(child: WeeklyOrderCountComponent(weeklyOrderCount: weeklyOrderCount)),
                                  SizedBox(width: 16),
                                  Expanded(child: WeeklyUserCountComponent(weeklyCount: userWeeklyCount)),
                                  SizedBox(width: 16),
                                  Expanded(child: WeeklyUserCountComponent(weeklyCount: weeklyPaymentReport, isPaymentType: true)),
                                ],
                              )
                            : Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(width: getChartWidth(), child: WeeklyOrderCountComponent(weeklyOrderCount: weeklyOrderCount)),
                                  SizedBox(width: getChartWidth(), child: WeeklyUserCountComponent(weeklyCount: userWeeklyCount)),
                                  SizedBox(width: getChartWidth(), child: WeeklyUserCountComponent(weeklyCount: weeklyPaymentReport, isPaymentType: true)),
                                ],
                              ),
                        SizedBox(height: 16),
                        Wrap(
                          runSpacing: 16,
                          spacing: 16,
                          children: [
                            snapshot.data!.recent_order!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(),
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    width: getTableWidth(),
                                    child: SingleChildScrollView(
                                      controller: recentOrderController,
                                      padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(language.recent_order, style: boldTextStyle(color: primaryColor)),
                                          SizedBox(height: 20),
                                          RawScrollbar(
                                            scrollbarOrientation: ScrollbarOrientation.bottom,
                                            controller: recentOrderHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                                            radius: Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller: recentOrderHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: getTableWidth()),
                                                child: DataTable(
                                                  headingTextStyle: boldTextStyle(),
                                                  dataTextStyle: primaryTextStyle(size: 15),
                                                  headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                                  showCheckboxColumn: false,
                                                  dataRowHeight: 45,
                                                  headingRowHeight: 45,
                                                  horizontalMargin: 16,
                                                  columns: [
                                                    DataColumn(label: Text(language.order_id)),
                                                    DataColumn(label: Text(language.customer_name)),
                                                    DataColumn(label: Text(language.delivery_person)),
                                                    DataColumn(label: Text(language.pickup_date)),
                                                    DataColumn(label: Text(language.created_date)),
                                                    DataColumn(label: Text(language.status)),
                                                  ],
                                                  rows: snapshot.data!.recent_order!.map((e) {
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(Text('${e.id}')),
                                                        DataCell(Text(e.clientName ?? "-")),
                                                        DataCell(Text(e.deliveryManName ?? "-")),
                                                        DataCell(Text(e.pickupPoint!.startTime != null ? printDate(e.pickupPoint!.startTime!) : '-')),
                                                        DataCell(Text(e.readableDate.toString())),
                                                        DataCell(
                                                          Container(
                                                            padding: EdgeInsets.all(6),
                                                            child: Text(orderStatus(e.status.validate()), style: boldTextStyle(color: statusColor(e.status ?? ""), size: 15)),
                                                            decoration: BoxDecoration(color: statusColor(e.status ?? "").withOpacity(0.15), borderRadius: BorderRadius.circular(defaultRadius)),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                                      borderRadius: BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                            snapshot.data!.upcoming_order!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(),
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    width: getTableWidth(),
                                    child: SingleChildScrollView(
                                      controller: upcomingOrderController,
                                      padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(language.upcoming_order, style: boldTextStyle(color: primaryColor)),
                                          SizedBox(height: 20),
                                          RawScrollbar(
                                            scrollbarOrientation: ScrollbarOrientation.bottom,
                                            controller: upcomingOrderHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                                            radius: Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller: upcomingOrderHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: getTableWidth()),
                                                child: DataTable(
                                                  headingTextStyle: boldTextStyle(),
                                                  dataTextStyle: primaryTextStyle(size: 15),
                                                  headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                                  showCheckboxColumn: false,
                                                  dataRowHeight: 45,
                                                  headingRowHeight: 45,
                                                  horizontalMargin: 16,
                                                  columns: [
                                                    DataColumn(label: Text(language.order_id)),
                                                    DataColumn(label: Text(language.customer_name)),
                                                    DataColumn(label: Text(language.delivery_person)),
                                                    DataColumn(label: Text(language.pickup_date)),
                                                    DataColumn(label: Text(language.created_date)),
                                                    DataColumn(label: Text(language.status)),
                                                  ],
                                                  rows: snapshot.data!.upcoming_order!.map((e) {
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(Text('${e.id}')),
                                                        DataCell(Text(e.clientName ?? "-")),
                                                        DataCell(Text(e.deliveryManName ?? "-")),
                                                        DataCell(Text(e.pickupPoint!.startTime != null ? printDate(e.pickupPoint!.startTime!) : '-')),
                                                        DataCell(Text(e.readableDate.toString())),
                                                        DataCell(
                                                          Container(
                                                            padding: EdgeInsets.all(6),
                                                            child: Text(orderStatus(e.status.validate()), style: boldTextStyle(color: statusColor(e.status ?? ""), size: 15)),
                                                            decoration: BoxDecoration(color: statusColor(e.status ?? "").withOpacity(0.15), borderRadius: BorderRadius.circular(defaultRadius)),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                                      borderRadius: BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                            snapshot.data!.recent_client!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(),
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    width: getTableWidth(),
                                    child: SingleChildScrollView(
                                      controller: userController,
                                      padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.recent_user, style: boldTextStyle(color: primaryColor)),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, UserWidget.route);
                                                },
                                                child: Text(language.view_all, style: boldTextStyle(color: primaryColor)),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          RawScrollbar(
                                            scrollbarOrientation: ScrollbarOrientation.bottom,
                                            controller: userHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                                            radius: Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller: userHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              child: ConstrainedBox(constraints: BoxConstraints(minWidth: getTableWidth()), child: HomeWidgetUserList(userModel: snapshot.data!.recent_client!)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                                      borderRadius: BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                            snapshot.data!.recent_delivery_man!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(),
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    width: getTableWidth(),
                                    child: SingleChildScrollView(
                                      controller: deliveryBoyController,
                                      padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.recent_delivery, style: boldTextStyle(color: primaryColor)),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, DeliveryBoyWidget.route);
                                                },
                                                child: Text(language.view_all, style: boldTextStyle(color: primaryColor)),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          RawScrollbar(
                                            scrollbarOrientation: ScrollbarOrientation.bottom,
                                            controller: deliveryBoyHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                                            radius: Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller: deliveryBoyHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              child: ConstrainedBox(constraints: BoxConstraints(minWidth: getTableWidth()), child: HomeWidgetUserList(userModel: snapshot.data!.recent_delivery_man!)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                                      borderRadius: BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        SizedBox(height: 80)
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return emptyWidget();
                }
                return loaderWidget();
              },
            ),
            Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: loaderWidget())),
          ],
        ),
      ),
    );
  }
}
