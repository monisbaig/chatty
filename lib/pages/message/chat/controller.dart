import 'dart:io';

import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/widgets/toast.dart';
import 'package:chatty/pages/message/chat/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatController extends GetxController {
  ChatController();
  final state = ChatState();
  late String docId;
  final myInputController = TextEditingController();
  final myScrollController = ScrollController();
  final token = UserStore.to.profile.token;
  final db = FirebaseFirestore.instance;
  dynamic listener;
  dynamic isLoadMore = true;
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  void goMore() {
    state.moreStatus.value = state.moreStatus.value ? false : true;
  }

  void audioCall() {
    state.moreStatus.value = false;
    Get.toNamed(
      AppRoutes.voiceCall,
      parameters: {
        'to_token': state.toToken.value,
        'to_name': state.toName.value,
        'to_avatar': state.toAvatar.value,
        'call_role': 'anchor',
        'doc_id': docId,
      },
    );
  }

  Future<bool> requestPermission(Permission permission) async {
    var permissionStatus = await permission.status;
    if (permissionStatus != PermissionStatus.granted) {
      var status = await permission.request();
      if (status != PermissionStatus.granted) {
        toastInfo(msg: 'Please enable permission to have video call');
        if (GetPlatform.isAndroid) {
          await openAppSettings();
        }
        return false;
      }
    }
    return true;
  }

  Future<void> videoCall() async {
    state.moreStatus.value = false;
    bool micStatus = await requestPermission(Permission.microphone);
    bool camStatus = await requestPermission(Permission.camera);

    if (GetPlatform.isAndroid && micStatus && camStatus) {
      Get.toNamed(
        AppRoutes.videoCall,
        parameters: {
          'to_token': state.toToken.value,
          'to_name': state.toName.value,
          'to_avatar': state.toAvatar.value,
          'call_role': 'anchor',
          'doc_id': docId,
        },
      );
    } else {
      Get.toNamed(
        AppRoutes.videoCall,
        parameters: {
          'to_token': state.toToken.value,
          'to_name': state.toName.value,
          'to_avatar': state.toAvatar.value,
          'call_role': 'anchor',
          'doc_id': docId,
        },
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    docId = data['doc_id']!;
    state.toToken.value = data['to_token'] ?? '';
    state.toName.value = data['to_name'] ?? '';
    state.toAvatar.value = data['to_avatar'] ?? '';
    state.toOnline.value = data['to_online'] ?? '1';
    // clearing red dots
    clearMsgNum(docId);
  }

  Future<void> clearMsgNum(String docId) async {
    var messageResult = await db
        .collection('message')
        .doc(docId)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();
    // to know if we have any unread messages or calls
    if (messageResult.data() != null) {
      var item = messageResult.data()!;

      int toMsgNum = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int fromMsgNum = item.from_msg_num == null ? 0 : item.from_msg_num!;

      if (item.from_token == token) {
        toMsgNum = 0;
      } else {
        fromMsgNum = 0;
      }
      await db.collection('message').doc(docId).update(
        {
          'to_msg_num': toMsgNum,
          'from_msg_num': fromMsgNum,
        },
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
    state.msgContentList.clear();
    final messages = db
        .collection('message')
        .doc(docId)
        .collection('messageList')
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msg, options) => msg.toFirestore(),
        )
        .orderBy('addtime', descending: true)
        .limit(15);
    listener = messages.snapshots().listen((event) {
      List<Msgcontent> tempMsgList = <Msgcontent>[];
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            if (change.doc.data() != null) {
              tempMsgList.add(change.doc.data()!);
            }
            break;

          case DocumentChangeType.modified:
            break;

          case DocumentChangeType.removed:
            break;
        }
      }

      tempMsgList.reversed.forEach((element) {
        state.msgContentList.value.insert(0, element);
      });

      state.msgContentList.refresh();

      if (myScrollController.hasClients) {
        myScrollController.animateTo(
          myScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    myScrollController.addListener(() {
      if (myScrollController.offset + 10 >
          myScrollController.position.maxScrollExtent) {
        if (isLoadMore) {
          state.isLoading.value = true;
          // to stop request to firebase
          isLoadMore = false;
          asyncLoadMoreData();
        }
      }
    });
  }

  Future<void> imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      uploadFile();
    } else {
      print('No image selected');
    }
  }

  Future<void> uploadFile() async {
    var result = await ChatAPI.upload_img(file: _photo);
    if (result.code == 0) {
      sendImageMessage(result.data!);
    } else {
      toastInfo(msg: 'Sending image error');
    }
  }

  Future<void> asyncLoadMoreData() async {
    final messages = await db
        .collection('message')
        .doc(docId)
        .collection('messageList')
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msg, options) => msg.toFirestore(),
        )
        .orderBy('addtime', descending: true)
        .where('addtime', isLessThan: state.msgContentList.value.last.addtime)
        .limit(10)
        .get();

    if (messages.docs.isNotEmpty) {
      messages.docs.forEach((element) {
        var data = element.data();
        state.msgContentList.value.add(data);
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      isLoadMore = true;
    });
    state.isLoading.value = false;
  }

  Future<void> sendMessage() async {
    String sendContent = myInputController.text;
    if (sendContent.isEmpty) {
      toastInfo(msg: 'Content is empty');
      return;
    }

    var msgData = Msgcontent(
      token: token,
      content: sendContent,
      type: 'text',
      addtime: Timestamp.now(),
    );

    await db
        .collection('message')
        .doc(docId)
        .collection('messageList')
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msg, options) => msg.toFirestore(),
        )
        .add(msgData)
        .then((DocumentReference doc) {
      myInputController.clear();
    });

    var messageResult = await db
        .collection('message')
        .doc(docId)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();

    if (messageResult.data() != null) {
      var item = messageResult.data()!;

      int toMsgNum = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int fromMsgNum = item.from_msg_num == null ? 0 : item.from_msg_num!;

      if (item.from_token == token) {
        fromMsgNum = fromMsgNum + 1;
      } else {
        toMsgNum = toMsgNum + 1;
      }
      await db.collection('message').doc(docId).update(
        {
          'to_msg_num': toMsgNum,
          'from_msg_num': fromMsgNum,
          'last_msg': sendContent,
          'last_time': Timestamp.now(),
        },
      );
    }
  }

  Future<void> sendImageMessage(String url) async {
    var msgData = Msgcontent(
      token: token,
      content: url,
      type: 'image',
      addtime: Timestamp.now(),
    );

    await db
        .collection('message')
        .doc(docId)
        .collection('messageList')
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msg, options) => msg.toFirestore(),
        )
        .add(msgData)
        .then((DocumentReference doc) {});

    // collection().get().docs.data()
    var messageResult = await db
        .collection('message')
        .doc(docId)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();
    // to know if we have any unread messages or calls
    if (messageResult.data() != null) {
      var item = messageResult.data()!;

      int toMsgNum = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int fromMsgNum = item.from_msg_num == null ? 0 : item.from_msg_num!;

      if (item.from_token == token) {
        fromMsgNum += fromMsgNum;
      } else {
        toMsgNum += toMsgNum;
      }
      await db.collection('message').doc(docId).update({
        'to_msg_num': toMsgNum,
        'from_msg_num': fromMsgNum,
        'last_msg': '⟦image⟧',
        'last_time': Timestamp.now(),
      });
    }
  }

  void closeAllPop() {
    Get.focusScope?.unfocus();
    state.moreStatus.value = false;
  }

  @override
  void onClose() {
    super.onClose();
    listener.cancel();
    myInputController.dispose();
    myScrollController.dispose();
    clearMsgNum(docId);
  }
}
