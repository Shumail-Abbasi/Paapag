import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../models/WithdrawModel.dart';
import '../utils/Extensions/int_extensions.dart';
import '../models/AutoCompletePlacesListModel.dart';
import '../models/CityListModel.dart';
import '../models/CountryListModel.dart';
import '../models/DashboardModel.dart';
import '../models/DeliveryDocumentListModel.dart';
import '../models/DocumentListModel.dart';
import '../models/ExtraChragesListModel.dart';
import '../models/LDBaseResponse.dart';
import '../models/LoginResponse.dart';
import '../models/NotificationModel.dart';
import '../models/AppSettingModel.dart';
import '../models/OrderDetailModel.dart';
import '../models/OrderListModel.dart';
import '../models/ParcelTypeListModel.dart';
import '../models/PaymentGatewayListModel.dart';
import '../models/PlaceIdDetailModel.dart';
import '../models/UpdateUserStatus.dart';
import '../models/UserDetailModel.dart';
import '../models/UserListModel.dart';
import '../models/UserModel.dart';
import '../network/NetworkUtils.dart';
import '../screens/AdminLoginScreen.dart';
import '../screens/Client/DashboardScreen.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../utils/Extensions/common.dart';
import '../utils/Extensions/shared_pref.dart';

Future<LoginResponse> signUpApi(Map request) async {
  Response response = await buildHttpResponse('register', request: request, method: HttpMethod.POST);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    if (getStringAsync(USER_TYPE) != ADMIN && getStringAsync(USER_TYPE) != DEMO_ADMIN) {
      await setValue(USER_ID, loginResponse.data!.id.validate());
      await setValue(USER_NAME, loginResponse.data!.name.validate());
      await setValue(USER_EMAIL, loginResponse.data!.email.validate());
      await setValue(TOKEN, loginResponse.data!.fcmToken.validate());
      await setValue(USER_CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
      await setValue(USER_PROFILE_PHOTO, loginResponse.data!.profileImage.validate());
      await setValue(USER_TYPE, loginResponse.data!.userType.validate());
      await setValue(USER_NAME, loginResponse.data!.username.validate());
      await setValue(USER_ADDRESS, loginResponse.data!.address.validate());
      await setValue(COUNTRY_ID, loginResponse.data!.countryId.validate());
      await setValue(CITY_ID, loginResponse.data!.cityId.validate());
      await setValue(UID, loginResponse.data!.uid.validate());
      await setValue(IS_VERIFIED_DELIVERY_MAN, loginResponse.data!.isVerifiedDeliveryMan == 1);

      await clientStore.setClientEmail(loginResponse.data!.email.validate());
      await appStore.setLoggedIn(true);

      await setValue(USER_PASSWORD, request['password']);
    }

    return loginResponse;
  }).catchError((e) {
    log(e.toString());
    throw e.toString();
  });
}

Future<LoginResponse> logInApi(Map request, {bool isSocialLogin = false}) async {
  Response response = await buildHttpResponse('login', request: request, method: HttpMethod.POST);
  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    /*if (request['login_type'] == LoginTypeGoogle) {
      await setValue(USER_PHOTO_URL, request['image']);
    } else {
      await setValue(USER_PHOTO_URL, loginResponse.userData!.profile_image.validate());
    }

    await setValue(GENDER, loginResponse.userData!.gender.validate());
    await setValue(NAME, loginResponse.userData!.name.validate());
    await setValue(BIO, loginResponse.userData!.bio.validate());
    await setValue(DOB, loginResponse.userData!.dob.validate());
*/
    if(loginResponse.data == null) {
      print("GOT NULL DATA");
    }

    await setValue(USER_ID, loginResponse.data!.id.validate());
    await setValue(NAME, loginResponse.data!.name.validate());
    await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    await setValue(TOKEN, loginResponse.data!.apiToken.validate());
    await setValue(USER_CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
    await setValue(USER_PROFILE_PHOTO, loginResponse.data!.profileImage.validate());
    await setValue(USER_TYPE, loginResponse.data!.userType.validate());
    await setValue(USER_NAME, loginResponse.data!.username.validate());
    await setValue(USER_STATUS, loginResponse.data!.status.validate());
    await setValue(USER_ADDRESS, loginResponse.data!.address.validate());
    await setValue(COUNTRY_ID, loginResponse.data!.countryId.validate());
    await setValue(CITY_ID, loginResponse.data!.cityId.validate());
    await setValue(UID, loginResponse.data!.uid.validate());
    await setValue(IS_VERIFIED_DELIVERY_MAN, loginResponse.data!.isVerifiedDeliveryMan == 1);
    await clientStore.setClientEmail(loginResponse.data!.email.validate());
    if (getIntAsync(USER_STATUS) == 1) {
      await appStore.setLoggedIn(true);
    } else {
      await appStore.setLoggedIn(false);
    }

    await setValue(USER_PASSWORD, request['password']);
    appStore.setUserProfile(getStringAsync(USER_PROFILE_PHOTO));

    return loginResponse;
  }).catchError((e) {
    print('ERROR WHILE PARSING RESPONSE: ${e.toString()}');
    throw e.toString();
  });
}

Future<void> logout(BuildContext context, {bool isFromLogin = false, bool isDeleteAccount = false}) async {
  clearData() async {
    await removeKey(USER_ID);
    await removeKey(USER_NAME);
    await removeKey(TOKEN);
    await removeKey(USER_CONTACT_NUMBER);
    await removeKey(USER_PROFILE_PHOTO);
    await removeKey(USER_TYPE);
    await removeKey(USER_NAME);
    await removeKey(USER_ADDRESS);
    await removeKey(USER_STATUS);
    await removeKey(COUNTRY_ID);
    await removeKey(COUNTRY_DATA);
    await removeKey(CITY_ID);
    await removeKey(CITY_DATA);
    await removeKey(FILTER_DATA);
    await removeKey(IS_VERIFIED_DELIVERY_MAN);
    await removeKey(IS_LOGGED_IN);
    await removeKey(FCM_TOKEN);
    await appStore.setLoggedIn(false);
    clientStore.setFiltering(false);
    clientStore.availableBal = 0;

    if (!getBoolAsync(REMEMBER_ME) || getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN) {
      await removeKey(USER_EMAIL);
      await removeKey(USER_PASSWORD);
    }
    if (isFromLogin) {
      toast('These credential do not match our records');
    } else {
      if (getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN) {
        Navigator.pushNamedAndRemoveUntil(context, AdminLoginScreen.route, (route) {
          return true;
        });
      } else {
        Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route, (route) {
          return true;
        });
      }
    }
    appStore.setLoading(false);
  }

  if (getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN) {
    removeKey(THEME_MODE_INDEX);
    appStore.setDarkMode(false);
    if (!isFromLogin) {
      Navigator.pop(context);
      appStore.setLoading(true);
    }
  }
  if (isDeleteAccount) {
    clearData();
  } else {
    await logoutApi().then((value) async {
      clearData();
    }).catchError((e) {
      appStore.setLoading(false);
      throw e.toString();
    });
  }
}

/// Profile Update
Future updateProfile({int? id, String? userName, String? name, String? userEmail, String? address, String? contactNumber, Uint8List? image, String? fileName}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = '${id ?? getIntAsync(USER_ID)}';
  if (userName != null) multiPartRequest.fields['username'] = userName.validate();
  if (userEmail != null) multiPartRequest.fields['email'] = userEmail.validate();
  if (name != null) multiPartRequest.fields['name'] = name.validate();
  if (contactNumber != null) multiPartRequest.fields['contact_number'] = contactNumber.validate();
  if (address != null) multiPartRequest.fields['address'] = address.validate();

  if (image != null) {
    multiPartRequest.files.add(MultipartFile.fromBytes('profile_image', image, filename: fileName));
  }

  print('req: ${multiPartRequest.fields} ${multiPartRequest.files}');
  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      LoginResponse res = LoginResponse.fromJson(data);
      if (id == null) {
        await setValue(NAME, res.data!.name.validate());
        await setValue(USER_NAME, res.data!.username.validate());
        await setValue(USER_ADDRESS, res.data!.address.validate());
        await setValue(USER_CONTACT_NUMBER, res.data!.contactNumber.validate());
        await setValue(USER_EMAIL, res.data!.email.validate());
        appStore.setUserProfile(res.data!.profileImage.validate());
      }
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<LDBaseResponse> forgotPassword(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('forget-password', request: req, method: HttpMethod.POST)));
}

Future<LDBaseResponse> changePassword(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('change-password', request: req, method: HttpMethod.POST)));
}

// User Api
Future<UserListModel> getAllUserList({String? type, int? perPage, int? page}) async {
  return UserListModel.fromJson(await handleResponse(await buildHttpResponse('user-list?user_type=$type&page=$page&is_deleted=1&per_page=$perPage', method: HttpMethod.GET)));
}

Future<UpdateUserStatus> updateUserStatus(Map req) async {
  return UpdateUserStatus.fromJson(await handleResponse(await buildHttpResponse('update-user-status', request: req, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteUser(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('delete-user', request: req, method: HttpMethod.POST)));
}

Future<LDBaseResponse> userAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('user-action', request: request, method: HttpMethod.POST)));
}

Future<UserModel> getUserDetail(int id) async {
  return UserModel.fromJson(await handleResponse(await buildHttpResponse('user-detail?id=$id', method: HttpMethod.GET)).then((value) => value['data']));
}

// Country Api
Future<CountryListModel> getCountryList({int? page, bool isDeleted = false, int perPage = 10}) async {
  return CountryListModel.fromJson(
      await handleResponse(await buildHttpResponse(page != null ? 'country-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage' : 'country-list?per_page=-1&is_deleted=${isDeleted ? 1 : 0}', method: HttpMethod.GET)));
}

Future<LDBaseResponse> addCountry(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('country-save', request: request, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteCountry(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('country-delete/$id', method: HttpMethod.POST)));
}

Future<CountryData> getCountryDetail(int id) async {
  return CountryData.fromJson(await handleResponse(await buildHttpResponse('country-detail?id=$id', method: HttpMethod.GET)).then((value) => value['data']));
}

Future<LDBaseResponse> countryAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('country-action', request: request, method: HttpMethod.POST)));
}

// City Api
Future<CityListModel> getCityList({int? page, bool isDeleted = false, int? countryId, int? perPage = 10}) async {
  if (countryId == null) {
    return CityListModel.fromJson(await handleResponse(
        await buildHttpResponse(page != null ? 'city-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage' : 'city-list?per_page=-1&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage', method: HttpMethod.GET)));
  } else {
    return CityListModel.fromJson(await handleResponse(await buildHttpResponse('city-list?per_page=-1&country_id=$countryId', method: HttpMethod.GET)));
  }
}

Future<LDBaseResponse> addCity(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('city-save', request: request, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteCity(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('city-delete/$id', method: HttpMethod.POST)));
}

Future<LDBaseResponse> cityAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('city-action', request: request, method: HttpMethod.POST)));
}

Future<CityData> getCityDetail(int id) async {
  return CityData.fromJson(await handleResponse(await buildHttpResponse('city-detail?id=$id', method: HttpMethod.GET)).then((value) => value['data']));
}

// ExtraCharge Api
Future<ExtraChargesListModel> getExtraChargeList({int? page, bool isDeleted = false, int perPage = 10}) async {
  return ExtraChargesListModel.fromJson(await handleResponse(await buildHttpResponse('extracharge-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage', method: HttpMethod.GET)));
}

Future<LDBaseResponse> addExtraCharge(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('extracharge-save', request: request, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteExtraCharge(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('extracharge-delete/$id', method: HttpMethod.POST)));
}

Future<LDBaseResponse> extraChargeAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('extracharge-action', request: request, method: HttpMethod.POST)));
}

// Document Api
Future<DocumentListModel> getDocumentList({int? page, bool isDeleted = false, int perPage = 10}) async {
  return DocumentListModel.fromJson(await handleResponse(await buildHttpResponse('document-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage', method: HttpMethod.GET)));
}

Future<LDBaseResponse> addDocument(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('document-save', request: request, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteDocument(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('document-delete/$id', method: HttpMethod.POST)));
}

Future<LDBaseResponse> documentAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('document-action', request: request, method: HttpMethod.POST)));
}

// Delivery Man Documents
Future<DeliveryDocumentListModel> getDeliveryDocumentList({int? page, bool isDeleted = false, int? deliveryManId, int? perPage = 10}) async {
  return DeliveryDocumentListModel.fromJson(await handleResponse(await buildHttpResponse(
      deliveryManId != null
          ? 'delivery-man-document-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&delivery_man_id=$deliveryManId&per_page=$perPage'
          : 'delivery-man-document-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage',
      method: HttpMethod.GET)));
}

/// Create Order Api
Future<LDBaseResponse> createOrder(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-save', request: request, method: HttpMethod.POST)));
}

// Order Api
Future<OrderListModel> getAllOrder({int? page, int perPage = 10, String? status}) async {
  return OrderListModel.fromJson(
      await handleResponse(await buildHttpResponse(status != null ? 'order-list?page=$page&status=$status&per_page=$perPage' : 'order-list?page=$page&status=trashed&per_page=$perPage', method: HttpMethod.GET)));
}

// ParcelType Api
Future<ParcelTypeListModel> getParcelTypeList({int? page, int perPage = 10}) async {
  return ParcelTypeListModel.fromJson(
      await handleResponse(await buildHttpResponse(page != null ? 'staticdata-list?type=parcel_type&page=$page&per_page=$perPage' : 'staticdata-list?type=parcel_type&per_page=-1', method: HttpMethod.GET)));
}

Future<LDBaseResponse> addParcelType(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('staticdata-save', request: request, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteParcelType(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('staticdata-delete/$id', method: HttpMethod.POST)));
}

// Payment Gateway Api
Future<PaymentGatewayListModel> getPaymentGatewayList() async {
  return PaymentGatewayListModel.fromJson(await handleResponse(await buildHttpResponse('paymentgateway-list?perPage=-1', method: HttpMethod.GET)));
}

Future<MultipartRequest> getMultiPartRequest(String endPoint, {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  multiPartRequest.headers.addAll(buildHeaderTokens());
  http.Response response = await http.Response.fromStream(await multiPartRequest.send());

  if (response.statusCode >= 200 && response.statusCode <= 206) {
    onSuccess?.call(response.body.isEmpty ? null : jsonDecode(response.body));
  } else {
    onError?.call(language.somethingWentWrong);
  }
}

// Dashboard Api
Future<DashboardModel> getDashBoardData() async {
  return DashboardModel.fromJson(await handleResponse(await buildHttpResponse('dashboard-detail', method: HttpMethod.GET)));
}

Future<LDBaseResponse> getRestoreOrderApi(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-action', request: req, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteOrderApi(int OrderId) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-delete/$OrderId', method: HttpMethod.POST)));
}

Future<UserListModel> getAllDeliveryBoyList({String? type, int? page, int? cityID, int? countryId, int? perPage = 10}) async {
  return UserListModel.fromJson(await handleResponse(await buildHttpResponse('user-list?user_type=$type&page=$page&country_id=$countryId&city_id=$cityID&status=1&per_page=$perPage', method: HttpMethod.GET)));
}

Future<LDBaseResponse> orderAssign(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-action', request: req, method: HttpMethod.POST)));
}

Future<OrderDetailModel> orderDetail({required int orderId}) async {
  return OrderDetailModel.fromJson(await handleResponse(await buildHttpResponse('order-detail?id=$orderId', method: HttpMethod.GET)));
}

Future<NotificationModel> getNotification({required int page}) async {
  return NotificationModel.fromJson(await handleResponse(await buildHttpResponse('notification-list?limit=20&page=$page', method: HttpMethod.POST)));
}

Future<AppSettingModel> getAppSetting() async {
  return AppSettingModel.fromJson(await handleResponse(await buildHttpResponse('get-appsetting', method: HttpMethod.GET)));
}

Future<LDBaseResponse> setNotification(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('update-appsetting', request: req, method: HttpMethod.POST)));
}

Future<AutoCompletePlacesListModel> placeAutoCompleteApi({String searchText = '', String countryCode = "in", String language = 'en'}) async {
  return AutoCompletePlacesListModel.fromJson(await handleResponse(await buildHttpResponse('place-autocomplete-api?country_code=$countryCode&language=$language&search_text=$searchText', method: HttpMethod.GET)));
}

Future<PlaceIdDetailModel> getPlaceDetail({String placeId = ''}) async {
  return PlaceIdDetailModel.fromJson(await handleResponse(await buildHttpResponse('place-detail-api?placeid=$placeId', method: HttpMethod.GET)));
}

Future<LDBaseResponse> logoutApi() async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('logout?clear=fcm_token', method: HttpMethod.GET)));
}

// Wallet Api
Future<WithDrawListModel> getWithdrawList({int? page, int perPage = 10}) async {
  return WithDrawListModel.fromJson(await handleResponse(await buildHttpResponse('withdrawrequest-list?page=$page&per_page=$perPage', method: HttpMethod.GET)));
}

Future<LDBaseResponse> deleteWithdraw(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('decline-withdrawrequest', request: req, method: HttpMethod.POST)));
}

Future<LDBaseResponse> approveWithdraw(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('approved-withdrawrequest', request: req, method: HttpMethod.POST)));
}

Future<UserDetailModel> userDetailApi(int id) async {
  return UserDetailModel.fromJson(await handleResponse(await buildHttpResponse('user-profile-detail?id=$id', method: HttpMethod.GET)));
}

Future<WalletHistory> walletUserByUser(int page, int userId) async {
  return WalletHistory.fromJson(await handleResponse(await buildHttpResponse('wallet-list?page=$page&user_id=$userId', method: HttpMethod.GET)));
}

Future<EarningList> earningUserByUser(int page, int userId) async {
  return EarningList.fromJson(await handleResponse(await buildHttpResponse('payment-list?page=$page&delivery_man_id=$userId&type=earning', method: HttpMethod.GET)));
}
