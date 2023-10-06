import 'package:get/get.dart';

class VoiceCallViewState {
  RxBool isJoined = false.obs;
  RxBool openMicrophone = true.obs;
  RxBool enableSpeaker = true.obs;
  RxString callTime = '00.00'.obs;
  RxString callStatus = 'not connected'.obs;
  RxString callTimeNum = "not connected".obs;

  var toToken = ''.obs;
  var toName = ''.obs;
  var toAvatar = ''.obs;
  var docId = ''.obs;
  var callRole = 'audience'.obs;
  var channelId = ''.obs;
}
