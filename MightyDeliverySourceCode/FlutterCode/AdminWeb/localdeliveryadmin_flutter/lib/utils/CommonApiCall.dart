
import '../network/RestApis.dart';

import '../main.dart';
import 'Extensions/common.dart';

getAllCountryApiCall() async{
  await getCountryList().then((value) {
    appStore.countryList.clear();
    appStore.countryList.addAll(value.data!);
  }).catchError((error) {
    toast(error.toString());
  });
}
