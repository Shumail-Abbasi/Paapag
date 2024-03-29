import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/DeliveryDocumentListModel.dart';
import '../../main/models/DocumentListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/network/NetworkUtils.dart';
import '../../main/utils/Constants.dart';

class VerifyDeliveryPersonScreen extends StatefulWidget {
  static String tag = '/VerifyDeliveryPersonScreen';

  @override
  VerifyDeliveryPersonScreenState createState() => VerifyDeliveryPersonScreenState();
}

class VerifyDeliveryPersonScreenState extends State<VerifyDeliveryPersonScreen> {
  List<DocumentData> documents = [];
  List<DeliveryDocumentData> deliveryPersonDocuments = [];
  DocumentListModel? documentListModel;
  FilePickerResult? filePickerResult;
  List<File>? imageFiles;
  List<String> eAttachments = [];
  int? updateDocId;
  List<int>? uploadedDocList = [];
  DocumentData? selectedDoc;
  int docId = 0;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    await getDocListApiCall();
    await getDeliveryDocListApiCall();
  }

  /// get Document list
  getDocListApiCall() {
    appStore.setLoading(true);
    getDocumentList().then((res) {
      documents.addAll(res.data!);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  ///Get Delivery Documents List
  getDeliveryDocListApiCall() {
    getDeliveryPersonDocumentList().then((res) {
      appStore.setLoading(false);
      deliveryPersonDocuments.addAll(res.data!);
      deliveryPersonDocuments.forEach((element) {
        uploadedDocList!.add(element.documentId!);
        updateDocId = element.id;
        log(uploadedDocList);
      });
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  /// SelectImage
  getMultipleFile(int? docId, {int? updateId}) async {
    filePickerResult = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf']);

    if (filePickerResult != null) {
      showConfirmDialogCustom(
        context,
        title: language.uploadFileConfirmationMsg,
        onAccept: (BuildContext context) {
          setState(() {
            imageFiles = filePickerResult!.paths.map((path) => File(path!)).toList();
            eAttachments = [];
          });
          addDocument(docId, updateId: updateId);
        },
        positiveText: language.yes,
        negativeText: language.no,
        primaryColor: colorPrimary,
      );
    } else {}
  }

  /// Add Documents
  addDocument(int? docId, {int? updateId}) async {
    final url = 'delivery-man-document-save';
    final multiPartRequest = FormData();

    multiPartRequest.fields
      ..add(MapEntry('id', updateId != null ? updateId.toString() : ''))
      ..add(MapEntry('delivery_man_id', getIntAsync(USER_ID).toString()))
      ..add(MapEntry('document_id', docId.toString()))
      ..add(MapEntry('is_verified', '0'));

    if (imageFiles != null) {
      multiPartRequest.files.add(MapEntry('delivery_man_document', await MultipartFile.fromFile(imageFiles!.first.path)));
    }
    final response = await buildHttpResponse(url, method: HttpMethod.POST_FORM, formData: multiPartRequest).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });

    try {
      await handleResponse(response);
      deliveryPersonDocuments.clear();
      getDeliveryDocListApiCall();
    } catch (error) {
      toast(error.toString(), print: true);
      appStore.setLoading(false);
    }

    log(multiPartRequest);
    appStore.setLoading(true);
  }

  /// Delete Documents
  deleteDoc(int? id) {
    appStore.setLoading(true);
    deleteDeliveryDoc(id!).then((value) {
      toast(value.message, print: true);
      uploadedDocList!.clear();
      deliveryPersonDocuments.clear();
      getDeliveryDocListApiCall();
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.verifyDocument)),
      body: BodyCornerWidget(
        child: Observer(
          builder: (_) => Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (documents.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.grey.withOpacity(0.15)),
                            child: DropdownButtonFormField<DocumentData>(
                              decoration: InputDecoration.collapsed(hintText: null),
                              hint: Text(language.selectDocument, style: primaryTextStyle()),
                              value: selectedDoc,
                              dropdownColor: context.cardColor,
                              items: documents.map((DocumentData e) {
                                return DropdownMenuItem<DocumentData>(
                                    value: e,
                                    child: Text(
                                      e.name! + '${e.isRequired == 1 ? '*' : ''}',
                                      style: primaryTextStyle(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ));
                              }).toList(),
                              onChanged: (DocumentData? value) async {
                                selectedDoc = value;
                                docId = value!.id!;
                                setState(() {});
                              },
                            ),
                          ).expand(),
                        if (docId != 0)
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(left: 16),
                            decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary, borderRadius: BorderRadius.circular(defaultRadius)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 24),
                                8.width,
                                Text(language.addDocument, style: secondaryTextStyle(color: Colors.white)),
                              ],
                            ),
                          ).onTap(() {
                            getMultipleFile(docId);
                          }).visible(!uploadedDocList!.contains(docId)),
                      ],
                    ),
                    30.height,
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: deliveryPersonDocuments.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(deliveryPersonDocuments[index].documentName!, style: boldTextStyle()).expand(),
                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: colorPrimary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: colorPrimary),
                                  ),
                                  child: Icon(Icons.edit, color: colorPrimary, size: 14),
                                ).onTap(() {
                                  getMultipleFile(deliveryPersonDocuments[index].documentId, updateId: deliveryPersonDocuments[index].id.validate());
                                }).visible(deliveryPersonDocuments[index].isVerified == 0),
                                8.width,
                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: Icon(Icons.delete, color: Colors.red, size: 14),
                                ).onTap(() {
                                  deleteDoc(deliveryPersonDocuments[index].id);
                                }).visible(deliveryPersonDocuments[index].isVerified == 0),
                                Icon(Icons.verified_user, color: Colors.green).visible(deliveryPersonDocuments[index].isVerified == 1),
                              ],
                            ),
                            12.height,
                            deliveryPersonDocuments[index].deliveryManDocument!.contains('.pdf')
                                ? Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.grey.withOpacity(0.2)),
                                    child: Text(deliveryPersonDocuments[index].deliveryManDocument!.split('/').last, style: primaryTextStyle()),
                                  ).onTap(() {
                                    commonLaunchUrl(deliveryPersonDocuments[index].deliveryManDocument.validate());
                                  })
                                : commonCachedNetworkImage(deliveryPersonDocuments[index].deliveryManDocument!, height: 200, width: context.width(), fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(8)
                                    .onTap(() {
                                    commonLaunchUrl(deliveryPersonDocuments[index].deliveryManDocument!.validate());
                                  }),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(height: 30);
                      },
                    ),
                  ],
                ),
              ),
              emptyWidget().visible(!appStore.isLoading && documents.isEmpty && deliveryPersonDocuments.isEmpty),
              loaderWidget().center().visible(appStore.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
