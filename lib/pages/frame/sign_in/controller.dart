import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../common/apis/user.dart';
import '../../../common/store/user.dart';
import '../../../common/widgets/toast.dart';
import 'index.dart';

class SignInController extends GetxController {
  SignInController();
  final state = SignInState();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['openId'],
  );

  Future<void> handleSignIn(String type) async {
    // 1. Email 2. Google 3. Facebook 4.Apple 5. Phone
    try {
      if (type == 'phone number') {
        if (kDebugMode) {
          print('...you are logging in with phone number');
        }
      } else if (type == 'google') {
        final GoogleSignInAccount? user = await GoogleSignIn().signIn();

        final GoogleSignInAuthentication googleAuth =
            await user!.authentication;

        if (googleAuth.accessToken != null && googleAuth.idToken != null) {
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);

          String id = user.id;
          String? name = user.displayName;
          String email = user.email;
          String photoUrl = user.photoUrl ?? 'assets/icons/google.png';

          LoginRequestEntity loginPanelListRequestEntity = LoginRequestEntity();

          loginPanelListRequestEntity.avatar = photoUrl;
          loginPanelListRequestEntity.name = name;
          loginPanelListRequestEntity.email = email;
          loginPanelListRequestEntity.openId = id;
          loginPanelListRequestEntity.type = 2;

          asyncPostAllData(loginPanelListRequestEntity);
        }
      } else {
        if (kDebugMode) {
          print('...login type not sure');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('...error with login $e');
      }
    }
  }

  asyncPostAllData(LoginRequestEntity loginRequestEntity) async {
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );

    var result = await UserAPI.login(params: loginRequestEntity);
    if (result.code == 0) {
      await UserStore.to.saveProfile(result.data!);
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      toastInfo(msg: 'Internet error');
    }

    Get.offAllNamed(AppRoutes.message);
  }
}
