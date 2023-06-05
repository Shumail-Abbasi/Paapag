import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../screens/AdminLoginScreen.dart';
import '../screens/AdminOrderDetailScreen.dart';
import '../screens/AppSettingScreen.dart';
import '../screens/Client/AboutUsScreen.dart';
import '../screens/Client/ChatScreen.dart';
import '../screens/Client/ContactUsScreen.dart';
import '../screens/Client/DashboardScreen.dart';
import '../screens/Client/DeliveryPartnerScreen.dart';
import '../screens/Client/NotificationScreen.dart';
import '../screens/Client/OrderDetailScreen.dart';
import '../screens/Client/PrivacyPolicyScreen.dart';
import '../screens/Client/ProfileScreen.dart';
import '../screens/Client/SendPackageFragment.dart';
import '../screens/DeliveryBoyDetailScreen.dart';
import '../screens/NotificationViewAllScreen.dart';
import '../services/AuthServices.dart';
import '../services/ChatMessagesService.dart';
import '../services/NotificationService.dart';
import '../services/UserServices.dart';
import '../store/AppStore.dart';
import '../store/ClientStore.dart';
import '../utils/Extensions/common.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';
import '../AppTheme.dart';
import '../language/AppLocalizations.dart';
import '../language/BaseLanguage.dart';
import '../models/LanguageDataModel.dart';
import '../screens/SplashScreen.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/DataProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/CityWidget.dart';
import 'components/CountryWidget.dart';
import 'components/CreateOrderWidget.dart';
import 'components/DeliveryBoyWidget.dart';
import 'components/DeliveryPersonDocumentWidget.dart';
import 'components/DocumentWidget.dart';
import 'components/ExtraChargesWidget.dart';
import 'components/HomeWidget.dart';
import 'components/OrderWidget.dart';
import 'components/ParcelTypeWidget.dart';
import 'components/PaymentGatewayWidget.dart';
import 'components/UserWidget.dart';
import 'components/WithdrawWidget.dart';
import 'models/Client/BuilderResponse.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

AppStore appStore = AppStore();
ClientStore clientStore = ClientStore();

BuilderResponse builderResponse = BuilderResponse();

AuthServices authService = AuthServices();
UserService userService = UserService();
ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();

final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;

late SharedPreferences shared_pref;

late BaseLanguage language;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;

PageRouteAnimation? pageRouteAnimationGlobal;
Duration pageRouteTransitionDurationGlobal = 400.milliseconds;

Future<String> loadBuilderData() async {
  return await rootBundle.loadString('assets/builder.json');
}

Future<BuilderResponse> loadContent() async {
  String jsonString = await loadBuilderData();
  final jsonResponse = json.decode(jsonString);
  return BuilderResponse.fromJson(jsonResponse);
}

Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel = getSelectedLanguageModel(defaultLanguage: default_Language);
}

void main() async {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  shared_pref = await SharedPreferences.getInstance();
  builderResponse = await loadContent();

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBNfqjs4no9jb_15Nf8Dx4Q5_ZCrurHmvs",
        authDomain: "paapag-2c755.firebaseapp.com",
        projectId: "paapag-2c755",
        storageBucket: "paapag-2c755.appspot.com",
        messagingSenderId: "115794562052",
        appId: "1:115794562052:web:c97997c34d05c55acb7951",
        measurementId: "G-MWPPYDLTMR"),
  );

  await initialize(aLocaleLanguageList: languageList());
  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: default_Language));

  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
  appStore.setUserProfile(getStringAsync(USER_PROFILE_PHOTO), isInitializing: true);
  FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
  clientStore.setFiltering(filterData.orderStatus.toString() != "null" || filterData.fromDate.toString() != "null" || filterData.toDate.toString() != "null");

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
  saveFcmTokenId();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
            ),
            child: child!,
          );
        },
        initialRoute: AdminLoginScreen.route,  //(getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN) ? AdminHomeWidget.route : DashboardScreen.route,
        routes: {
          DashboardScreen.route: (context) => DashboardScreen(),
          AboutUsScreen.route: (context) => AboutUsScreen(),
          DeliveryPartnerScreen.route: (context) => DeliveryPartnerScreen(),
          ProfileScreen.route: (context) => ProfileScreen(),
          ContactUsScreen.route: (context) => ContactUsScreen(),
          PrivacyPolicyScreen.route: (context) => PrivacyPolicyScreen(),
          SendPackageFragment.route: (context) => SendPackageFragment(),
          NotificationScreen.route: (context) => NotificationScreen(),
          AdminLoginScreen.route: (context) => AdminLoginScreen(),
          NotificationViewAllScreen.route: (context) => NotificationViewAllScreen(),
          //PaymentSetupScreen.route: (context) => PaymentSetupScreen(),
          SplashScreen.route: (context) => SplashScreen(),
          AdminHomeWidget.route: (context) => AdminHomeWidget(),
          CountryWidget.route: (context) => CountryWidget(),
          CityWidget.route: (context) => CityWidget(),
          ExtraChargesWidget.route: (context) => ExtraChargesWidget(),
          ParcelTypeWidget.route: (context) => ParcelTypeWidget(),
          PaymentGatewayWidget.route: (context) => PaymentGatewayWidget(),
          CreateOrderWidget.route: (context) => CreateOrderWidget(),
          OrderWidget.route: (context) => OrderWidget(),
          DocumentWidget.route: (context) => DocumentWidget(),
          DeliveryPersonDocumentWidget.route: (context) => DeliveryPersonDocumentWidget(),
          UserWidget.route: (context) => UserWidget(),
          DeliveryBoyWidget.route: (context) => DeliveryBoyWidget(),
          WithdrawWidget.route: (context) => WithdrawWidget(),
          AppSettingScreen.route: (context) => AppSettingScreen(),
        },
        onGenerateRoute: (settings) {
          var uriData = Uri.parse(settings.name!);
          final queryParameters = uriData.queryParameters;
          var settingData = RouteSettings(arguments: settings.arguments);
          if (settings.name == OrderDetailScreen.route + "?order_Id=${queryParameters['order_Id']}") {
            return MaterialPageRoute(builder: (context) => OrderDetailScreen(orderId: queryParameters['order_Id'].toInt()), settings: settingData);
          }
          if (settings.name == SendPackageFragment.route + "?order_Id=${queryParameters['order_Id']}") {
            return MaterialPageRoute(builder: (context) => SendPackageFragment(orderId: queryParameters['order_Id'].toInt()), settings: settingData);
          }
          if (settings.name == ChatScreen.route + "?user_Id=${queryParameters['user_Id']}") {
            return MaterialPageRoute(builder: (context) => ChatScreen(userId: queryParameters['user_Id'].toInt()), settings: settingData);
          }
          if (settings.name == AdminOrderDetailScreen.route + "?order_Id=${queryParameters['order_Id']}") {
            return MaterialPageRoute(builder: (context) => AdminOrderDetailScreen(orderId: queryParameters['order_Id'].toInt()), settings: settingData);
          }
          // if (settings.name == PaymentSetupScreen.route + "?payment_type=${queryParameters['payment_type']}") {
          //   return MaterialPageRoute(builder: (context) => PaymentSetupScreen(paymentType: queryParameters['payment_type']), settings: settingData);
          // }
          if (settings.name == DeliveryPersonDocumentWidget.route + "?delivery_man_id=${queryParameters['delivery_man_id']}") {
            return MaterialPageRoute(builder: (context) => DeliveryPersonDocumentWidget(deliveryManId: queryParameters['delivery_man_id'].toInt()), settings: settingData);
          }
          if (settings.name == DeliveryPersonDetailScreen.route + "?user_Id=${queryParameters['user_Id']}") {
            return MaterialPageRoute(builder: (context) => DeliveryPersonDetailScreen(userId: queryParameters['user_Id'].toInt()), settings: settingData);
          }
          if (settings.name == DeliveryPersonDetailScreen.route + "?delivery_man_id=${queryParameters['delivery_man_id']}") {
            return MaterialPageRoute(builder: (context) => DeliveryPersonDetailScreen(userId: queryParameters['delivery_man_id'].toInt()), settings: settingData);
          }
          return null;
        },
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: language.app_name,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage),
      );
    });
  }
}
