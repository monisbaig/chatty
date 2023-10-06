import 'package:chatty/common/entities/entities.dart';
import 'package:get/get.dart';

class MessageState {
  var headDetail = UserItem().obs;
  RxBool tabStatus = true.obs;
  RxList<Message> msgList = <Message>[].obs;
  RxList<CallMessage> callList = <CallMessage>[].obs;
}
