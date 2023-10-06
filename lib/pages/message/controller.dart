import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'index.dart';

class MessageController extends GetxController {
  MessageController();
  final state = MessageState();
  final db = FirebaseFirestore.instance;
  final token = UserStore.to.profile.token;

  Future<void> goProfile() async {
    await Get.toNamed(
      AppRoutes.profile,
      arguments: state.headDetail.value,
    );
    getProfile();
  }

  void goTabStatus() {
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );
    state.tabStatus.value = !state.tabStatus.value;
    if (state.tabStatus.value) {
      asyncLoadMsgData();
    } else {
      asyncLoadCallData();
    }
    EasyLoading.dismiss();
  }

  Future<void> asyncLoadCallData() async {
    state.callList.clear();

    var fromChatCall = await db
        .collection('chatcall')
        .withConverter(
          fromFirestore: ChatCall.fromFirestore,
          toFirestore: (ChatCall msg, options) => msg.toFirestore(),
        )
        .where('from_token', isEqualTo: token)
        .limit(30)
        .get();

    var toChatCall = await db
        .collection('chatcall')
        .withConverter(
          fromFirestore: ChatCall.fromFirestore,
          toFirestore: (ChatCall msg, options) => msg.toFirestore(),
        )
        .where('to_token', isEqualTo: token)
        .limit(30)
        .get();

    if (fromChatCall.docs.isNotEmpty) {
      await addChatCall(fromChatCall.docs);
    }

    if (toChatCall.docs.isNotEmpty) {
      await addChatCall(toChatCall.docs);
    }

    state.callList.value.sort((a, b) {
      if (b.lastTime == null) {
        return 0;
      }
      if (a.lastTime == null) {
        return 0;
      }
      return b.lastTime!.compareTo(a.lastTime!);
    });
  }

  addChatCall(List<QueryDocumentSnapshot<ChatCall>> data) {
    data.forEach((element) {
      var item = element.data();
      CallMessage message = CallMessage();
      // saves the common properties
      message.docId = element.id;
      message.lastTime = item.last_time;
      message.callTime = item.call_time;

      if (item.from_token == token) {
        message.name = item.to_name;
        message.avatar = item.to_avatar;
        message.token = item.to_token;
      } else {
        message.name = item.from_name;
        message.avatar = item.from_avatar;
        message.token = item.from_token;
      }

      state.callList.add(message);
    });
  }

  Future<void> asyncLoadMsgData() async {
    var fromMessages = await db
        .collection('message')
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where('from_token', isEqualTo: token)
        .get();

    var toMessages = await db
        .collection('message')
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where('to_token', isEqualTo: token)
        .get();

    state.msgList.clear();

    if (fromMessages.docs.isNotEmpty) {
      await addMessage(fromMessages.docs);
    }

    if (toMessages.docs.isNotEmpty) {
      await addMessage(toMessages.docs);
    }
  }

  addMessage(List<QueryDocumentSnapshot<Msg>> data) {
    data.forEach((element) {
      var item = element.data();
      Message message = Message();
      // saves the common properties
      message.docId = element.id;
      message.lastTime = item.last_time;
      message.msgNum = item.msg_num;
      message.lastMsg = item.last_msg;

      if (item.from_token == token) {
        message.name = item.to_name;
        message.avatar = item.to_avatar;
        message.token = item.to_token;
        message.online = item.to_online;
        message.msgNum = item.to_msg_num ?? 0;
      } else {
        message.name = item.from_name;
        message.avatar = item.from_avatar;
        message.token = item.from_token;
        message.online = item.from_online;
        message.msgNum = item.from_msg_num ?? 0;
      }

      state.msgList.add(message);
    });
  }

  @override
  void onReady() {
    super.onReady();
    firebaseMessageSetup();
  }

  @override
  void onInit() {
    super.onInit();
    getProfile();
    _snapshots();
  }

  _snapshots() async {
    var token = UserStore.to.profile.token;
    var toMessageRef = await db
        .collection('message')
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where('to_token', isEqualTo: token);

    var fromMessageRef = await db
        .collection('message')
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where('from_token', isEqualTo: token);

    toMessageRef.snapshots().listen((event) {
      asyncLoadMsgData();
    });

    fromMessageRef.snapshots().listen((event) {
      asyncLoadMsgData();
    });
  }

  void getProfile() async {
    var profile = UserStore.to.profile;
    state.headDetail.value = profile;
    state.headDetail.refresh();
  }

  firebaseMessageSetup() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('...my token = $fcmToken');
    if (fcmToken != null) {
      BindFcmTokenRequestEntity bindFcmTokenRequestEntity =
          BindFcmTokenRequestEntity();
      bindFcmTokenRequestEntity.fcmtoken = fcmToken;
      await ChatAPI.bind_fcmtoken(params: bindFcmTokenRequestEntity);
    }
  }
}
