import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/chat.dart';
import 'package:chatty/common/entities/chatcall.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/values/server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/entities/msg.dart';
import '../../../common/entities/msgcontent.dart';
import 'state.dart';

class VoiceCallViewController extends GetxController {
  VoiceCallViewController();
  final state = VoiceCallViewState();
  final player = AudioPlayer();
  String appId = APPID;
  final db = FirebaseFirestore.instance;
  final profileToken = UserStore.to.profile.token;
  late final RtcEngine engine;
  ChannelProfileType channelProfileType =
      ChannelProfileType.channelProfileCommunication;

  late final Timer calltimer;
  int call_m = 0;
  int call_s = 0;
  int call_h = 0;

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    state.toName.value = data['to_name'] ?? '';
    state.toAvatar.value = data['to_avatar'] ?? '';
    state.callRole.value = data['call_role'] ?? '';
    state.docId.value = data['doc_id'] ?? '';
    state.toToken.value = data['to_token'] ?? '';
    initEngine();
  }

  Future<void> initEngine() async {
    await player.setAsset('assets/Sound_Horizon.mp3');
    engine = createAgoraRtcEngine();

    await engine.initialize(
      RtcEngineContext(
        appId: appId,
      ),
    );

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          print('...error:$err, msg: $msg');
        },
        onJoinChannelSuccess: (connection, elapsed) {
          print('...onConnection ${connection.toJson()}');
          state.isJoined.value = true;
        },
        onUserJoined: (connection, remoteUid, elapsed) async {
          await player.pause();
          if (state.callRole == "anchor") {
            callTime();
          }
        },
        onLeaveChannel: (connection, stats) {
          print('...user left the room.');
          state.isJoined.value = false;
        },
        onRtcStats: (connection, stats) {
          print('...time.');
          print(stats.duration);
        },
      ),
    );

    await engine.enableAudio();
    await engine.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );
    await engine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    await joinChannel();
    if (state.callRole == 'anchor') {
      await sendNotification('voice');
      await player.play();
    }
  }

  callTime() async {
    calltimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        call_s = call_s + 1;
        if (call_s >= 60) {
          call_s = 0;
          call_m = call_m + 1;
        }
        if (call_m >= 60) {
          call_m = 0;
          call_h = call_h + 1;
        }
        var h = call_h < 10 ? "0$call_h" : "$call_h";
        var m = call_m < 10 ? "0$call_m" : "$call_m";
        var s = call_s < 10 ? "0$call_s" : "$call_s";

        if (call_h == 0) {
          state.callTime.value = "$m:$s";
          state.callTimeNum.value = "$call_m m and $call_s s";
        } else {
          state.callTime.value = "$h:$m:$s";
          state.callTimeNum.value = "$call_h h $call_m m and $call_s s";
        }
      },
    );
  }

  Future<void> sendNotification(String callType) async {
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.call_type = callType;
    callRequestEntity.to_token = state.toToken.value;
    callRequestEntity.to_avatar = state.toAvatar.value;
    callRequestEntity.doc_id = state.docId.value;
    callRequestEntity.to_name = state.toName.value;
    var res = await ChatAPI.call_notifications(params: callRequestEntity);
    if (res.code == 0) {
      print('Notification successful');
    } else {
      print('Could not send notification');
    }
  }

  Future<String> getToken() async {
    if (state.callRole == 'anchor') {
      state.channelId.value = md5
          .convert(utf8.encode('${profileToken}_${state.toToken}'))
          .toString();
    } else {
      state.channelId.value =
          md5.convert(utf8.encode('${state.toToken}_$profileToken')).toString();
    }
    CallTokenRequestEntity callTokenRequestEntity = CallTokenRequestEntity();
    callTokenRequestEntity.channel_name = state.channelId.value;
    print("...channel id is ${state.channelId.value}");
    print("...access token is ${UserStore.to.token}");
    var res = await ChatAPI.call_token(params: callTokenRequestEntity);
    if (res.code == 0) {
      return res.data!;
    }

    return '';
  }

  Future<void> joinChannel() async {
    await Permission.microphone.request();
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );

    String token = await getToken();
    if (token.isEmpty) {
      EasyLoading.dismiss();
      Get.back();
      return;
    }

    await engine.joinChannel(
      token: token,
      channelId: state.channelId.value,
      uid: 0,
      options: ChannelMediaOptions(
        channelProfile: channelProfileType,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    if (state.callRole == "audience") {
      callTime();
    }

    EasyLoading.dismiss();
  }

  Future<void> addCallTime() async {
    var profile = UserStore.to.profile;
    var metaData = ChatCall(
      from_token: profile.token,
      to_token: state.toToken.value,
      from_name: profile.name,
      to_name: state.toName.value,
      from_avatar: profile.avatar,
      to_avatar: state.toAvatar.value,
      call_time: state.callTime.value,
      type: 'voice',
      last_time: Timestamp.now(),
    );

    await db
        .collection('chatcall')
        .withConverter(
          fromFirestore: ChatCall.fromFirestore,
          toFirestore: (ChatCall call, options) => call.toFirestore(),
        )
        .add(metaData);

    String sendcontent = "Call time ${state.callTimeNum.value}【voice】";
    sendMessage(sendcontent);
  }

  sendMessage(String sendcontent) async {
    if (state.docId.value.isEmpty) {
      return;
    }
    final content = Msgcontent(
      token: profileToken,
      content: sendcontent,
      type: "text",
      addtime: Timestamp.now(),
    );

    await db
        .collection("message")
        .doc(state.docId.value)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .add(content);

    var message_res = await db
        .collection("message")
        .doc(state.docId.value)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();

    if (message_res.data() != null) {
      var item = message_res.data()!;

      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;

      if (item.from_token == profileToken) {
        from_msg_num = from_msg_num + 1;
      } else {
        to_msg_num = to_msg_num + 1;
      }
      await db.collection("message").doc(state.docId.value).update(
        {
          "to_msg_num": to_msg_num,
          "from_msg_num": from_msg_num,
          "last_msg": sendcontent,
          "last_time": Timestamp.now()
        },
      );
    }
  }

  Future<void> leaveChannel() async {
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );
    await player.pause();
    state.isJoined.value = false;
    EasyLoading.dismiss();
    Get.back();
  }

  Future<void> _dispose() async {
    super.dispose();
    await player.pause();
    await engine.leaveChannel();
    await addCallTime();
    await engine.release();
    await player.stop();
  }

  @override
  void onClose() {
    super.onClose();
    _dispose();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }
}
