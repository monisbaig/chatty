import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/utils/utils.dart';
import 'package:chatty/common/values/values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

Widget leftRichTextContainer(String textContent) {
  const urlPattern =
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+-~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&\/\/=]*)";
  List<InlineSpan> widgets = [];

  textContent.splitMapJoin(
    RegExp(urlPattern, caseSensitive: false, multiLine: false),
    onMatch: (Match match) {
      final matchText = match[0];
      if (matchText != null) {
        widgets.add(
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Uri _url = Uri.parse(matchText);
                launchUrl(_url);
              },
            text: matchText,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryText,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }
      return '';
    },
    onNonMatch: (String text) {
      if (text.isNotEmpty) {
        widgets.add(
          TextSpan(
            text: text,
            style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
          ),
        );
      }
      return '';
    },
  );

  return RichText(
    text: TextSpan(children: [...widgets]),
  );
}

Widget chatLeftItem(Msgcontent item) {
  dynamic imagePath;
  if (item.type == 'image') {
    imagePath = item.content?.replaceAll('http://localhost/', SERVER_API);
  }

  return Container(
    padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w, bottom: 10.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 250.w, //
              minHeight: 40.w //
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 0.w, top: 0.w),
                padding: EdgeInsets.only(
                    top: 10.w, bottom: 10.w, left: 10.w, right: 10.w),
                decoration: BoxDecoration(
                  color: AppColors.primarySecondaryBackground,
                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                ),
                child: item.type == "text"
                    ? leftRichTextContainer("${item.content}")
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 90.w),
                        child: GestureDetector(
                          child:
                              CachedNetworkImage(imageUrl: "${item.content}"),
                          onTap: () {},
                        ),
                      ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.h),
                child: Text(
                  item.addtime == null
                      ? ""
                      : duTimeLineFormat((item.addtime as Timestamp).toDate()),
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primarySecondaryElementText),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
