import 'package:chatty/common/middlewares/middlewares.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/contact/index.dart';
import '../../pages/frame/email_login/index.dart';
import '../../pages/frame/forgot/index.dart';
import '../../pages/frame/phone/index.dart';
import '../../pages/frame/register/index.dart';
import '../../pages/frame/send_code/index.dart';
import '../../pages/frame/sign_in/index.dart';
import '../../pages/frame/welcome/index.dart';
import '../../pages/message/chat/index.dart';
import '../../pages/message/index.dart';
import '../../pages/message/photoview/index.dart';
import '../../pages/message/videocall/index.dart';
import '../../pages/message/voicecall/index.dart';
import '../../pages/profile/index.dart';
import 'routes.dart';

class AppPages {
  static const initial = AppRoutes.initial;
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInPage(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: AppRoutes.message,
      page: () => const MessagePage(),
      binding: MessageBinding(),
      middlewares: [
        RouteAuthMiddleware(priority: 1),
      ],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.contact,
      page: () => const ContactPage(),
      binding: ContactBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.voiceCall,
      page: () => const VoiceCallViewPage(),
      binding: VoiceCallViewBinding(),
    ),
    GetPage(
      name: AppRoutes.videoCall,
      page: () => const VideoCallPage(),
      binding: VideoCallBinding(),
    ),
    GetPage(
      name: AppRoutes.emailLogin,
      page: () => const EmailLoginPage(),
      binding: EmailLoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.forgot,
      page: () => ForgotPage(),
      binding: ForgotBinding(),
    ),
    GetPage(
      name: AppRoutes.phone,
      page: () => PhonePage(),
      binding: PhoneBinding(),
    ),
    GetPage(
      name: AppRoutes.sendCode,
      page: () => SendCodePage(),
      binding: SendCodeBinding(),
    ),
    GetPage(
      name: AppRoutes.photoImgView,
      page: () => PhotoImgViewPage(),
      binding: PhotoImgViewBinding(),
    ),

    /*
    // 需要登录
    // GetPage(
    //   name: AppRoutes.Application,
    //   page: () => ApplicationPage(),
    //   binding: ApplicationBinding(),
    //   middlewares: [
    //     RouteAuthMiddleware(priority: 1),
    //   ],
    // ),
    */
  ];
}
