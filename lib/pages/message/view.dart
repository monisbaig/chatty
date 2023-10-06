import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/utils/utils.dart';
import 'package:chatty/common/values/values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'index.dart';

class MessagePage extends GetView<MessageController> {
  const MessagePage({super.key});

  Widget chatListItem(Message item) {
    return Container(
      padding: EdgeInsets.only(top: 10.h, left: 0.w, right: 0.w, bottom: 10.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom:
              BorderSide(width: 1, color: AppColors.primarySecondaryBackground),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (item.docId != null) {
            Get.toNamed(
              '/chat',
              parameters: {
                'doc_id': item.docId!,
                'to_token': item.token!,
                'to_name': item.name!,
                'to_avatar': item.avatar!,
                'to_online': item.online!.toString(),
              },
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44.w,
              height: 44.w,
              margin: EdgeInsets.only(top: 0.h, left: 0.w, right: 10.w),
              decoration: BoxDecoration(
                color: AppColors.primarySecondaryBackground,
                borderRadius: BorderRadius.all(
                  Radius.circular(22.w),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: item.avatar == null
                  ? const Image(
                      image: AssetImage('assets/images/account_header.png'),
                    )
                  : CachedNetworkImage(
                      imageUrl: item.avatar!,
                      height: 44.w,
                      width: 44.w,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(22.w)),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.fill
                              // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                              ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Image(
                        image: AssetImage('assets/images/account_header.png'),
                      ),
                    ),
            ),
            // 右侧
            Container(
              padding:
                  EdgeInsets.only(top: 0.w, left: 0.w, right: 0.w, bottom: 0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // center
                  SizedBox(
                    width: 175.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${item.name}",
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.bold,
                            color: AppColors.thirdElement,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          "${item.lastMsg}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.normal,
                            color: AppColors.primarySecondaryElementText,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 85.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          item.lastTime == null
                              ? ""
                              : duTimeLineFormat(
                                  (item.lastTime as Timestamp).toDate(),
                                ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.normal,
                            color: AppColors.thirdElementText,
                            fontSize: 12.sp,
                          ),
                        ),
                        item.msgNum == 0
                            ? Container()
                            : Container(
                                padding: EdgeInsets.only(
                                  left: 4.w,
                                  right: 4.w,
                                  top: 0.h,
                                  bottom: 0.h,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "${item.msgNum}",
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.primaryElementText,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget callListItem(CallMessage item) {
    return Container(
      padding: EdgeInsets.only(top: 10.h, left: 0.w, right: 0.w, bottom: 10.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom:
              BorderSide(width: 1, color: AppColors.primarySecondaryBackground),
        ),
      ),
      child: InkWell(
        onTap: () {
          // if (item.docId != null) {
          //   Get.toNamed(
          //     '/chat',
          //     parameters: {
          //       'doc_id': item.docId!,
          //       'to_token': item.token!,
          //       'to_name': item.name!,
          //       'to_avatar': item.avatar!,
          //       'to_online': item.online!.toString(),
          //     },
          //   );
          // }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44.w,
              height: 44.w,
              margin: EdgeInsets.only(top: 0.h, left: 0.w, right: 10.w),
              decoration: BoxDecoration(
                color: AppColors.primarySecondaryBackground,
                borderRadius: BorderRadius.all(Radius.circular(22.w)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: item.avatar == null
                  ? const Image(
                      image: AssetImage('assets/images/account_header.png'),
                    )
                  : CachedNetworkImage(
                      imageUrl: item.avatar!,
                      height: 44.w,
                      width: 44.w,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(22.w),
                          ),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.fill
                              // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                              ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Image(
                        image: AssetImage('assets/images/account_header.png'),
                      ),
                    ),
            ),
            Container(
              padding:
                  EdgeInsets.only(top: 0.w, left: 0.w, right: 0.w, bottom: 0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // center
                  SizedBox(
                    width: 175.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${item.name}",
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.bold,
                            color: AppColors.thirdElement,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          "${item.callTime}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.normal,
                            color: AppColors.primarySecondaryElementText,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 85.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          item.lastTime == null
                              ? ""
                              : duTimeLineFormat(
                                  (item.lastTime as Timestamp).toDate()),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.normal,
                            color: AppColors.thirdElementText,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          item.type == null ? "" : "${item.type}",
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.normal,
                            color: AppColors.thirdElementText,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headBar() {
    return Center(
      child: Container(
        width: 320.w,
        height: 44.w,
        margin: EdgeInsets.only(bottom: 20.h, top: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.primarySecondaryBackground,
                      borderRadius: BorderRadius.all(
                        Radius.circular(22.w),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: controller.state.headDetail.value.avatar == null
                        ? const Image(
                            image:
                                AssetImage('assets/images/account_header.png'),
                          )
                        : CachedNetworkImage(
                            imageUrl: controller.state.headDetail.value.avatar!,
                            height: 44.w,
                            width: 44.w,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(22.w)),
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.fill
                                    // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                                    ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Image(
                              image: AssetImage(
                                  'assets/images/account_header.png'),
                            ),
                          ),
                  ),
                  onTap: () {
                    controller.goProfile();
                  },
                ),
                Positioned(
                  bottom: 5.w,
                  right: 0.w,
                  height: 14.w,
                  child: Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 2.w, color: AppColors.primaryElementText),
                      color: controller.state.headDetail.value.online == 1
                          ? AppColors.primaryElementStatus
                          : AppColors.primarySecondaryElementText,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.w),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // GestureDetector(
            //   child:Container(
            //       width: 40.w,
            //       height: 40.h,
            //       padding: EdgeInsets.all(7.w),
            //       child: Image.asset("assets/icons/search.png"),
            //     ),onTap: (){controller.goSearch();},)
          ],
        ),
      ),
    );
  }

  Widget _headTabs() {
    return Center(
      child: Container(
        width: 320.w,
        height: 48.h,
        margin: EdgeInsets.only(bottom: 0.h),
        padding: EdgeInsets.all(4.w),
        decoration: const BoxDecoration(
          color: AppColors.primarySecondaryBackground,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              child: Container(
                width: 150.w,
                height: 40.h,
                margin: EdgeInsets.only(bottom: 0.h),
                padding: EdgeInsets.all(0.h),
                decoration: controller.state.tabStatus.value
                    ? BoxDecoration(
                        color: AppColors.primaryBackground,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(
                                0, 2), // changes position of shadow
                          ),
                        ],
                      )
                    : const BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Chat",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryThreeElementText,
                          fontWeight: FontWeight.normal,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                controller.goTabStatus();
              },
            ),
            GestureDetector(
              child: Container(
                width: 150.w,
                height: 40.h,
                margin: EdgeInsets.only(bottom: 0.h),
                padding: EdgeInsets.all(0.h),
                decoration: controller.state.tabStatus.value
                    ? const BoxDecoration()
                    : BoxDecoration(
                        color: AppColors.primaryBackground,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(
                                0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Call",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.normal,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                controller.goTabStatus();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: _headBar(),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: 0.w,
                      horizontal: 0.w,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _headTabs(),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: 0.w,
                      horizontal: 20.w,
                    ),
                    sliver: controller.state.tabStatus.value
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (content, index) {
                                var item = controller.state.msgList[index];
                                return chatListItem(item);
                              },
                              childCount: controller.state.msgList.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (content, index) {
                                var item = controller.state.callList[index];
                                //controller.state.msgList.length
                                return callListItem(item);
                              },
                              childCount: controller.state.callList.length,
                            ),
                          ),
                  ),
                ],
              ),
              Positioned(
                right: 20.w,
                bottom: 70.h,
                height: 50.w,
                width: 50.w,
                child: GestureDetector(
                  child: Container(
                    height: 50.w,
                    width: 50.w,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryElement,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset:
                              const Offset(1, 1), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(40.w)),
                    ),
                    child: Image.asset("assets/icons/contact.png"),
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.contact);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}